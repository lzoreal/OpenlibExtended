// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:openlib/app/app_settings.dart';
import 'package:openlib/app/di.dart';
import 'package:openlib/data/models/book_data.dart';
import 'package:openlib/data/models/download_refusal.dart';
import 'package:openlib/data/models/my_book.dart';
import 'package:openlib/data/repositories/book_info_repository.dart';
import 'package:openlib/data/repositories/cover_repository.dart';
import 'package:openlib/data/repositories/download_repository.dart';
import 'package:openlib/data/repositories/library_repository.dart';
import 'package:openlib/data/repositories/mirror_repository.dart';
import 'package:openlib/data/services/annas_archieve.dart';
import 'package:openlib/data/services/download_manager.dart';
import 'package:openlib/data/services/download_target.dart';
import 'package:openlib/data/services/instance_manager.dart';
import 'package:openlib/data/services/platform_utils.dart';
import 'package:openlib/data/services/search_manager.dart';
import 'package:openlib/data/services/stream_throttle.dart';
import 'package:openlib/data/models/file_name.dart';

/// What the detail page should do after the user taps download.
sealed class DownloadPlan {
  const DownloadPlan();
}

/// The resolved page needs a browser pass for its mirrors: the page pushes
/// the WebView and hands the captured mirrors back through
/// [BookDetailViewModel.startWithMirrors].
class DownloadNeedsMirrors extends DownloadPlan {
  const DownloadNeedsMirrors(this.url);

  final String url;
}

/// The task was queued. [fast] selects the "fast download" snackbar.
class DownloadStarted extends DownloadPlan {
  const DownloadStarted(this.fast);

  final bool fast;
}

/// No route produced a link. [refusal] carries the mirror's own reason (or
/// one of the view model's refusal codes) so the page can pick the text;
/// null means the generic "no mirrors" message.
class DownloadRefused extends DownloadPlan {
  const DownloadRefused(this.refusal);

  final String? refusal;
}

/// Owns the book-detail page's state and its download resolution.
///
/// The page keeps AppBar, snackbar text and navigation; everything that
/// talks to a service, the library or the download queue lives here.
class BookDetailViewModel extends ChangeNotifier {
  BookDetailViewModel({
    required this.url,
    this.source,
    BookData? preview,
    required LibraryRepository library,
    required DownloadRepository downloads,
    required AppSettings settings,
    required BookInfoRepository bookInfo,
    required MirrorRepository mirrors,
    required CoverRepository covers,
  })  : _preview = preview,
        _library = library,
        _downloads = downloads,
        _settings = settings,
        _bookInfo = bookInfo,
        _mirrors = mirrors,
        _covers = covers {
    _settings.addListener(_notify);
    unawaited(_resolveCover());
    _task = _findTask(_downloads.active);
    _taskSubscription = throttleLatest(
      _downloads.updates,
      const Duration(milliseconds: 100),
    ).listen(_onTasks);
  }

  factory BookDetailViewModel.fromDi({
    required String url,
    String? source,
    BookData? preview,
  }) {
    return BookDetailViewModel(
      url: url,
      source: source,
      preview: preview,
      library: getIt<LibraryRepository>(),
      downloads: getIt<DownloadRepository>(),
      settings: getIt<AppSettings>(),
      bookInfo: getIt<BookInfoRepository>(),
      mirrors: getIt<MirrorRepository>(),
      covers: getIt<CoverRepository>(),
    );
  }

  /// WeLib refusals the view model cannot localize; the page maps these
  /// codes back to its own strings.
  static const welibNoDownloadLinkRefusal =
      DownloadRefusal.welibNoDownloadLink;
  static const welibPageUnreadableRefusal =
      DownloadRefusal.welibPageUnreadable;

  final String url;
  final String? source;
  final BookData? _preview;
  final LibraryRepository _library;
  final DownloadRepository _downloads;
  final AppSettings _settings;
  final BookInfoRepository _bookInfo;
  final MirrorRepository _mirrors;
  final CoverRepository _covers;

  final ZlibraryProvider _zlibrary = ZlibraryProvider();
  final WelibProvider _welib = WelibProvider();
  final AnnasArchieve _annasArchive = AnnasArchieve();

