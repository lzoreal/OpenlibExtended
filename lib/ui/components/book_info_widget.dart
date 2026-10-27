// Flutter imports:
import 'package:flutter/material.dart';
import 'package:openlib/l10n/app_localizations.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:openlib/state/state.dart' show annaArchiveBaseUrlProvider;
import 'package:openlib/ui/components/book_card_widget.dart'
    show getFileType, getLanguage;
import 'package:openlib/ui/swiss_grid.dart';

/// The URL the "open in site" button opens for a book.
///
/// A real md5 (32 hex) means Anna's Archive carries the book under that
/// id, so the button opens the AA page. Z-Library results carry a short
/// book id, not an md5, and have no Anna's Archive page - pointing at AA
/// for them lands on the error the user sees as "link expired". Those
/// open their own source page instead. Null (a disabled button) only when
/// neither target is available.
@visibleForTesting
String? openInSiteUrl({
  required String link,
  required String md5,
  String? annaArchiveBaseUrl,
}) {
  final hasMd5 = RegExp(r'^[0-9a-f]{32}$', caseSensitive: false).hasMatch(md5);
  if (hasMd5 && annaArchiveBaseUrl != null && annaArchiveBaseUrl.isNotEmpty) {
    return '$annaArchiveBaseUrl/md5/$md5';
  }
  return link.isEmpty ? null : link;
}

String? _isbnFromInfo(String info) {
  final labelled = RegExp(
    r'ISBN(?:-1[03])?\s*:?\s*([0-9][0-9Xx -]{8,16}[0-9Xx])',
    caseSensitive: false,
  ).firstMatch(info)?.group(1);
  final candidate =
      labelled ?? RegExp(r'\b97[89][0-9]{10}\b').firstMatch(info)?.group(0);
  if (candidate == null) return null;
  final normalized =
      candidate.replaceAll(RegExp(r'[^0-9Xx]'), '').toUpperCase();
  if (normalized.length == 10 || normalized.length == 13) return normalized;
  return null;
}

/// Best-effort source label for a stored book whose search-result tag was
/// never persisted.
String? sourceLabelForUrl(String? url, AppLocalizations l10n) {
  if (url == null || url.isEmpty) return null;
  final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';
  if (host.contains('welib')) return 'WeLib';
  if (url.contains('ads.php?md5=') ||
      host.contains('libgen') ||
      host.contains('lgli')) {
    return l10n.sourceLibgen;
  }
  if (url.contains('/book/') ||
      host.contains('z-lib') ||
      host.contains('zlibrary') ||
      host.contains('1lib') ||
      host.contains('artificial')) {
    return l10n.sourceZlib;
  }
  if (host.contains('annas-archive')) return l10n.sourceAnnas;
  return host.isEmpty ? null : host;
}

class BookInfoWidget extends ConsumerWidget {
  final dynamic data;
  final String? source;

  const BookInfoWidget({super.key, required this.data, this.source});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final aaBaseUrl = ref.watch(annaArchiveBaseUrlProvider).valueOrNull;
    final link = (data.link ?? '').toString();
    final sourceName = (source?.trim().isNotEmpty ?? false)
        ? source!
        : sourceLabelForUrl(link, l10n);
    final opensAtSource = sourceName != null &&
        sourceName != l10n.sourceAnnas &&
        !sourceName.toLowerCase().contains('anna');
    final siteUrl = opensAtSource
        ? (link.isEmpty ? null : link)
        : openInSiteUrl(
            link: link,
            md5: (data.md5 ?? '').toString(),
            annaArchiveBaseUrl: aaBaseUrl,
          );
    final thumbnail = (data.thumbnail ?? '').toString();
    final rawDescription = (data.description ?? '').toString().trim();
    final description = rawDescription.length < 3
        ? l10n.noDescriptionAvailable
        : rawDescription;
    final info = (data.info ?? '').toString();
    final isbn = _isbnFromInfo(info);
    final format =
        ((data.format ?? getFileType(info)) ?? '').toString().toUpperCase();
    final language = getLanguage(info) ?? '';
    final year = RegExp(r'\b(?:19|20)\d{2}\b')
            .firstMatch('$info ${data.publisher ?? ''}')
            ?.group(0) ??
        '';
    final fileSize =
        RegExp(r'\b\d+(?:\.\d+)?\s*(?:KB|MB|GB)\b', caseSensitive: false)
                .firstMatch(info)
                ?.group(0) ??
            '';
    final publisher = (data.publisher ?? '').toString().trim();
    final author = (data.author ?? '').toString().trim();
    final byline = [
      author.isEmpty ? l10n.unknown : author,
      if (publisher.isNotEmpty) publisher,
    ].join(' · ');

