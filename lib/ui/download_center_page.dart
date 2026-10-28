// Dart imports:
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

// Flutter imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:openlib/l10n/app_localizations.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:openlib/data/models/my_book.dart';
import 'package:openlib/data/services/database.dart';
import 'package:openlib/data/services/download_manager.dart';
import 'package:openlib/data/services/files.dart' show deleteFile, getFilePath;
import 'package:openlib/data/services/platform_utils.dart';
import 'package:openlib/data/services/share_book.dart';
import 'package:openlib/data/repositories/preferences_repository.dart';
import 'package:openlib/state/state.dart'
    show
        activeDownloadsProvider,
        downloadManagerProvider,
        myLibraryProvider,
        selectedIndexProvider;
import 'package:openlib/ui/components/book_info_widget.dart'
    show sourceLabelForUrl;
import 'package:openlib/ui/components/content_width.dart';
import 'package:openlib/ui/components/inline_hint.dart';
import 'package:openlib/ui/open_book.dart';
import 'package:openlib/ui/components/page_header.dart';
import 'package:openlib/ui/components/pill_tabs.dart';
import 'package:openlib/ui/components/section_header.dart';
import 'package:openlib/ui/components/tab_keep_alive.dart';
import 'package:openlib/ui/mybook_page.dart';
import 'package:openlib/ui/swiss_grid.dart';
import 'package:openlib/ui/webview_page.dart';

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

/// Completed records live in the `mybooks` table. The preview calls for
/// "completed downloads" rather than a browsable library, so this provider
/// only enriches them with file size and modification time.
final completedDownloadsProvider =
    FutureProvider<List<CompletedDownload>>((ref) async {
  final books = await ref.watch(myLibraryProvider.future);
  // Resolve the folder once: reading the preference per book turned
  // opening the tab into N database queries on top of N stat calls.
  final storageDirectory = await PreferencesRepository().bookStorageDirectory();
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
  return entries;
});

bool _isActiveTask(DownloadTask task) =>
    task.status != DownloadStatus.completed &&
    task.status != DownloadStatus.cancelled &&
    task.status != DownloadStatus.failed;

@immutable
class _ActiveSummary {
  const _ActiveSummary({required this.activeCount, required this.failedCount});

  final int activeCount;
  final int failedCount;

  static const empty = _ActiveSummary(activeCount: 0, failedCount: 0);

  @override
  bool operator ==(Object other) =>
      other is _ActiveSummary &&
      other.activeCount == activeCount &&
      other.failedCount == failedCount;

  @override
  int get hashCode => Object.hash(activeCount, failedCount);
}

/// Only counts/statuses: progress ticks produce an equal summary, so the
/// page shell and the completed list do not rebuild ten times per second.
final _activeSummaryProvider = Provider<_ActiveSummary>((ref) {
  final tasks =
      ref.watch(activeDownloadsProvider).valueOrNull?.values ?? const [];
  var active = 0;
  var failed = 0;
  for (final task in tasks) {
    if (task.status == DownloadStatus.failed) {
      failed++;
    } else if (_isActiveTask(task)) {
      active++;
    }
  }
  return _ActiveSummary(activeCount: active, failedCount: failed);
});

enum _DownloadFilter { all, active, completed }

enum _CompletedAction { details, share, folder, remove }

class DownloadCenterPage extends ConsumerStatefulWidget {
  const DownloadCenterPage({super.key});

  @override
  ConsumerState<DownloadCenterPage> createState() => _DownloadCenterPageState();
}

