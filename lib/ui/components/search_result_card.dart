// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/state/state.dart'
    show checkIdExists, resultCoverProvider;
import 'package:openlib/ui/components/book_card_widget.dart'
    show getFileType, getLanguage;
import 'package:openlib/ui/components/language_names.dart';
import 'package:openlib/ui/components/visible_builder.dart';
import 'package:openlib/ui/swiss_grid.dart';

/// Parses the size token out of the provider's comma-separated info line.
String? getFileSize(String? info) {
  if (info == null || info.isEmpty) return null;
  return RegExp(r'\b\d+(?:\.\d+)?\s*(?:KB|MB|GB)\b', caseSensitive: false)
      .firstMatch(info)
      ?.group(0);
}

Map<String, String>? _coverHeaders(String? coverUrl) {
  if (coverUrl == null || !coverUrl.contains('libgen')) return null;
  final origin = Uri.tryParse(coverUrl)?.origin;
  if (origin == null) return null;
  return {'Referer': '$origin/ads.php?md5=cover-lookup'};
}

/// Compact search result row used inside the results surface card.
class SearchResultCard extends ConsumerWidget {
  const SearchResultCard({
    super.key,
    required this.title,
    required this.author,
    required this.thumbnail,
    required this.info,
    required this.link,
    required this.onClick,
    this.md5,
    this.sourceLabel,
  });

  final String title;
  final String author;
  final String? thumbnail;
  final String? info;
  final String link;
  final VoidCallback onClick;
  final String? md5;
  final String? sourceLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final fileType = getFileType(info);
    final language = getLanguage(info);
    final fileSize = getFileSize(info);
    final isDownloaded = md5 != null
        ? ref.watch(checkIdExists(md5!))
        : const AsyncValue<bool>.data(false);

    final hasThumbnail = thumbnail != null && thumbnail!.isNotEmpty;

    return InkWell(
      onTap: onClick,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              key: const ValueKey('result-cover'),
              width: 56,
              height: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(SwissRadius.sm),
                child: VisibilityBuilder(
                  builder: (context, visible) {
                    if (!visible) {
                      return _CoverFallback(scheme: scheme, title: title);
                    }
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        if (hasThumbnail)
                          _CoverImage(
                            url: thumbnail!,
                            title: title,
                            scheme: scheme,
                          )
                        else
                          _LazyResultCover(
                            link: link,
                            title: title,
                            scheme: scheme,
                          ),
                        if (isDownloaded.valueOrNull == true)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: scheme.surface, width: 1),
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                size: 9,
                                color: scheme.onPrimary,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: SwissText.label.copyWith(color: scheme.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author.trim().isEmpty ? l10n.unknown : author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SwissText.micro.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (fileType != null)
                        _FormatBadge(label: fileType.toUpperCase()),
                      if (language != null)
                        _MetaText(localizedLanguageName(l10n, language)),
                      if (fileSize != null) ...[
                        const _Dot(),
                        _MetaText(fileSize),
                      ],
                      if (sourceLabel != null && sourceLabel!.isNotEmpty) ...[
                        const _Dot(),
                        _MetaText(sourceLabel!),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: scheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatBadge extends StatelessWidget {
  const _FormatBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (label) {
      'PDF' => (scheme.tertiaryContainer, scheme.tertiary),
      'EPUB' => (scheme.secondaryContainer, scheme.secondary),
      _ => (scheme.surfaceContainerHigh, scheme.onSurfaceVariant),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(SwissRadius.xs),
      ),
      child: Text(
        label,
        style: SwissText.badge.copyWith(
          color: foreground,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: SwissText.micro.copyWith(
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({
    required this.url,
    required this.title,
    required this.scheme,
  });

  final String url;
  final String title;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      httpHeaders: _coverHeaders(url),
      placeholder: (context, url) => _CoverFallback(
        scheme: scheme,
        title: title,
      ),
      errorWidget: (context, url, error) => _CoverFallback(
        scheme: scheme,
        title: title,
      ),
    );
  }
}

class _LazyResultCover extends ConsumerWidget {
  const _LazyResultCover({
    required this.link,
    required this.title,
    required this.scheme,
  });

  final String link;
  final String title;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ref.watch(resultCoverProvider(link)).valueOrNull;
    if (url == null || url.isEmpty) {
      return _CoverFallback(scheme: scheme, title: title);
    }
    return _CoverImage(url: url, title: title, scheme: scheme);
  }
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback({required this.scheme, required this.title});

  final ColorScheme scheme;
  final String title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer,
            scheme.surfaceContainerHighest,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -14,
            top: -12,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 7, 6, 18),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: SwissText.badge.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 5, 20),
              child: Icon(
                Icons.menu_book_outlined,
                size: 15,
                color: scheme.onPrimaryContainer.withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