  BookInfoData? _data;
  Object? _error;
  StackTrace? _errorStackTrace;
  bool? _inLibrary;
  MyBook? _libraryBook;
  String? _annaArchiveBaseUrl;
  bool _loadStarted = false;
  bool _fetching = false;
  bool _disposed = false;
  DownloadTask? _task;
  StreamSubscription<Map<String, DownloadTask>>? _taskSubscription;
  String? _resolvedCover;

  /// The full detail page once it arrived, otherwise what the results row
  /// already knew - so a tap never lands on a blank spinner.
  BookData? get book => _data ?? _preview;

  /// Non-null only once the real detail page is loaded; the page shows the
  /// disabled download bar until then.
  BookInfoData? get details => _data;

  bool get loading => _data == null && _error == null;

  bool get hasError => _error != null;

  Object? get error => _error;

  StackTrace? get errorStackTrace => _errorStackTrace;

  /// Null while membership is unknown (the old provider's loading/error
  /// state rendered nothing).
  bool? get inLibrary => _inLibrary;

  MyBook? get libraryBook => _libraryBook;

  String? get annaArchiveBaseUrl => _annaArchiveBaseUrl;

  /// The live queue entry for this book, if any. The action bar renders its
  /// progress instead of the download button while it is active.
  DownloadTask? get task => _task;

  /// Search rows without a thumbnail resolve one lazily; the same cached
  /// value is reused here so the detail page does not re-fetch the cover.
  String? get coverUrl => _resolvedCover;

  Future<void> _resolveCover() async {
    if (_disposed || _resolvedCover != null) return;
    final previewThumb = (_preview?.thumbnail ?? '').trim();
    if (previewThumb.isNotEmpty) return;
    try {
      final cover = await _covers.coverFor(url);
      if (_disposed || cover == null || cover.isEmpty) return;
      _resolvedCover = cover;
      _notify();
    } catch (_) {
      // A missing cover only falls back to the placeholder.
    }
  }

  bool get taskCompleted => _task?.status == DownloadStatus.completed;

  bool get taskFailed => _task?.status == DownloadStatus.failed;

  bool get taskPaused => _task?.status == DownloadStatus.paused;

  bool get taskVerifying => _task?.status == DownloadStatus.verifying;

  /// Mirror resolution, queueing and the initial hop carry no byte progress.
  bool get taskPreparing {
    final status = _task?.status;
    return status == DownloadStatus.queued ||
        status == DownloadStatus.fetchingMirrors ||
        status == DownloadStatus.downloadingMirrors;
  }

  double get taskProgress => (_task?.progress ?? 0).clamp(0.0, 1.0);

  String? get _md5 => _data?.md5 ?? _preview?.md5;

  DownloadTask? _findTask(Map<String, DownloadTask> tasks) {
    final md5 = _md5;
    if (md5 == null || md5.isEmpty) return null;
    for (final task in tasks.values) {
      if (task.md5 == md5 && task.status != DownloadStatus.cancelled) {
        return task;
      }
    }
    return null;
  }

  void _onTasks(Map<String, DownloadTask> tasks) {
    if (_disposed) return;
    final previous = _task;
    final next = _findTask(tasks);
    _task = next;
    final completed = previous?.status != DownloadStatus.completed &&
        next?.status == DownloadStatus.completed;
    if (next != null || previous != null) _notify();
    if (completed) unawaited(refreshMembership());
  }

  /// Pauses an active task, resumes a paused one, retries a failed one.
  Future<void> toggleTask() async {
    final task = _task;
    if (task == null) return;
    switch (task.status) {
      case DownloadStatus.paused:
        await _downloads.resume(task.id);
      case DownloadStatus.failed:
        await _downloads.retryKeepingPartial(task.id);
      default:
        await _downloads.pause(task.id);
    }
  }

  bool get showManualButton => _settings.showManualDownloadButton;

  String get donationKey => _settings.donationKey;

  Future<void> load() async {
    if (_loadStarted) return;
    _loadStarted = true;
    unawaited(_loadAnnaArchiveBaseUrl());
    await _loadDetails();
  }

