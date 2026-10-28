// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:openlib/l10n/app_localizations.dart';

// Project imports:
import 'package:openlib/data/models/book_data.dart';
import 'package:openlib/data/services/share_book.dart';
import 'package:openlib/ui/core/components/book_info_widget.dart';
import 'package:openlib/ui/features/book_detail/view_models/book_detail_view_model.dart';
import 'package:openlib/ui/features/shell/widgets/content_width.dart';
import 'package:openlib/ui/core/components/detail_bottom_bar.dart';
import 'package:openlib/ui/core/components/error_widget.dart';
import 'package:openlib/ui/core/components/file_buttons_widget.dart';
import 'package:openlib/ui/core/components/share_icon.dart';
import 'package:openlib/ui/core/components/snack_bar_widget.dart';
import 'package:openlib/ui/core/swiss_grid.dart';
import 'package:openlib/ui/features/webview/views/webview_page.dart';

class BookInfoPage extends StatefulWidget {
  const BookInfoPage({
    super.key,
    required this.url,
    this.source,
    this.preview,
    this.viewModel,
  });

  final String url;
  final String? source;

  /// What the results row already knew. The page paints from it while
  /// the detail page is fetched, so a tap never lands on a blank spinner
  /// for the seconds a mirror takes.
  final BookData? preview;

  /// Tests inject their own instance; the app builds one from DI.
  final BookDetailViewModel? viewModel;

  @override
  State<BookInfoPage> createState() => _BookInfoPageState();
}

class _BookInfoPageState extends State<BookInfoPage> {
  late final BookDetailViewModel _vm;
  late final bool _ownsVm;

  @override
  void initState() {
    super.initState();
    _vm = widget.viewModel ??
        BookDetailViewModel.fromDi(
          url: widget.url,
          source: widget.source,
          preview: widget.preview,
        );
    _ownsVm = widget.viewModel == null;
    unawaited(_vm.load());
  }