class _DownloadCenterPageState extends ConsumerState<DownloadCenterPage>
    with SingleTickerProviderStateMixin {
  Timer? _speedTimer;
  final Map<String, int> _lastBytes = {};
  final Map<String, double> _speeds = {};
  DateTime _lastSample = DateTime.now();
  bool _hasSample = false;
  bool _tabActive = false;
  String? _verifyingTaskId;
  _DownloadFilter _filter = _DownloadFilter.all;
  late final TabController _filterController;

  @override
  void initState() {
    super.initState();
    _filterController = TabController(
      length: _DownloadFilter.values.length,
      vsync: this,
      initialIndex: _filter.index,
    );
    _filterController.addListener(_syncFilter);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final active = TabVisibility.of(context);
    if (active == _tabActive) return;
    _tabActive = active;
    _speedTimer?.cancel();
    _speedTimer = null;
    if (!active) return;
    // Speeds come from byte deltas, so a tab that was hidden for a while
    // needs a fresh baseline instead of one giant spike on return.
    _hasSample = false;
    _lastBytes.clear();
    _speeds.clear();
    _speedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _sampleSpeeds();
    });
  }

  void _syncFilter() {
    final next = _DownloadFilter.values[_filterController.index];
    if (next != _filter) {
      setState(() => _filter = next);
    }
  }

  @override
  void dispose() {
    _speedTimer?.cancel();
    _filterController.dispose();
    super.dispose();
  }

  void _sampleSpeeds() {
    final downloads = ref.read(downloadManagerProvider).activeDownloads;
    if (downloads.isEmpty && _lastBytes.isEmpty && _speeds.isEmpty) return;

    final now = DateTime.now();
    final seconds = now.difference(_lastSample).inMilliseconds / 1000;
    if (seconds <= 0) return;

    if (!_hasSample) {
      _hasSample = true;
      _lastSample = now;
      _lastBytes
        ..clear()
        ..addEntries(downloads.values
            .map((task) => MapEntry(task.id, task.downloadedBytes)));
      _speeds.clear();
      return;
    }

    final nextSpeeds = <String, double>{};
    final nextLast = <String, int>{};
    for (final task in downloads.values) {
      if (task.status == DownloadStatus.downloading) {
        final previousBytes = _lastBytes[task.id];
        final instant = previousBytes == null
            ? 0.0
            : (task.downloadedBytes - previousBytes) / seconds;
        final previousSpeed = _speeds[task.id] ?? 0;
        nextSpeeds[task.id] =
            previousSpeed == 0 ? instant : previousSpeed * 0.6 + instant * 0.4;
      }
      nextLast[task.id] = task.downloadedBytes;
    }

    _speeds
      ..clear()
      ..addAll(nextSpeeds);
    _lastBytes
      ..clear()
      ..addAll(nextLast);
    _lastSample = now;
    if (mounted) setState(() {});
  }

  Future<void> _toggleAll(List<DownloadTask> active) async {
    final manager = ref.read(downloadManagerProvider);
    final paused = active.where((t) => t.status == DownloadStatus.paused);
    final pausable = active.where((t) =>
        t.status == DownloadStatus.downloading ||
        t.status == DownloadStatus.downloadingMirrors ||
        t.status == DownloadStatus.fetchingMirrors ||
        t.status == DownloadStatus.queued);
    if (paused.isNotEmpty && pausable.isEmpty) {
      await manager.resumeAll();
    } else {
      await manager.pauseAll();
    }
  }

  Future<void> _verifyTask(DownloadTask task) async {
    if (task.mirrorUrl == null || _verifyingTaskId != null) return;
    setState(() => _verifyingTaskId = task.id);
    final manager = ref.read(downloadManagerProvider);
    final mirrors = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => Webview(
          url: task.mirrorUrl!,
          showOverlay: false,
        ),
      ),
    );
    if (mirrors != null && mirrors.isNotEmpty && mounted) {
      await manager.restartDownloadWithMirrors(task.id, mirrors);
    }
    if (mounted) setState(() => _verifyingTaskId = null);
  }

  Future<void> _openCompleted(MyBook book) async {
    await openBookExternally(
      fileName: book.getFileName(),
      format: book.format ?? '',
      context: context,
    );
  }

  Future<void> _removeRecord(CompletedDownload item) async {
    final l10n = AppLocalizations.of(context);
    var removeFile = false;
    final deleteLocalFile = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final scheme = Theme.of(context).colorScheme;
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: scheme.errorContainer,
                        borderRadius: BorderRadius.circular(SwissRadius.field),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: scheme.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.downloadCenterRemoveRecord,
                    style: SwissText.subtitle.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.downloadCenterRemoveRecordBody,
                    style: SwissText.caption.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(SwissRadius.field),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: CheckboxListTile(
                        value: removeFile,
                        onChanged: (value) =>
                            setDialogState(() => removeFile = value ?? false),
                        title: Text(
                          l10n.downloadCenterRemoveFile,
                          style: SwissText.label.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context, removeFile),
                          style: FilledButton.styleFrom(
                            backgroundColor: scheme.error,
                            foregroundColor: scheme.onError,
                          ),
                          child: Text(l10n.delete),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (deleteLocalFile == null) return;
    if (deleteLocalFile) {
      try {
        final directory =
            await PreferencesRepository().bookStorageDirectory();
        if (directory != null) {
          await deleteFile('$directory/${item.fileName}');
        }
      } catch (_) {
        // The record must still go away if the file or preference is missing.
      }
    }
    final db = MyLibraryDb.instance;
    await db.delete(item.book.id);
    await db.deleteBookState(item.fileName);
    ref.invalidate(myLibraryProvider);
    ref.invalidate(completedDownloadsProvider);
  }

  Future<void> _openStorageFolder() async {
    final l10n = AppLocalizations.of(context);
    try {
      final directory = await PreferencesRepository().bookStorageDirectory();
      if (directory == null) return;
      if (PlatformUtils.isWindows) {
        await Process.run('explorer.exe', [directory]);
      } else if (PlatformUtils.isMacOS) {
        await Process.run('open', [directory]);
      } else if (PlatformUtils.isLinux) {
        await Process.run('xdg-open', [directory]);
      } else if (Platform.isAndroid) {
        // Android has no intent that reliably reaches a file manager for a
        // folder; the system document browser is the one UI every device
        // ships, and it can be opened straight at the library folder.
        await FilePicker.getDirectoryPath(
          dialogTitle: l10n.downloadCenterShowInFolder,
          initialDirectory: directory,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.storagePathMessage(directory))),
        );
      }
    } catch (_) {
      // File manager integration is best-effort.
    }
  }

  Future<void> _showInFolder(CompletedDownload item) async {
    try {
      final path = await getFilePath(item.fileName);
      if (PlatformUtils.isWindows) {
        await Process.run('explorer.exe', ['/select,', path]);
      } else if (PlatformUtils.isMacOS) {
        await Process.run('open', ['-R', path]);
      } else if (PlatformUtils.isLinux) {
        await Process.run('xdg-open', [File(path).parent.path]);
      }
    } catch (_) {
      // File manager integration is best-effort.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    ref.listen(activeDownloadsProvider, (previous, next) {
      final before = previous?.valueOrNull ?? const <String, DownloadTask>{};
      final after = next.valueOrNull ?? const <String, DownloadTask>{};
      final newlyCompleted = after.values.any((task) =>
          task.status == DownloadStatus.completed &&
          before[task.id]?.status != DownloadStatus.completed);
      if (newlyCompleted) {
        ref.invalidate(myLibraryProvider);
        ref.invalidate(completedDownloadsProvider);
      }
    });

    // A hidden tab stays mounted, so it must not keep subscribing: every
    // download event would rebuild this whole page behind the user's back.
    final tabActive = TabVisibility.of(context);
    final summary = tabActive
        ? ref.watch(_activeSummaryProvider)
        : _ActiveSummary.empty;
    final completedAsync = tabActive
        ? ref.watch(completedDownloadsProvider)
        : const AsyncData<List<CompletedDownload>>([]);
    final completed = completedAsync.valueOrNull ?? const <CompletedDownload>[];

    final allCount =
        summary.activeCount + summary.failedCount + completed.length;

    Widget buildList(_DownloadFilter filter) {
      final includeActive = filter != _DownloadFilter.completed;
      final includeCompleted = filter != _DownloadFilter.active;
      final hasActive = includeActive && summary.activeCount > 0;
      final hasFailed = includeCompleted && summary.failedCount > 0;
      final hasCompleted = includeCompleted && completed.isNotEmpty;
      final hasContent = hasActive || hasFailed || hasCompleted;

      final showCompleted = hasCompleted;
      return CustomScrollView(
        key: PageStorageKey<_DownloadFilter>(filter),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (hasActive)
                    _ActiveSection(
                      speeds: _speeds,
                      verifyingTaskId: _verifyingTaskId,
                      onToggleAll: _toggleAll,
                      onVerify: _verifyTask,
                    ),
                  if (!hasActive) const SizedBox(height: 16),
                  if (!hasContent)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          l10n.downloadCenterNoTasks,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    if (hasFailed)
                      _FailedSection(
                        verifyingTaskId: _verifyingTaskId,
                        onVerify: _verifyTask,
                      ),
                    if (showCompleted && (hasActive || hasFailed))
                      const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
          if (showCompleted)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: _CompletedSliver(
                items: completed,
                onOpen: _openCompleted,
                onDetails: (item) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookPage(id: item.book.id),
                    ),
                  );
                },
                onShare: (item) async {
                  await shareBook(
                    item.book.title,
                    item.book.link,
                    item.book.thumbnail ?? '',
                    fileName: item.fileName,
                    format: item.book.format,
                  );
                },
                onShowInFolder: PlatformUtils.isDesktop
                    ? (item) => _showInFolder(item)
                    : null,
                onRemove: _removeRecord,
              ),
            ),
          if (showCompleted)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InlineHint(message: l10n.downloadCenterRemoveNote),
                    const SizedBox(height: 12),
                    _StorageSummary(completed: completed),
                  ],
                ),
              ),
            )
          else
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      );
    }

    return ContentWidth(
      maxWidth: 900,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: PageHeader(
              eyebrow: l10n.downloadEyebrow,
              title: l10n.downloadCenterTitle,
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
              action: IconButton(
                onPressed: _openStorageFolder,
                tooltip: l10n.downloadCenterShowInFolder,
                icon: const Icon(Icons.folder_outlined, size: 20),
                style: IconButton.styleFrom(
                  fixedSize: const Size(40, 40),
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                  backgroundColor: scheme.surface,
                  foregroundColor: scheme.onSurface,
                  side: BorderSide(color: scheme.outlineVariant),
                ),
              ),
            ),
          ),
          if (allCount > 0)
            PillTabs(
              controller: _filterController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              tabs: [
                Tab(text: '${l10n.downloadCenterAll} $allCount'),
                Tab(text: l10n.downloadCenterActive),
                Tab(text: l10n.downloadCenterCompleted),
              ],
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(myLibraryProvider);
                ref.invalidate(completedDownloadsProvider);
              },
              child: allCount == 0
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                      children: [
                        _EmptyState(
                          onSearch: () {
                            ref.read(selectedIndexProvider.notifier).state = 1;
                          },
                        ),
                      ],
                    )
                  : TabBarView(
                      controller: _filterController,
                      children: [
                        for (final filter in _DownloadFilter.values)
                          buildList(filter),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressHero extends StatelessWidget {
  const _ProgressHero({required this.task, required this.speed});

  final DownloadTask task;
  final double? speed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final progress = task.progress.clamp(0.0, 1.0);
    final percent = (progress * 100).round();
    final eta = speed != null && speed! > 0 && task.totalBytes > 0
        ? _etaText(l10n, task.totalBytes - task.downloadedBytes, speed!)
        : null;
    final stat = speed != null && speed! > 0
        ? '${_formatBytes(speed!.round())}/s${eta == null ? '' : ' · $eta'}'
        : _statusLabel(l10n, task.status);

    return _SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 7,
                      backgroundColor: scheme.surfaceContainer,
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$percent%',
                      style: SwissText.caption.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SwissText.label.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stat,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SwissText.micro.copyWith(
                      color: speed != null && speed! > 0
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: scheme.surfaceContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatBytes(task.downloadedBytes)} / ${_formatBytes(task.totalBytes)} · ${l10n.rangeResume}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SwissText.micro.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorageSummary extends StatelessWidget {
  const _StorageSummary({required this.completed});

  final List<CompletedDownload> completed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final month = completed.where((item) {
      final time = item.modifiedAt;
      return time != null && time.year == now.year && time.month == now.month;
    }).toList();
    final entries = month.isEmpty ? completed : month;
    final epubBytes = entries
        .where((item) => (item.book.format ?? '').toLowerCase() == 'epub')
        .fold<int>(0, (sum, item) => sum + (item.sizeBytes ?? 0));
    final pdfBytes = entries
        .where((item) => (item.book.format ?? '').toLowerCase() == 'pdf')
        .fold<int>(0, (sum, item) => sum + (item.sizeBytes ?? 0));
    final total = epubBytes + pdfBytes;

    return _SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.downloadCenterStorageSummary(
                      entries.length,
                      _formatBytes(total),
                    ),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 8,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (epubBytes > 0)
                      Expanded(
                        flex: math.max(epubBytes, 1),
                        child: ColoredBox(color: scheme.primary),
                      ),
                    if (pdfBytes > 0)
                      Expanded(
                        flex: math.max(pdfBytes, 1),
                        child: ColoredBox(color: scheme.tertiary),
                      ),
                    if (total == 0)
                      Expanded(
                        child: ColoredBox(
                          color: scheme.surfaceContainerHighest,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.downloadCenterStorageLegend(
                _formatBytes(epubBytes),
                _formatBytes(pdfBytes),
              ),
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.speed,
    required this.verifying,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
    required this.onRetry,
    required this.onVerify,
  });

  final DownloadTask task;
  final double? speed;
  final bool verifying;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback onCancel;
  final VoidCallback onRetry;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final statusColor = _statusColor(scheme, task.status);
    final source = _sourceLabel(task);
    final size = task.totalBytes > 0 ? _formatBytes(task.totalBytes) : '';
    final meta = [
      if ((task.author ?? '').isNotEmpty) task.author!,
      if (task.format.isNotEmpty) task.format.toUpperCase(),
      if (size.isNotEmpty) size,
    ].join(' · ');
    final percent = (task.progress.clamp(0.0, 1.0) * 100).round();
    final isPaused = task.status == DownloadStatus.paused;
    final isDownloading = task.status == DownloadStatus.downloading;
    final isFailed = task.status == DownloadStatus.failed;
    final isVerifying = task.status == DownloadStatus.verifying;
    final isQueued = task.status == DownloadStatus.queued ||
        task.status == DownloadStatus.fetchingMirrors ||
        task.status == DownloadStatus.downloadingMirrors;
    final eta = speed != null && speed! > 0 && task.totalBytes > 0
        ? _etaText(
            l10n,
            task.totalBytes - task.downloadedBytes,
            speed!,
          )
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _SurfaceCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DownloadCover(
                    title: task.title,
                    thumbnail: task.thumbnail,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: SwissText.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meta,
                          style: SwissText.micro.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        _StatusPill(
                          label: isDownloading || isPaused
                              ? '$percent%'
                              : _statusLabel(l10n, task.status),
                          color: statusColor,
                          dot: isDownloading || isQueued,
                          icon: isFailed ? Icons.error_outline_rounded : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isDownloading || isPaused) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      '${_formatBytes(task.downloadedBytes)} / ${_formatBytes(task.totalBytes)}',
                      style: SwissText.micro.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    if (isDownloading && speed != null && speed! > 0)
                      Text(
                        [
                          '${_formatBytes(speed!.round())}/s',
                          if (eta != null) eta,
                        ].join(' · '),
                        style: SwissText.micro.copyWith(
                          color: scheme.primary,
                        ),
                      )
                    else if (isPaused)
                      Text(
                        l10n.downloadPaused,
                        style: SwissText.micro.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: task.progress,
                    minHeight: 4,
                  ),
                ),
              ] else if (isVerifying) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: const LinearProgressIndicator(minHeight: 4),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.downloadVerifying,
                  style: SwissText.micro.copyWith(color: scheme.secondary),
                ),
              ] else if (isQueued) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: const LinearProgressIndicator(minHeight: 4),
                ),
                const SizedBox(height: 8),
                Text(
                  _statusLabel(l10n, task.status),
                  style: SwissText.micro.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ] else if (isFailed) ...[
                const SizedBox(height: 16),
                _ErrorBox(
                  text: _errorText(l10n, task.errorMessage),
                  manual: task.errorMessage
                          ?.contains('Manual verification required') ==
                      true,
                  verifying: verifying,
                  onVerify: onVerify,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.public,
                    size: 16,
                    color: scheme.outline,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      source ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SwissText.micro.copyWith(color: scheme.outline),
                    ),
                  ),
                  if (isDownloading || isQueued || isPaused) ...[
                    OutlinedButton.icon(
                      onPressed: isPaused ? onResume : onPause,
                      icon: Icon(
                        isPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        size: 16,
                      ),
                      label: Text(
                        isPaused ? l10n.resumeDownload : l10n.pauseDownload,
                      ),
                      style: _smallOutlinedActionStyle(context),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (isFailed) ...[
                    OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: Text(l10n.retry),
                      style: _smallOutlinedActionStyle(context),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (!isVerifying)
                    TextButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: Text(l10n.cancel),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: scheme.primary,
                        textStyle: SwissText.micro.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveSection extends ConsumerWidget {
  const _ActiveSection({
    required this.speeds,
    required this.verifyingTaskId,
    required this.onToggleAll,
    required this.onVerify,
  });

  final Map<String, double> speeds;
  final String? verifyingTaskId;
  final Future<void> Function(List<DownloadTask> tasks) onToggleAll;
  final Future<void> Function(DownloadTask task) onVerify;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = (ref.watch(activeDownloadsProvider).valueOrNull?.values ??
            const <DownloadTask>[])
        .where(_isActiveTask)
        .toList(growable: false);
    if (tasks.isEmpty) return const SizedBox.shrink();

    final selected = tasks.firstWhere(
      (task) => task.status == DownloadStatus.downloading,
      orElse: () => tasks.first,
    );
    final pausedCount =
        tasks.where((task) => task.status == DownloadStatus.paused).length;
    final canPause = tasks.any((task) =>
        task.status == DownloadStatus.downloading ||
        task.status == DownloadStatus.downloadingMirrors ||
        task.status == DownloadStatus.fetchingMirrors ||
        task.status == DownloadStatus.queued);
    final canResume = pausedCount > 0;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProgressHero(task: selected, speed: speeds[selected.id]),
        const SizedBox(height: 16),
        SectionHeader(
          title: l10n.downloadCenterInProgress,
          hint: l10n.downloadCenterQueueMemory,
          action: canPause || canResume
              ? TextButton.icon(
                  onPressed: () => onToggleAll(tasks),
                  icon: Icon(
                    canResume && !canPause
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    size: 16,
                  ),
                  label: Text(
                    canResume && !canPause
                        ? l10n.downloadCenterAllResume
                        : l10n.downloadCenterAllPause,
                  ),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: SwissText.micro,
                  ),
                )
              : null,
        ),
        for (final task in tasks)
          _TaskCard(
            task: task,
            speed: speeds[task.id],
            verifying: verifyingTaskId == task.id,
            onPause: () =>
                ref.read(downloadManagerProvider).pauseDownload(task.id),
            onResume: () =>
                ref.read(downloadManagerProvider).resumeDownload(task.id),
            onCancel: () =>
                ref.read(downloadManagerProvider).cancelDownload(task.id),
            onRetry: () => ref
                .read(downloadManagerProvider)
                .retryDownloadKeepingPartial(task.id),
            onVerify: () => onVerify(task),
          ),
      ],
    );
  }
}