  void retry() {
    if (_fetching) return;
    _error = null;
    _errorStackTrace = null;
    _notify();
    unawaited(_loadDetails());
  }

  Future<void> refreshMembership() async {
    final id = _data?.md5;
    if (id == null || id.isEmpty) {
      if (_inLibrary != null || _libraryBook != null) {
        _inLibrary = null;
        _libraryBook = null;
        _notify();
      }
      return;
    }
    try {
      final exists = await _library.contains(id);
      if (_disposed) return;
      final book = exists ? await _library.bookById(id) : null;
      if (_disposed) return;
      _inLibrary = exists;
      _libraryBook = book;
    } catch (_) {
      if (_disposed) return;
      _inLibrary = null;
      _libraryBook = null;
    }
    _notify();
  }

  /// Runs every download route, in the order the old button handler used.
  Future<DownloadPlan> startDownload() async {
    final data = _data;
    if (data == null) return const DownloadRefused(null);

    String? downloadUrl = data.mirror;
    bool isFastDownload = data.isFastDownload;

    // Libgen serves its files directly (get.php -> CDN); no mirror scraping
    // or donation key applies.
    var isDirectLink = downloadUrl != null && downloadUrl.contains('/get.php?');
    if (isDirectLink) isFastDownload = true;

    // Z-Library /dl/ links sit behind a DiamWall proof-of-work and a 302 to
    // a signed CDN URL; a cached detail page keeps no signed mirror, so the
    // book page itself is the signal to resolve one.
    final isZlib = (downloadUrl?.contains('/dl/') ?? false) ||
        (downloadUrl == null && data.link.contains('/book/'));
    String? zlibRefusal;
    if (isZlib && !isDirectLink) {
      try {
        final resolved = await _zlibrary.resolveBookDownload(data.link);
        if (resolved.url != null) {
          downloadUrl = resolved.url;
          isDirectLink = true;
          isFastDownload = true;
        } else {
          zlibRefusal = resolved.refusal;
        }
      } catch (_) {
        // Fall through to the slow AA-style flow, which cannot work for
        // zlib; the refusal snackbar below fires.
      }
    }

    // WeLib's public-server page carries the partner file link, but with
    // the class on a <div> where the Anna's Archive scraper looks for a
    // <p>, so it needs WeLib's own parser. The signed file URL expires, so
    // the page URL is kept for the task's linkRefresher.
    final isWelib = isWelibUrl(downloadUrl);
    final welibPageUrl = isWelib ? downloadUrl : null;
    String? welibRefusal;
    if (welibPageUrl != null && !isDirectLink) {
      try {
        final resolved = await _welib.resolveDownload(welibPageUrl);
        if (resolved.url != null) {
          downloadUrl = resolved.url;
          isDirectLink = true;
          isFastDownload = true;
        } else {
          welibRefusal = resolved.refusal ?? welibNoDownloadLinkRefusal;
        }
      } catch (_) {
        welibRefusal = welibPageUnreadableRefusal;
      }
    }

    // Donation-key fast link, when one is configured and nothing faster
    // already answered.
    final donationKey = isDirectLink ? '' : _settings.donationKey;
    var donationFastLink = false;
    if (donationKey.isNotEmpty && !isFastDownload) {
      try {
        final fastLink =
            await _annasArchive.getFastDownloadUrl(data.md5, donationKey);
        if (fastLink != null) {
          downloadUrl = fastLink;
          isFastDownload = true;
          donationFastLink = true;
        }
      } catch (_) {
        // Fallback to the normal mirror.
      }
    }

    // A mirror that stated why it withheld the file only wins when nothing
    // else produced a link - starting a download against the refused /dl/
    // hop could only fail, hiding that message.
    final target = chooseDownloadTarget(
      url: downloadUrl,
      fast: isDirectLink || donationFastLink,
      refusal: zlibRefusal ?? welibRefusal,
    );
    if (!target.hasUrl) return DownloadRefused(target.refusal);
    final effectiveUrl = target.url!;

    // Linux has no headless WebView: the user fetches mirrors through the
    // visible browser first. Fast links skip that step.
    if (PlatformUtils.isLinux && !isFastDownload) {
      return DownloadNeedsMirrors(effectiveUrl);
    }

    final task = DownloadTask(
      id: '${data.md5}_${DateTime.now().millisecondsSinceEpoch}',
      md5: data.md5,
      title: data.title,
      author: data.author,
      thumbnail: data.thumbnail,
      publisher: data.publisher,
      info: data.info,
      format: data.format!,
      description: data.description,
      link: data.link,
      mirrors: const [], // Fetched in the background from the mirror URL.
      mirrorUrl: effectiveUrl,
      isDirectLink: isFastDownload,
      // z-lib's signed CDN link and WeLib's partner link both expire; the
      // manager re-resolves a fresh one from the page instead of failing.
      linkRefresher: isZlib
          ? (pageUrl) async =>
              (await _zlibrary.resolveBookDownload(pageUrl)).url
          : welibPageUrl != null
              ? (_) async => (await _welib.resolveDownload(welibPageUrl)).url
              : null,
    );

    await _downloads.addWithMirrorUrl(task, effectiveUrl);
    await refreshMembership();
    return DownloadStarted(isFastDownload);
  }

