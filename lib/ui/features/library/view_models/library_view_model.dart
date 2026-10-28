// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:openlib/app/di.dart';
import 'package:openlib/data/models/my_book.dart';
import 'package:openlib/data/repositories/cover_repository.dart';
import 'package:openlib/data/repositories/download_repository.dart';
import 'package:openlib/data/repositories/library_repository.dart';
import 'package:openlib/data/repositories/mirror_repository.dart';
import 'package:openlib/data/repositories/preferences_repository.dart';
import 'package:openlib/data/services/download_manager.dart';
import 'package:openlib/data/services/slum_catalogue.dart' show MirrorService;
import 'package:openlib/data/services/stream_throttle.dart';

/// A completed download as shown in the download center. The file facts
/// come from the local file, so the database schema stays unchanged.
class CompletedDownload {
  final MyBook book;
  final int? sizeBytes;
  final DateTime? modifiedAt;

  const CompletedDownload({
    required this.book,
    this.sizeBytes,
    this.modifiedAt,
  });

  String get fileName => book.getFileName();
}

bool _isActiveTask(DownloadTask task) =>
    task.status != DownloadStatus.completed &&
    task.status != DownloadStatus.cancelled &&
    task.status != DownloadStatus.failed;

/// Owns the download center's data: completed records (enriched with file
/// facts), the in-memory download queue, and the Anna's Archive base URL the
/// book detail route needs.
class LibraryViewModel extends ChangeNotifier {
  LibraryViewModel({
    required LibraryRepository library,
    required DownloadRepository downloads,
    required PreferencesRepository preferences,
    required CoverRepository covers,
    required MirrorRepository mirrors,
  })  : _library = library,
        _downloads = downloads,
        _preferences = preferences,
        _covers = covers,
        _mirrors = mirrors {
    // Seed from the manager so a page opened while a download is already
    // running does not wait for the next progress tick.
    _lastTasks = downloads.active;
    _applyTasks(_lastTasks, notify: false);
    _subscription = throttleLatest(
      downloads.updates,
      const Duration(milliseconds: 100),
    ).listen(_onTasks);
    _library.addListener(_onLibraryChanged);
    unawaited(_resolveAnnaArchiveBaseUrl());
  }

  /// Detail pages, onboarding and settings delete or import books through
  /// the same repository instance; refresh so the completed list is never
  /// stale when the tab is shown again.
  void _onLibraryChanged() {
    if (!_disposed) refresh();
  }

  factory LibraryViewModel.fromDi() => LibraryViewModel(
        library: getIt<LibraryRepository>(),
        downloads: getIt<DownloadRepository>(),
        preferences: getIt<PreferencesRepository>(),
        covers: getIt<CoverRepository>(),
        mirrors: getIt<MirrorRepository>(),
      );

  final LibraryRepository _library;
  final DownloadRepository _downloads;
  final PreferencesRepository _preferences;
  final CoverRepository _covers;
  final MirrorRepository _mirrors;

  StreamSubscription<Map<String, DownloadTask>>? _subscription;
  Map<String, DownloadTask> _lastTasks = const {};
  List<MyBook> _books = const [];
  List<CompletedDownload> _completed = const [];
  List<DownloadTask> _active = const [];
  List<DownloadTask> _failed = const [];
  int _activeCount = 0;
  int _failedCount = 0;
  bool _loading = false;
  bool _busy = false;
  bool _loadStarted = false;
  bool _disposed = false;
  String? _annaArchiveBaseUrl;

  List<MyBook> get books => _books;

  List<CompletedDownload> get completed => _completed;

  /// In-flight tasks (queued, downloading, paused, verifying); recently
  /// completed tasks linger in the manager and are deliberately excluded.
  List<DownloadTask> get active => _active;

  List<DownloadTask> get failed => _failed;

  int get activeCount => _activeCount;

  int get failedCount => _failedCount;

  bool get loading => _loading;

  /// True while a record delete is in flight.
  bool get busy => _busy;

  String? get annaArchiveBaseUrl => _annaArchiveBaseUrl;

