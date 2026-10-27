// Flutter imports:
import 'package:flutter/material.dart';
import 'package:openlib/l10n/app_localizations.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:openlib/services/annas_archieve.dart';
import 'package:openlib/services/download_target.dart';
import 'package:openlib/services/search_manager.dart';
import 'package:openlib/services/download_manager.dart';
import 'package:openlib/services/platform_utils.dart';
import 'package:openlib/services/share_book.dart';
import 'package:openlib/ui/components/book_info_widget.dart';
import 'package:openlib/ui/components/content_width.dart';
import 'package:openlib/ui/components/detail_bottom_bar.dart';
import 'package:openlib/ui/components/error_widget.dart';
import 'package:openlib/ui/components/file_buttons_widget.dart';
import 'package:openlib/ui/components/share_icon.dart';
import 'package:openlib/ui/components/snack_bar_widget.dart';
import 'package:openlib/ui/swiss_grid.dart';
import 'package:openlib/ui/webview_page.dart';
import 'package:openlib/state/state.dart'
    show
        bookInfoProvider,
        checkIdExists,
        getBookByIdProvider,
        myLibraryProvider,
        showManualDownloadButtonProvider,
        downloadManagerProvider,
        donationKeyProvider;

class BookInfoPage extends ConsumerWidget {
  const BookInfoPage({super.key, required this.url, this.source});

  final String url;
  final String? source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final bookInfo = ref.watch(bookInfoProvider(url));

    return bookInfo.when(
      skipLoadingOnRefresh: false,
      data: (data) {
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
                      data.title, data.link, data.thumbnail ?? '',
                      format: data.format,
                      message: l10n.shareBookMessage(data.title, data.link));
                  if (context.mounted && outcome == ShareOutcome.pathCopied) {
                    showSnackBar(
                        context: context, message: l10n.copiedBookLink);
                  }
                },
              ),
            ],
          ),
          body: ContentWidth(
            maxWidth: 840,
            child: BookInfoWidget(data: data, source: source),
          ),
          bottomNavigationBar: ActionButtonWidget(data: data),
        );
      },
      error: (err, _) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.bookDetailsTitle)),
          body: ContentWidth(
            maxWidth: 840,
            child: CustomErrorWidget(
              error: err,
              stackTrace: StackTrace.empty,
              onRefresh: () {
                ref.invalidate(bookInfoProvider(url));
              },
            ),
          ),
        );
      },
      loading: () {
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
      },
    );
  }
}

class ActionButtonWidget extends ConsumerStatefulWidget {
  const ActionButtonWidget({super.key, required this.data});
  final BookInfoData data;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ActionButtonWidgetState();
}

