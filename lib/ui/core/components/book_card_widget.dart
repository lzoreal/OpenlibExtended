// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/data/services/book_format.dart';
import 'package:openlib/state/state.dart'
    show languageCodeToDisplay, languageValues;
import 'package:openlib/ui/core/components/language_names.dart';

/// Badge label for the format embedded in a result's info string.
String? getFileType(String? info) => bookFormatLabel(detectBookFormat(info));

/// Full language names as catalogs write them ("English", "Chinese")
/// mapped to the same uppercase codes [languageCodeToDisplay] uses.
final Map<String, String> _languageNameToDisplay = {
  for (final entry in languageValues.entries)
    if (entry.value.isNotEmpty)
      entry.key.toLowerCase(): entry.value.toUpperCase(),
};

String? _canonicalLanguage(String token) {
  final value = token.trim().toLowerCase();
  if (value.isEmpty) return null;
  return languageCodeToDisplay[value] ?? _languageNameToDisplay[value];
}

// Extract language code from book info string
// Info format typically: "[en], pdf, 5.2MB", "English, pdf, 5.2MB" or
// "English · EPUB · 2 MB" - catalogs disagree on both code and separator.
final _languageBracketPattern = RegExp(r'\[([a-z]{2})\]', caseSensitive: false);
final _languageSeparatorPattern = RegExp(r'[,·]');

String? getLanguage(String? info) {
  if (info == null || info.isEmpty) return null;

  // Try to match [xx] pattern for language code
  final bracketMatch = _languageBracketPattern.firstMatch(info);
  if (bracketMatch != null) {
    final byBracket = _canonicalLanguage(bracketMatch.group(1) ?? '');
    if (byBracket != null) return byBracket;
  }

  // Otherwise the language leads the info string.
  final firstPart = info.split(_languageSeparatorPattern).first;
  return _canonicalLanguage(firstPart);
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

class BookInfoCard extends StatefulWidget {
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
    this.downloaded = false,
    this.resolveCover,
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

  /// The book is already in the library.
  final bool downloaded;

  /// Lazily returns a cover address for rows without a thumbnail; null
  /// keeps the placeholder.
  final Future<String?> Function(String link)? resolveCover;

  @override
  State<BookInfoCard> createState() => _BookInfoCardState();
}

class _BookInfoCardState extends State<BookInfoCard> {
  String? _lazyCover;

  @override
  void initState() {
    super.initState();
    unawaited(_resolveLazyCover());
  }

  @override
  void didUpdateWidget(covariant BookInfoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.link != widget.link ||
        oldWidget.thumbnail != widget.thumbnail ||
        oldWidget.resolveCover != widget.resolveCover) {
      _lazyCover = null;
      unawaited(_resolveLazyCover());
    }
  }

  Future<void> _resolveLazyCover() async {
    // LibGen search rows ship without covers; resolve one lazily from
    // the book's ads.php page (it carries the cover URL).
    final hasThumbnail =
        widget.thumbnail != null && widget.thumbnail!.isNotEmpty;
    final resolver = widget.resolveCover;
    if (hasThumbnail || resolver == null) return;
    String? url;
    try {
      url = await resolver(widget.link);
    } catch (_) {
      url = null;
    }
    if (!mounted || url == null || url.isEmpty) return;
    setState(() => _lazyCover = url);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final l10n = AppLocalizations.of(context);
    final fileType = getFileType(widget.info);
    final language = getLanguage(widget.info);

    // Check if book is downloaded (only if md5 is provided)
    final isDownloaded = widget.downloaded && widget.md5 != null;

    final hasThumbnail =
        widget.thumbnail != null && widget.thumbnail!.isNotEmpty;
    final coverUrl = hasThumbnail ? widget.thumbnail : _lazyCover;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onClick,
        onLongPress: widget.onLongPress,
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
                      memCacheWidth: (84 * dpr).round(),
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
                  if (isDownloaded)
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
                      widget.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.publisher.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.publisher,
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
                        if (widget.source != null && widget.source!.isNotEmpty)
                          _MetaBadge(
                            label: widget.source!,
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
                            label: localizedLanguageName(l10n, language),
                            background: scheme.tertiaryContainer,
                            foreground: scheme.onTertiaryContainer,
                          ),
                        Text(
                          widget.author,
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