  Future<void> load() async {
    if (_loadStarted) return;
    _loadStarted = true;
    _loading = true;
    _notify();
    try {
      await _reload();
    } finally {
      _loading = false;
      _notify();
    }
  }

  /// Fire-and-forget refresh for pull-to-refresh and delete flows.
  void refresh() {
    unawaited(_reload());
  }

  Future<void> pause(String id) => _downloads.pause(id);

  Future<void> resume(String id) => _downloads.resume(id);

  void cancel(String id) => _downloads.cancel(id);

  Future<void> retry(String id) => _downloads.retryKeepingPartial(id);

  Future<void> restartWithMirrors(String id, List<String> mirrors) =>
      _downloads.restartWithMirrors(id, mirrors);

  Future<void> pauseAll() => _downloads.pauseAll();

  Future<void> resumeAll() => _downloads.resumeAll();

  /// Removes the record and, unless [removeFile] is false, its local file.
  Future<void> deleteBook(MyBook book, {bool removeFile = true}) async {
    _busy = true;
    _notify();
    try {
      if (removeFile) {
        await _library.deleteWithFile(book);
      } else {
        await _library.deleteRecord(book);
      }
    } finally {
      _busy = false;
      _notify();
    }
    await _reload();
  }

  Future<String?> coverFor(String? thumbnail, String link) {
    final direct = thumbnail?.trim() ?? '';
    if (direct.isNotEmpty) return Future.value(direct);
    if (link.isEmpty) return Future.value(null);
    return _covers.coverFor(link);
  }

  void _onTasks(Map<String, DownloadTask> tasks) {
    final newlyCompleted = tasks.values.any((task) =>
        task.status == DownloadStatus.completed &&
        _lastTasks[task.id]?.status != DownloadStatus.completed);
    _lastTasks = tasks;
    _applyTasks(tasks);
    // The manager writes the book row just before flipping to completed, so
    // the completed list is stale until this refresh lands.
    if (newlyCompleted) refresh();
  }

  void _applyTasks(Map<String, DownloadTask> tasks, {bool notify = true}) {
    final active = <DownloadTask>[];
    final failed = <DownloadTask>[];
    for (final task in tasks.values) {
      if (task.status == DownloadStatus.failed) {
        failed.add(task);
      } else if (_isActiveTask(task)) {
        active.add(task);
      }
    }
    _active = List.unmodifiable(active);
    _failed = List.unmodifiable(failed);
    _activeCount = active.length;
    _failedCount = failed.length;
    if (notify) _notify();
  }

  Future<void> _reload() async {
    try {
      final books = await _library.allBooks();
      // Resolve the folder once: reading the preference per book turned
      // opening the tab into N database queries on top of N stat calls.
      final storageDirectory = await _preferences.bookStorageDirectory();
      final entries = await Future.wait(books.map((book) async {
        int? size;
        DateTime? modified;
        if (storageDirectory != null) {
          try {
            final stat =
                await File('$storageDirectory/${book.getFileName()}').stat();
            size = stat.size;
            modified = stat.modified;
          } catch (_) {
            // The record survives even if the file was moved away.
          }
        }
        return CompletedDownload(
          book: book,
          sizeBytes: size,
          modifiedAt: modified,
        );
      }));
      entries.sort((a, b) {
        final aTime = a.modifiedAt?.millisecondsSinceEpoch ?? 0;
        final bTime = b.modifiedAt?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });
      if (_disposed) return;
      _books = books;
      _completed = entries;
      _notify();
    } catch (_) {
      // A failed read used to surface as an empty AsyncValue; keep the last
      // known list instead of throwing into a fire-and-forget refresh.
    }
  }

  Future<void> _resolveAnnaArchiveBaseUrl() async {
    try {
      final urls = await _mirrors.enabledUrls(MirrorService.annasArchive);
      if (urls.isEmpty || _disposed) return;
      final base = urls.first;
      _annaArchiveBaseUrl =
          base.endsWith('/') ? base.substring(0, base.length - 1) : base;
      _notify();
    } catch (_) {
      // The "open in site" button falls back to the book's own link.
    }
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _library.removeListener(_onLibraryChanged);
    _subscription?.cancel();
    super.dispose();
  }
}