class _ActionButtonWidgetState extends ConsumerState<ActionButtonWidget> {
  @override
  Widget build(BuildContext context) {
    final isBookExist = ref.watch(checkIdExists(widget.data.md5));
    final bookData = ref.watch(getBookByIdProvider(widget.data.md5));

    return isBookExist.when(
      data: (isExists) {
        if (isExists) {
          // Get fileName from database for existing books
          final fileName = bookData.whenOrNull(data: (book) => book?.fileName);
          return FileOpenAndDeleteButtons(
            id: widget.data.md5,
            format: widget.data.format!,
            fileName: fileName,
            onDelete: () async {
              await Future.delayed(const Duration(seconds: 1));
              // ignore: unused_result
              ref.refresh(checkIdExists(widget.data.md5));
              // ignore: unused_result
              ref.refresh(getBookByIdProvider(widget.data.md5));
            },
          );
        } else {
          final showManualButton = ref.watch(showManualDownloadButtonProvider);

          return DetailBottomBar(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    final l10n = AppLocalizations.of(context);
                    String? downloadUrl = widget.data.mirror;
                    bool isFastDownload = widget.data.isFastDownload;

                    // Libgen serves its files directly (get.php -> CDN);
                    // no mirror scraping or donation key applies.
                    var isDirectLink = downloadUrl != null &&
                        downloadUrl.contains('/get.php?');
                    if (isDirectLink) {
                      isFastDownload = true;
                    }

                    // Z-Library /dl/ links sit behind a DiamWall
                    // proof-of-work and a 302 to a signed CDN URL, and
                    // some ids answer 204 forever; re-fetch the page for
                    // the live ids and resolve the first working one.
                    final isZlib =
                        downloadUrl != null && downloadUrl.contains('/dl/');
                    String? zlibRefusal;
                    if (isZlib && !isDirectLink) {
                      try {
                        final resolved = await ZlibraryProvider()
                            .resolveBookDownload(widget.data.link);
                        if (resolved.url != null) {
                          downloadUrl = resolved.url;
                          isDirectLink = true;
                          isFastDownload = true;
                        } else {
                          zlibRefusal = resolved.refusal;
                        }
                      } catch (e) {
                        // Fall through to the slow AA-style flow, which
                        // cannot work for zlib; the snackbar below fires.
                      }
                    }

                    // WeLib's public-server page carries the partner
                    // file link, but with the class on a <div> where the
                    // Anna's Archive scraper looks for a <p>. That is
                    // why the old path hung on "detecting the download
                    // link"; resolve it with WeLib's own parser instead.
                    final isWelib = isWelibUrl(downloadUrl);
                    // The signed file URL expires within hours, so keep
                    // the public-server page around: the download
                    // manager re-resolves a fresh URL from it when the
                    // stored one dies, exactly like z-lib's /dl/ hop.
                    final welibPageUrl = isWelib ? downloadUrl : null;
                    String? welibRefusal;
                    if (welibPageUrl != null && !isDirectLink) {
                      try {
                        final resolved =
                            await WelibProvider().resolveDownload(welibPageUrl);
                        if (resolved.url != null) {
                          downloadUrl = resolved.url;
                          isDirectLink = true;
                          isFastDownload = true;
                        } else {
                          welibRefusal =
                              resolved.refusal ?? l10n.welibNoDownloadLink;
                        }
                      } catch (e) {
                        welibRefusal = l10n.welibPageUnreadable;
                      }
                    }

                    // Try to fetch fast download link if key is present and not already fast
                    final donationKey =
                        isDirectLink ? '' : ref.read(donationKeyProvider);
                    var donationFastLink = false;
                    if (donationKey.isNotEmpty && !isFastDownload) {
                      try {
                        final annasArchive = AnnasArchieve();
                        final fastLink = await annasArchive.getFastDownloadUrl(
                            widget.data.md5, donationKey);
                        if (fastLink != null) {
                          downloadUrl = fastLink;
                          isFastDownload = true;
                          donationFastLink = true;
                        }
                      } catch (e) {
                        // Fallback to normal mirror
                      }
                    }

                    // Every route has run. A mirror that stated why it
                    // withheld the file ("daily limit reached", "sign in
                    // required") only wins when nothing else produced a
                    // link - starting a download against the refused /dl/
                    // hop could only fail, hiding that message.
                    final target = chooseDownloadTarget(
                      url: downloadUrl,
                      fast: isDirectLink || donationFastLink,
                      refusal: zlibRefusal ?? welibRefusal,
                    );
                    downloadUrl = target.url;

                    if (target.hasUrl) {
                      final effectiveUrl = downloadUrl!;
                      // On Linux, use WebView UI flow since headless webview is not supported
                      // Unless it is a fast download (isDirectLink), which doesn't need scraping
                      if (PlatformUtils.isLinux && !isFastDownload) {
                        // Navigate to webview page to get mirrors
                        if (!context.mounted) return;
                        final List<String>? mirrors = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                Webview(url: effectiveUrl),
                          ),
                        );

                        if (mirrors != null &&
                            mirrors.isNotEmpty &&
                            context.mounted) {
                          // Start download with fetched mirrors
                          final downloadManager =
                              ref.read(downloadManagerProvider);
                          final task = DownloadTask(
                            id: '${widget.data.md5}_${DateTime.now().millisecondsSinceEpoch}',
                            md5: widget.data.md5,
                            title: widget.data.title,
                            author: widget.data.author,
                            thumbnail: widget.data.thumbnail,
                            publisher: widget.data.publisher,
                            info: widget.data.info,
                            format: widget.data.format!,
                            description: widget.data.description,
                            link: widget.data.link,
                            mirrors: mirrors,
                          );

                          await downloadManager.addDownload(task);

                          if (context.mounted) {
                            final message = isFastDownload
                                ? l10n.fastDownloadStarted
                                : l10n.downloadStartedBackground;
                            showSnackBar(
                              context: context,
                              message: message,
                            );
                          }
                          ref.invalidate(myLibraryProvider);
                        }
                      } else {
                        // Other platforms (or fast download on Linux): use background fetch
                        final downloadManager =
                            ref.read(downloadManagerProvider);
                        final task = DownloadTask(
                          id: '${widget.data.md5}_${DateTime.now().millisecondsSinceEpoch}',
                          md5: widget.data.md5,
                          title: widget.data.title,
                          author: widget.data.author,
                          thumbnail: widget.data.thumbnail,
                          publisher: widget.data.publisher,
                          info: widget.data.info,
                          format: widget.data.format!,
                          description: widget.data.description,
                          link: widget.data.link,
                          mirrors: [], // Will be fetched in background
                          // Store mirror URL for retry
                          mirrorUrl: effectiveUrl,
                          isDirectLink: isFastDownload,
                          // z-lib's signed CDN link and WeLib's partner
                          // link both expire after a few hours; the
                          // manager then re-resolves a fresh one from
                          // the page instead of failing. The refresher
                          // takes the task's /md5/ link, but WeLib's
                          // file URL only comes out of the public-server
                          // page captured above, so that page is used.
                          linkRefresher: isZlib
                              ? (pageUrl) async => (await ZlibraryProvider()
                                      .resolveBookDownload(pageUrl))
                                  .url
                              : welibPageUrl != null
                                  ? (_) async => (await WelibProvider()
                                          .resolveDownload(welibPageUrl))
                                      .url
                                  : null,
                        );

                        await downloadManager.addDownloadWithMirrorUrl(
                          task,
                          effectiveUrl,
                        );

                        if (context.mounted) {
                          final message = isFastDownload
                              ? l10n.fastDownloadStarted
                              : l10n.downloadStartedBackground;
                          showSnackBar(
                            context: context,
                            message: message,
                          );
                          ref.invalidate(myLibraryProvider);
                        }
                      }
                    } else {
                      if (context.mounted) {
                        // A mirror's own reason (daily limit, sign-in
                        // required) beats the generic "no mirrors".
                        showSnackBar(
                            context: context,
                            message: target.refusal ??
                                AppLocalizations.of(context).noMirrors);
                      }
                    }
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: Text(AppLocalizations.of(context).downloadThisBook),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    textStyle:
                        SwissText.label.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              // Button for "Manual Download" (opens webview for captcha) - only shown if setting is enabled
              if (showManualButton) ...[
                const SizedBox(width: 8),
                IconButton.outlined(
                  tooltip: AppLocalizations.of(context).manualDownloadAction,
                  style: IconButton.styleFrom(
                    fixedSize: const Size(48, 48),
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant),
                    shape: const CircleBorder(),
                  ),
                  onPressed: () async {
                    if (widget.data.mirror != null &&
                        widget.data.mirror != '') {
                      // Navigate to webview page
                      final List<String>? mirrors = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              Webview(url: widget.data.mirror!),
                        ),
                      );

                      if (mirrors != null &&
                          mirrors.isNotEmpty &&
                          context.mounted) {
                        // Start download in background with fetched mirrors
                        final downloadManager =
                            ref.read(downloadManagerProvider);
                        final task = DownloadTask(
                          id: '${widget.data.md5}_${DateTime.now().millisecondsSinceEpoch}',
                          md5: widget.data.md5,
                          title: widget.data.title,
                          author: widget.data.author,
                          thumbnail: widget.data.thumbnail,
                          publisher: widget.data.publisher,
                          info: widget.data.info,
                          format: widget.data.format!,
                          description: widget.data.description,
                          link: widget.data.link,
                          mirrors: mirrors, // Use manually fetched mirrors
                        );

                        await downloadManager.addDownload(task);

                        if (context.mounted) {
                          showSnackBar(
                            context: context,
                            message: AppLocalizations.of(context)
                                .downloadStartedBackground,
                          );
                        }
                        ref.invalidate(myLibraryProvider);
                      }
                    } else {
                      showSnackBar(
                          context: context,
                          message: AppLocalizations.of(context).noMirrors);
                    }
                  },
                  icon: const Icon(Icons.open_in_browser_outlined),
                ),
              ],
            ],
          );
        }
      },
      error: (error, stackTrace) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}