class _FailedSection extends ConsumerWidget {
  const _FailedSection({
    required this.verifyingTaskId,
    required this.onVerify,
  });

  final String? verifyingTaskId;
  final Future<void> Function(DownloadTask task) onVerify;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final failed = (ref.watch(activeDownloadsProvider).valueOrNull?.values ??
            const <DownloadTask>[])
        .where((task) => task.status == DownloadStatus.failed)
        .toList(growable: false);
    if (failed.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l10n.downloadCenterFailed,
          hint: '${failed.length}',
        ),
        for (final task in failed)
          _TaskCard(
            task: task,
            speed: null,
            verifying: verifyingTaskId == task.id,
            onPause: null,
            onResume: null,
            onCancel: () =>
                ref.read(downloadManagerProvider).cancelDownload(task.id),
            onRetry: () => ref
                .read(downloadManagerProvider)
                .retryDownloadKeepingPartial(task.id),
            onVerify: () => onVerify(task),
          ),
      ],
    );
  }
}

class _DownloadCover extends StatelessWidget {
  const _DownloadCover({
    required this.title,
    required this.thumbnail,
  });

  final String title;
  final String? thumbnail;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final hasThumbnail = thumbnail != null && thumbnail!.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(SwissRadius.sm),
      child: SizedBox(
        key: const ValueKey('download-cover'),
        width: 64,
        height: 96,
        child: hasThumbnail
            ? CachedNetworkImage(
                imageUrl: thumbnail!,
                memCacheWidth: (64 * dpr).round(),
                fit: BoxFit.cover,
                placeholder: (context, url) => _CoverFallback(
                  title: title,
                  scheme: scheme,
                ),
                errorWidget: (context, url, error) => _CoverFallback(
                  title: title,
                  scheme: scheme,
                ),
              )
            : _CoverFallback(title: title, scheme: scheme),
      ),
    );
  }
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback({required this.title, required this.scheme});

  final String title;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final initial = title.trim().isEmpty ? '?' : title.trim()[0];
    return ColoredBox(
      color: scheme.surfaceContainerHigh,
      child: Center(
        child: Text(
          initial,
          style: SwissText.caption.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.dot = false,
    this.icon,
    this.minHeight = 24,
  });

  final String label;
  final Color color;
  final bool dot;
  final IconData? icon;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(SwissRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: SwissText.badge.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

ButtonStyle _smallOutlinedActionStyle(BuildContext context) {
  final theme = Theme.of(context);
  return OutlinedButton.styleFrom(
    minimumSize: const Size(0, 40),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    side: BorderSide(color: theme.colorScheme.outlineVariant),
    textStyle: SwissText.micro.copyWith(fontWeight: FontWeight.w700),
  );
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({
    required this.text,
    required this.manual,
    required this.verifying,
    required this.onVerify,
  });

  final String text;
  final bool manual;
  final bool verifying;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final background =
        manual ? scheme.tertiaryContainer : scheme.errorContainer;
    final foreground =
        manual ? scheme.onTertiaryContainer : scheme.onErrorContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            manual ? Icons.warning_amber_rounded : Icons.error_outline,
            size: 16,
            color: foreground,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.labelSmall?.copyWith(color: foreground),
            ),
          ),
          if (manual)
            TextButton(
              onPressed: verifying ? null : onVerify,
              style: TextButton.styleFrom(
                foregroundColor: foreground,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                minimumSize: const Size(40, 24),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: verifying
                  ? SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: foreground,
                      ),
                    )
                  : Text(l10n.verifyAction),
            ),
        ],
      ),
    );
  }
}