  @override
  void dispose() {
    if (_ownsVm) _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        final book = _vm.book;

        if (book == null) {
          if (_vm.hasError) {
            return Scaffold(
              appBar: AppBar(title: Text(l10n.bookDetailsTitle)),
              body: ContentWidth(
                maxWidth: 840,
                child: CustomErrorWidget(
                  error: _vm.error!,
                  stackTrace: _vm.errorStackTrace ?? StackTrace.empty,
                  contextLabel: l10n.bookDetailsTitle,
                  contextDetails: 'url=${widget.url}',
                  onRefresh: _vm.retry,
                ),
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(title: Text(l10n.bookDetailsTitle)),
            body: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final loading = _vm.loading;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.bookDetailsTitle),
            actions: [
              IconButton(
                icon: ShareIcon(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onPressed: () async {
                  final outcome = await shareBook(
                      book.title, book.link, book.thumbnail ?? '',
                      format: book.format,
                      message: l10n.shareBookMessage(book.title, book.link));
                  if (context.mounted && outcome == ShareOutcome.pathCopied) {
                    showSnackBar(
                        context: context, message: l10n.copiedBookLink);
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              if (_vm.hasError)
                _DetailErrorStrip(
                  onRetry: _vm.retry,
                ),
              if (loading) const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: ContentWidth(
                  maxWidth: 840,
                  child: BookInfoWidget(
                    data: book,
                    source: widget.source,
                    loading: loading,
                    annaArchiveBaseUrl: _vm.annaArchiveBaseUrl,
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _vm.details != null
              ? _DetailActionBar(viewModel: _vm)
              : const _DetailLoadingBar(),
        );
      },
    );
  }
}

class _DetailErrorStrip extends StatelessWidget {
  const _DetailErrorStrip({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: scheme.errorContainer,
      padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 16,
            color: scheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.networkErrorBookDetailsUnavailableTitle,
              style: SwissText.micro.copyWith(color: scheme.onErrorContainer),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: scheme.onErrorContainer,
            ),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}

class _DetailLoadingBar extends StatelessWidget {
  const _DetailLoadingBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DetailBottomBar(
      children: [
        Expanded(
          child: FilledButton.icon(
            key: const ValueKey('detail-loading-download'),
            onPressed: null,
            icon: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            label: Text(l10n.downloadThisBook),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              textStyle: SwissText.label.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailActionBar extends StatelessWidget {
  const _DetailActionBar({required this.viewModel});

  final BookDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final details = viewModel.details!;
    final inLibrary = viewModel.inLibrary;

    // Membership is still loading (or the lookup failed): the old card
    // rendered nothing in both cases.
    if (inLibrary == null) return const SizedBox.shrink();

    if (inLibrary) {
      return FileOpenAndDeleteButtons(
        id: details.md5,
        format: details.format!,
        fileName: viewModel.libraryBook?.fileName,
        onDeleteFile: viewModel.deleteFile,
      );
    }

    return DetailBottomBar(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _startDownload(context),
            icon: const Icon(Icons.download_rounded),
            label: Text(l10n.downloadThisBook),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              textStyle: SwissText.label.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        // Button for "Manual Download" (opens webview for captcha) - only
        // shown if the setting is enabled.
        if (viewModel.showManualButton) ...[
          const SizedBox(width: 8),
          IconButton.outlined(
            tooltip: l10n.manualDownloadAction,
            style: IconButton.styleFrom(
              fixedSize: const Size(48, 48),
              side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant),
              shape: const CircleBorder(),
            ),
            onPressed: () => _startManualDownload(context),
            icon: const Icon(Icons.open_in_browser_outlined),
          ),
        ],
      ],
    );
  }

  Future<void> _startDownload(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final plan = await viewModel.startDownload();
    if (!context.mounted) return;
    switch (plan) {
      case DownloadStarted(:final fast):
        showSnackBar(
          context: context,
          message:
              fast ? l10n.fastDownloadStarted : l10n.downloadStartedBackground,
        );
      case DownloadNeedsMirrors(:final url):
        final mirrors = await _collectMirrors(context, url);
        if (mirrors == null || mirrors.isEmpty || !context.mounted) return;
        final started = await viewModel.startWithMirrors(url, mirrors);
        if (started && context.mounted) {
          showSnackBar(
            context: context,
            message: l10n.downloadStartedBackground,
          );
        }
      case DownloadRefused(:final refusal):
        showSnackBar(
          context: context,
          message: _refusalMessage(l10n, refusal),
        );
    }
  }

  Future<void> _startManualDownload(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final plan = await viewModel.manualDownload();
    if (!context.mounted) return;
    switch (plan) {
      case DownloadNeedsMirrors(:final url):
        final mirrors = await _collectMirrors(context, url);
        if (mirrors == null || mirrors.isEmpty || !context.mounted) return;
        final started = await viewModel.startWithMirrors(url, mirrors);
        if (started && context.mounted) {
          showSnackBar(
            context: context,
            message: l10n.downloadStartedBackground,
          );
        }
      case DownloadRefused():
        showSnackBar(context: context, message: l10n.noMirrors);
      case DownloadStarted():
        break;
    }
  }

  Future<List<String>?> _collectMirrors(BuildContext context, String url) {
    return Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => Webview(url: url),
      ),
    );
  }

  /// A mirror's own reason beats the generic "no mirrors"; the two WeLib
  /// codes stand in for strings the view model cannot localize.
  String _refusalMessage(AppLocalizations l10n, String? refusal) {
    if (refusal == null) return l10n.noMirrors;
    if (refusal == BookDetailViewModel.welibNoDownloadLinkRefusal) {
      return l10n.welibNoDownloadLink;
    }
    if (refusal == BookDetailViewModel.welibPageUnreadableRefusal) {
      return l10n.welibPageUnreadable;
    }
    return refusal;
  }
}