    Future<void> openSite() async {
      if (siteUrl == null) return;
      if (await canLaunchUrl(Uri.parse(siteUrl))) {
        await launchUrl(Uri.parse(siteUrl),
            mode: LaunchMode.externalApplication);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.couldNotOpenLink)),
        );
      }
    }

    return SelectionArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    key: const ValueKey('detail-cover'),
                    width: 128,
                    height: 192,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(SwissRadius.field),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.shadow.withValues(alpha: 0.15),
                          blurRadius: 32,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(SwissRadius.field),
                      child: CachedNetworkImage(
                        imageUrl: thumbnail,
                        fit: BoxFit.cover,
                        httpHeaders: thumbnail.contains('libgen')
                            ? <String, String>{'Referer': link}
                            : null,
                        placeholder: (context, url) => _DetailCoverFallback(
                          scheme: scheme,
                          title: data.title,
                        ),
                        errorWidget: (context, url, error) =>
                            _DetailCoverFallback(
                          scheme: scheme,
                          title: data.title,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.title,
                            key: const ValueKey('detail-title'),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: SwissText.subtitle.copyWith(
                              fontWeight: FontWeight.w800,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            byline,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: SwissText.caption.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              if (format.isNotEmpty)
                                _Stamp(label: format, accent: true),
                              if (language.isNotEmpty) _Stamp(label: language),
                              if (fileSize.isNotEmpty) _Stamp(label: fileSize),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CardHead(
                        icon: Icons.description_outlined,
                        title: l10n.fileInfoTitle,
                      ),
                      const SizedBox(height: 4),
                      if (isbn != null)
                        _InfoRow(
                          label: l10n.isbnLabel,
                          value: isbn,
                          first: true,
                        ),
                      _InfoRow(
                        label: l10n.languageSetting,
                        value: language.isEmpty ? '—' : language,
                        first: isbn == null,
                      ),
                      _InfoRow(
                        label: l10n.publishedYearLabel,
                        value: year.isEmpty ? '—' : year,
                      ),
                      _InfoRow(
                        label: l10n.fileSizeLabel,
                        value: fileSize.isEmpty ? '—' : fileSize,
                      ),
                      _InfoRow(
                        label: l10n.sourceLabel,
                        value: sourceName ?? '—',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CardHead(
                        icon: Icons.notes_rounded,
                        title: l10n.descriptionLabel,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: SwissText.caption.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(SwissRadius.card),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.sourceMirrorHint(sourceName ?? l10n.unknown),
                        style: SwissText.micro.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (siteUrl != null) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: openSite,
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          l10n.openAtSource,
                          style: SwissText.micro.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
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

class _Stamp extends StatelessWidget {
  const _Stamp({required this.label, this.accent = false});

  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      key: const ValueKey('detail-stamp'),
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: accent ? scheme.primaryContainer : scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(SwissRadius.pill),
      ),
      child: Align(
        alignment: Alignment.center,
        widthFactor: 1,
        child: Text(
          label,
          style: SwissText.micro.copyWith(
            color: accent ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _CardHead extends StatelessWidget {
  const _CardHead({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(SwissRadius.sm),
          ),
          child: Icon(icon, size: 16, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: SwissText.bodyStrong.copyWith(color: scheme.onSurface),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.first = false,
  });

  final String label;
  final String value;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: first
              ? BorderSide.none
              : BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: 0.55),
                ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: SwissText.micro.copyWith(color: scheme.outline),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: SwissText.caption.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCoverFallback extends StatelessWidget {
  const _DetailCoverFallback({required this.scheme, required this.title});

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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            title,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: SwissText.caption.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
