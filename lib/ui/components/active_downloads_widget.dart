// Flutter imports:
import 'package:flutter/material.dart';
import 'package:openlib/l10n/app_localizations.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:openlib/data/services/download_manager.dart';
import 'package:openlib/state/state.dart';
import 'package:openlib/ui/webview_page.dart';

class ActiveDownloadsWidget extends ConsumerWidget {
  const ActiveDownloadsWidget({super.key});

  String _bytesToFileSize(int bytes) {
    const int decimals = 1;
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    if (bytes == 0) return '0${suffixes[0]}';
    var i = 0;
    var size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(decimals)}${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadsAsync = ref.watch(activeDownloadsProvider);

    return downloadsAsync.when(
      data: (downloads) {
        if (downloads.isEmpty) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        // Progress ticks arrive at 10 Hz; keep that repaint off the page layer.
        return RepaintBoundary(
          child: Card(
            margin: const EdgeInsets.only(bottom: 8),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.download_rounded,
                        size: 20,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context).downloadsTitle,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${downloads.length}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                SizedBox(
                  height: downloads.length > 2 ? 220 : null,
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    physics: downloads.length > 2
                        ? const AlwaysScrollableScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    itemCount: downloads.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (context, index) {
                      final task = downloads.values.elementAt(index);
                      return _DownloadItem(
                        task: task,
                        bytesToFileSize: _bytesToFileSize,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _DownloadItem extends ConsumerStatefulWidget {
  final DownloadTask task;
  final String Function(int) bytesToFileSize;

  const _DownloadItem({
    required this.task,
    required this.bytesToFileSize,
  });

  @override
  ConsumerState<_DownloadItem> createState() => _DownloadItemState();
}

class _DownloadItemState extends ConsumerState<_DownloadItem> {
  // Track if auto-verification has been triggered
  bool _autoVerificationTriggered = false;
  bool _isVerifying = false;

  String _displayError(AppLocalizations l10n, String? message) {
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

  String _getStatusText(AppLocalizations l10n, DownloadStatus status) {
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

  /// Short source name for the mirror currently serving this download.
  String? get _activeMirrorLabel {
    final url = widget.task.mirrors.isNotEmpty
        ? widget.task.mirrors.first
        : widget.task.mirrorUrl;
    if (url == null || url.isEmpty) return null;
    return mirrorSourceLabel(url);
  }

  @override
  void initState() {
    super.initState();
    // Auto-trigger verification if manual verification is required
    _checkAndTriggerAutoVerification();
  }

  @override
  void didUpdateWidget(_DownloadItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check again if task status changed
    if (oldWidget.task.status != widget.task.status) {
      _checkAndTriggerAutoVerification();
    }
  }

  // Automatically trigger verification when manual verification is required
  void _checkAndTriggerAutoVerification() {
    if (_autoVerificationTriggered || _isVerifying) return;

    final task = widget.task;
    if (task.status == DownloadStatus.failed &&
        task.errorMessage?.contains('Manual verification required') == true &&
        task.mirrorUrl != null) {
      _autoVerificationTriggered = true;
      // Use post-frame callback to ensure context is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _triggerVerification();
        }
      });
    }
  }

  // Open webview for manual verification with visible countdown/CAPTCHA
  Future<void> _triggerVerification() async {
    final task = widget.task;
    if (task.mirrorUrl == null || _isVerifying) return;

    if (mounted) {
      setState(() {
        _isVerifying = true;
      });
    }

    final downloadManager = ref.read(downloadManagerProvider);

    final List<String>? mirrors = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => Webview(
          url: task.mirrorUrl!,
          showOverlay: false, // Show full page for CAPTCHA interaction
        ),
      ),
    );

    if (mirrors != null && mirrors.isNotEmpty && mounted) {
      await downloadManager.restartDownloadWithMirrors(task.id, mirrors);
    }

    if (mounted) {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final downloadManager = ref.read(downloadManagerProvider);
    final task = widget.task;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Status icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getStatusColor(task.status, context)
                      .withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _buildStatusIcon(task.status, context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _getStatusText(l10n, task.status),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getStatusColor(task.status, context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_activeMirrorLabel != null) ...[
                          Text(
                            '  ·  ',
                            style: theme.textTheme.labelSmall,
                          ),
                          Flexible(
                            child: Text(
                              _activeMirrorLabel!,
                              style: theme.textTheme.labelSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        if (task.author != null && task.author!.isNotEmpty) ...[
                          Text(
                            '  ·  ',
                            style: theme.textTheme.labelSmall,
                          ),
                          Flexible(
                            child: Text(
                              task.author!,
                              style: theme.textTheme.labelSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (task.status == DownloadStatus.downloading ||
                  task.status == DownloadStatus.downloadingMirrors ||
                  task.status == DownloadStatus.fetchingMirrors ||
                  task.status == DownloadStatus.queued) ...[
                IconButton(
                  icon: Icon(
                    Icons.pause_rounded,
                    size: 20,
                    color: scheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    downloadManager.pauseDownload(task.id);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: AppLocalizations.of(context).pauseDownload,
                ),
                const SizedBox(width: 8),
              ],
              if (task.status == DownloadStatus.paused) ...[
                IconButton(
                  icon: Icon(
                    Icons.play_arrow_rounded,
                    size: 20,
                    color: scheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    downloadManager.resumeDownload(task.id);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: AppLocalizations.of(context).resumeDownload,
                ),
                const SizedBox(width: 8),
              ],
              if (task.status != DownloadStatus.completed &&
                  task.status != DownloadStatus.failed)
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: scheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    downloadManager.cancelDownload(task.id);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: AppLocalizations.of(context).cancelDownload,
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (task.status == DownloadStatus.downloading ||
              task.status == DownloadStatus.paused) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: task.progress,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(task.progress * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${widget.bytesToFileSize(task.downloadedBytes)} / ${widget.bytesToFileSize(task.totalBytes)}',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ] else if (task.status == DownloadStatus.downloadingMirrors ||
              task.status == DownloadStatus.fetchingMirrors ||
              task.status == DownloadStatus.queued ||
              task.status == DownloadStatus.verifying) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(minHeight: 6),
            ),
          ] else if (task.status == DownloadStatus.failed) ...[
            if (task.errorMessage?.contains('Manual verification required') ==
                true) ...[
              // Show "Verify" button for manual verification required error
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: scheme.onTertiaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.manualVerificationRequired,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _isVerifying ? null : _triggerVerification,
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.onTertiaryContainer,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        minimumSize: const Size(40, 24),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: _isVerifying
                          ? SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: scheme.onTertiaryContainer,
                              ),
                            )
                          : Text(l10n.verifyAction),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Show regular error for other failures
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 16,
                      color: scheme.onErrorContainer,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _displayError(l10n, task.errorMessage),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onErrorContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        downloadManager.retryDownload(task.id);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.onErrorContainer,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon(DownloadStatus status, BuildContext context) {
    switch (status) {
      case DownloadStatus.queued:
        return Icon(
          Icons.schedule_rounded,
          size: 18,
          color: _getStatusColor(status, context),
        );
      case DownloadStatus.fetchingMirrors:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: _getStatusColor(status, context),
          ),
        );
      case DownloadStatus.downloadingMirrors:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: _getStatusColor(status, context),
          ),
        );
      case DownloadStatus.downloading:
        return Icon(
          Icons.arrow_downward_rounded,
          size: 18,
          color: _getStatusColor(status, context),
        );
      case DownloadStatus.paused:
        return Icon(
          Icons.pause_rounded,
          size: 18,
          color: _getStatusColor(status, context),
        );
      case DownloadStatus.verifying:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: _getStatusColor(status, context),
          ),
        );
      case DownloadStatus.completed:
        return Icon(
          Icons.check_circle_rounded,
          size: 18,
          color: _getStatusColor(status, context),
        );
      case DownloadStatus.failed:
        return Icon(
          Icons.error_rounded,
          size: 18,
          color: _getStatusColor(status, context),
        );
      case DownloadStatus.cancelled:
        return Icon(
          Icons.cancel_rounded,
          size: 18,
          color: _getStatusColor(status, context),
        );
    }
  }

  Color _getStatusColor(DownloadStatus status, BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (status) {
      case DownloadStatus.queued:
        return scheme.tertiary;
      case DownloadStatus.fetchingMirrors:
      case DownloadStatus.downloadingMirrors:
      case DownloadStatus.downloading:
        return scheme.primary;
      case DownloadStatus.paused:
        return scheme.tertiary;
      case DownloadStatus.verifying:
        return scheme.secondary;
      case DownloadStatus.completed:
        return scheme.primary;
      case DownloadStatus.failed:
        return scheme.error;
      case DownloadStatus.cancelled:
        return scheme.outline;
    }
  }
}
