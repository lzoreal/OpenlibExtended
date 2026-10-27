// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:openlib/state/state.dart'
    show checkIdExists, languageCodeToDisplay, resultCoverProvider;

// Extract file type from book info string
String? getFileType(String? info) {
  if (info == null || info.isEmpty) return null;
  final infoLower = info.toLowerCase();
  if (infoLower.contains('pdf')) return "PDF";
  if (infoLower.contains('epub')) return "Epub";
  if (infoLower.contains('cbr')) return "Cbr";
  if (infoLower.contains('cbz')) return "Cbz";
  return null;
}

// Extract language code from book info string
// Info format typically: "[en], pdf, 5.2MB" or "English, pdf, 5.2MB"
String? getLanguage(String? info) {
  if (info == null || info.isEmpty) return null;

  // Try to match [xx] pattern for language code
  final bracketMatch =
      RegExp(r'\[([a-z]{2})\]', caseSensitive: false).firstMatch(info);
  if (bracketMatch != null) {
    final code = bracketMatch.group(1)?.toLowerCase();
    if (code != null && languageCodeToDisplay.containsKey(code)) {
      return languageCodeToDisplay[code];
    }
  }

  // Try to find language code at start of info (common format: "en, pdf, ...")
  final parts = info.split(',');
  if (parts.isNotEmpty) {
    final firstPart = parts[0].trim().toLowerCase();
    if (languageCodeToDisplay.containsKey(firstPart)) {
      return languageCodeToDisplay[firstPart];
    }
  }

  return null;
}

/// Same-host Referer for libgen cover URLs, null for everything else.
/// libgen mirrors serve /covers/ only with an ads.php Referer from the
/// same host; the host is read from the cover URL itself so the app
/// hardcodes no mirror address.
Map<String, String>? _coverHeaders(String? coverUrl) {
  if (coverUrl == null || !coverUrl.contains('libgen')) return null;
  final origin = Uri.tryParse(coverUrl)?.origin;
  if (origin == null) return null;
  return {'Referer': '$origin/ads.php?md5=cover-lookup'};
}

class BookInfoCard extends ConsumerWidget {
  const BookInfoCard({
    super.key,
    required this.title,
    required this.author,
    required this.publisher,
    required this.thumbnail,
    required this.info,
    required this.link,
    required this.onClick,
    this.onLongPress,
    this.md5,
    this.source,
  });

  final String title;
  final String author;
  final String publisher;
  final String? thumbnail;
  final String? info;
  final String link;
  final VoidCallback onClick;
  final VoidCallback? onLongPress;
  final String? md5;

  /// Catalog name this result came from; shown as a small chip.
  final String? source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fileType = getFileType(info);
    final language = getLanguage(info);

    // Check if book is downloaded (only if md5 is provided)
    final isDownloaded = md5 != null
        ? ref.watch(checkIdExists(md5!))
        : const AsyncValue<bool>.data(false);

    // LibGen search rows ship without covers; resolve one lazily from
    // the book's ads.php page (it carries the cover URL).
    final hasThumbnail = thumbnail != null && thumbnail!.isNotEmpty;
    final lazyCover =
        hasThumbnail ? null : ref.watch(resultCoverProvider(link)).valueOrNull;
    final coverUrl = hasThumbnail ? thumbnail : lazyCover;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onClick,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      height: 120,
                      width: 84,
                      fit: BoxFit.cover,
                      imageUrl: coverUrl ?? "",
                      // libgen mirrors serve /covers/ only with a
                      // same-host ads.php Referer; without it the
                      // response is 200 but empty. The host comes from
                      // the cover URL itself, so no mirror address is
                      // baked into the app.
                      httpHeaders: _coverHeaders(coverUrl),
                      placeholder: (context, url) => Container(
                        color: scheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.menu_book_outlined,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: scheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  if (isDownloaded.valueOrNull == true)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: scheme.surfaceContainerLow,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.check,
                          color: scheme.onPrimary,
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (publisher.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        publisher,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (source != null && source!.isNotEmpty)
                          _MetaBadge(
                            label: source!,
                            background: scheme.primaryContainer,
                            foreground: scheme.onPrimaryContainer,
                          ),
                        if (fileType != null)
                          _MetaBadge(
                            label: fileType,
                            background: scheme.secondaryContainer,
                            foreground: scheme.onSecondaryContainer,
                          ),
                        if (language != null)
                          _MetaBadge(
                            label: language,
                            background: scheme.tertiaryContainer,
                            foreground: scheme.onTertiaryContainer,
                          ),
                        Text(
                          author,
                          style: theme.textTheme.labelMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
              height: 1.455,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