  /// The manual button: the stored page always drives the visible WebView,
  /// nothing is resolved here. No page means the page's "no mirrors" text.
  Future<DownloadPlan> manualDownload() async {
    final mirror = _data?.mirror;
    if (mirror == null || mirror.isEmpty) return const DownloadRefused(null);
    return DownloadNeedsMirrors(mirror);
  }

  /// Starts a download from mirrors the user captured in the WebView.
  /// [url] is the page they came from; it is not stored on the task
  /// because the mirrors themselves are already usable.
  Future<bool> startWithMirrors(String url, List<String> mirrors) async {
    final data = _data;
    if (data == null || mirrors.isEmpty) return false;
    final task = DownloadTask(
      id: '${data.md5}_${DateTime.now().millisecondsSinceEpoch}',
      md5: data.md5,
      title: data.title,
      author: data.author,
      thumbnail: data.thumbnail,
      publisher: data.publisher,
      info: data.info,
      format: data.format!,
      description: data.description,
      link: data.link,
      mirrors: mirrors,
    );
    await _downloads.add(task);
    await refreshMembership();
    return true;
  }

  /// Deletes the stored record and its file, then re-checks membership.
  Future<void> deleteFile(FileName fileName) async {
    try {
      final book = _libraryBook ?? await _library.bookById(fileName.md5);
      if (book != null) await _library.deleteWithFile(book);
    } catch (_) {
      // The refresh below shows the record still in the library.
    }
    // The old dialog refreshed a beat later, after the background delete
    // had landed; keep that visible delay.
    await Future<void>.delayed(const Duration(seconds: 1));
    if (_disposed) return;
    await refreshMembership();
  }

  Future<void> _loadDetails() async {
    if (_fetching) return;
    _fetching = true;
    try {
      final data =
          await _bookInfo.fetch(url, donationKey: _settings.donationKey);
      if (_disposed) return;
      _data = data;
      _error = null;
      _errorStackTrace = null;
      _task = _findTask(_downloads.active);
      _notify();
      if ((data.thumbnail ?? '').trim().isEmpty) unawaited(_resolveCover());
      await refreshMembership();
    } catch (error, stackTrace) {
      if (_disposed) return;
      _error = error;
      _errorStackTrace = stackTrace;
    } finally {
      _fetching = false;
      _notify();
    }
  }

  Future<void> _loadAnnaArchiveBaseUrl() async {
    String? base;
    try {
      final urls = await _mirrors.enabledUrls(MirrorService.annasArchive);
      if (urls.isNotEmpty) base = urls.first;
    } catch (_) {
      // No catalogue means no site button, exactly like the old provider.
    }
    if (_disposed) return;
    _annaArchiveBaseUrl = base == null
        ? null
        : (base.endsWith('/') ? base.substring(0, base.length - 1) : base);
    _notify();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _taskSubscription?.cancel();
    _settings.removeListener(_notify);
    super.dispose();
  }
}