class _CompletedSliver extends StatelessWidget {
  const _CompletedSliver({
    required this.items,
    required this.onOpen,
    required this.onDetails,
    required this.onShare,
    required this.onShowInFolder,
    required this.onRemove,
  });

  final List<CompletedDownload> items;
  final Future<void> Function(MyBook) onOpen;
  final void Function(CompletedDownload) onDetails;
  final Future<void> Function(CompletedDownload) onShare;
  final Future<void> Function(CompletedDownload)? onShowInFolder;
  final Future<void> Function(CompletedDownload) onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedSliver(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      sliver: SliverList.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CompletedRow(
                item: item,
                onOpen: () => onOpen(item.book),
                onDetails: () => onDetails(item),
                onShare: () => onShare(item),
                onShowInFolder: onShowInFolder == null
                    ? null
                    : () => onShowInFolder!(item),
                onRemove: () => onRemove(item),
              ),
              if (index < items.length - 1)
                const Divider(indent: 16, endIndent: 16),
            ],
          );
        },
      ),
    );
  }
}

class _CompletedRow extends StatelessWidget {
  const _CompletedRow({
    required this.item,
    required this.onOpen,
    required this.onDetails,
    required this.onShare,
    required this.onShowInFolder,
    required this.onRemove,
  });

  final CompletedDownload item;
  final VoidCallback onOpen;
  final VoidCallback onDetails;
  final VoidCallback onShare;
  final VoidCallback? onShowInFolder;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final book = item.book;
    final meta = [
      if ((book.author ?? '').isNotEmpty) book.author!,
      if ((book.format ?? '').isNotEmpty) book.format!.toUpperCase(),
      if (item.sizeBytes != null) _formatBytes(item.sizeBytes!),
    ].where((value) => value.isNotEmpty).join(' · ');
    final date = _formatCompletedTime(context, item.modifiedAt);
    final source = sourceLabelForUrl(book.link, l10n);
    final footer = [
      if (date.isNotEmpty) date,
      if (source != null) source,
    ].join(' · ');

    return InkWell(
      // The row opens the book's detail page; the explicit "open" button
      // is the only path that hands the file to an external reader.
      onTap: onDetails,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DownloadCover(
                  title: book.title,
                  thumbnail: book.thumbnail,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: SwissText.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meta,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: SwissText.micro.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      if (footer.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          footer,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SwissText.micro.copyWith(
                            color: scheme.outline,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                // The completed state sits with the actions it describes,
                // and shares their height so the row reads as one line.
                _StatusPill(
                  key: const ValueKey('completed-status-pill'),
                  label: l10n.statusCompleted,
                  color: scheme.secondary,
                  icon: Icons.check_rounded,
                  minHeight: 36,
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  key: const ValueKey('completed-open-button'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle:
                        SwissText.badge.copyWith(fontWeight: FontWeight.w800),
                  ),
                  onPressed: onOpen,
                  child: Text(l10n.open),
                ),
                PopupMenuButton<_CompletedAction>(
                  tooltip: MaterialLocalizations.of(context).showMenuTooltip,
                  icon: const Icon(Icons.more_vert, size: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  onSelected: (action) {
                    switch (action) {
                      case _CompletedAction.details:
                        onDetails();
                        break;
                      case _CompletedAction.share:
                        onShare();
                        break;
                      case _CompletedAction.folder:
                        onShowInFolder?.call();
                        break;
                      case _CompletedAction.remove:
                        onRemove();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _CompletedAction.details,
                      child: Text(l10n.downloadCenterBookDetails),
                    ),
                    PopupMenuItem(
                      value: _CompletedAction.share,
                      child: Text(l10n.share),
                    ),
                    if (onShowInFolder != null)
                      PopupMenuItem(
                        value: _CompletedAction.folder,
                        child: Text(l10n.downloadCenterShowInFolder),
                      ),
                    PopupMenuItem(
                      value: _CompletedAction.remove,
                      child: Text(l10n.downloadCenterRemoveRecord),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        const SizedBox(height: 36),
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.download_for_offline_outlined,
            size: 52,
            color: scheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          l10n.downloadCenterEmptyTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.downloadCenterEmptyBody,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: onSearch,
          icon: const Icon(Icons.search),
          label: Text(l10n.downloadCenterGoSearch),
        ),
        const SizedBox(height: 22),
        _SurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 20,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.downloadCenterTip,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surface,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: child,
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes <= 0) return '0 B';
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  final decimals = value >= 100 || unit == 0 ? 0 : 1;
  return '${value.toStringAsFixed(decimals)} ${units[unit]}';
}

String? _etaText(AppLocalizations l10n, int remainingBytes, double speed) {
  if (remainingBytes <= 0 || speed <= 0) return null;
  final seconds = (remainingBytes / speed).ceil();
  if (seconds < 60) return l10n.downloadCenterEtaSeconds(seconds);
  return l10n.downloadCenterEtaMinutes((seconds / 60).ceil());
}

String _formatCompletedTime(BuildContext context, DateTime? time) {
  if (time == null) return '';
  final local = MaterialLocalizations.of(context);
  final now = DateTime.now();
  if (time.year == now.year && time.month == now.month && time.day == now.day) {
    return local.formatTimeOfDay(
      TimeOfDay.fromDateTime(time),
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );
  }
  return local.formatShortDate(time);
}

String _statusLabel(AppLocalizations l10n, DownloadStatus status) {
  return switch (status) {
    DownloadStatus.queued => l10n.downloadQueued,
    DownloadStatus.fetchingMirrors => l10n.downloadGettingMirrors,
    DownloadStatus.downloadingMirrors => l10n.downloadFindingMirror,
    DownloadStatus.downloading => l10n.downloadDownloading,
    DownloadStatus.paused => l10n.downloadPaused,
    DownloadStatus.verifying => l10n.downloadVerifying,
    DownloadStatus.completed => l10n.statusCompleted,
    DownloadStatus.failed => l10n.downloadFailedGeneric,
    DownloadStatus.cancelled => l10n.downloadCancelled,
  };
}

Color _statusColor(ColorScheme scheme, DownloadStatus status) {
  return switch (status) {
    DownloadStatus.queued => scheme.tertiary,
    DownloadStatus.fetchingMirrors ||
    DownloadStatus.downloadingMirrors ||
    DownloadStatus.downloading =>
      scheme.primary,
    DownloadStatus.paused => scheme.tertiary,
    DownloadStatus.verifying => scheme.secondary,
    DownloadStatus.completed => scheme.primary,
    DownloadStatus.failed => scheme.error,
    DownloadStatus.cancelled => scheme.outline,
  };
}

String? _sourceLabel(DownloadTask task) {
  final url = task.mirrors.isNotEmpty ? task.mirrors.first : task.mirrorUrl;
  if (url == null || url.isEmpty) return null;
  return mirrorSourceLabel(url);
}

String _errorText(AppLocalizations l10n, String? message) {
  if (message == null || message.isEmpty) return l10n.downloadFailedGeneric;
  if (message.contains('Manual verification required')) {
    return l10n.manualVerificationRequired;
  }
  const savePrefix = 'Could not save to library:';
  if (message.startsWith(savePrefix)) {
    return l10n
        .downloadCouldNotSave(message.substring(savePrefix.length).trim());
  }
  return switch (message) {
    'No mirrors available!' ||
    'No working mirrors available!' =>
      l10n.noMirrorsAvailable,
    'Error getting mirrors' => l10n.downloadErrorGettingMirrors,
    'All mirrors failed!' => l10n.downloadAllMirrorsFailed,
    _ => message,
  };
}
