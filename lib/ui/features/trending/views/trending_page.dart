// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/data/models/trending_book_data.dart'
    show TrendingBookData;
import 'package:openlib/state/state.dart'
    show getTrendingBooks, appSettingsProvider;
import 'package:openlib/ui/features/trending/views/categories_page.dart'
    show GenreShortcutSection;
import 'package:openlib/ui/core/components/error_widget.dart';
import 'package:openlib/ui/core/components/section_header.dart';
import 'package:openlib/ui/features/results/views/results_page.dart';
import 'package:openlib/ui/core/swiss_grid.dart';

class TrendingPage extends ConsumerWidget {
  const TrendingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final trendingBooks = ref.watch(getTrendingBooks);
    final labelHeight = MediaQuery.textScalerOf(context).scale(32);

    return trendingBooks.when(
      skipLoadingOnRefresh: false,
      data: (data) {
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              sliver: SliverToBoxAdapter(
                child: SectionHeader(
                  title: l10n.trendingThisWeek,
                  hint: l10n.trendingSource,
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                key: const ValueKey('trending-strip'),
                height: 200 + labelHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: data.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final book = data[index];
                    return _TrendingBookCard(
                      book: book,
                      onTap: () {
                        ref
                            .read(appSettingsProvider)
                            .setFiltersEnabled(false);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ResultPage(searchQuery: book.title!),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: GenreShortcutSection(title: l10n.keepExploring),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        );
      },
      error: (error, stackTrace) {
        return CustomErrorWidget(
          error: error,
          stackTrace: stackTrace,
          contextLabel: l10n.trending,
          onRefresh: () {
            // ignore: unused_result
            ref.refresh(getTrendingBooks);
          },
        );
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _TrendingBookCard extends StatelessWidget {
  const _TrendingBookCard({required this.book, required this.onTap});

  final TrendingBookData book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dpr = MediaQuery.devicePixelRatioOf(context);

    return SizedBox(
      key: const ValueKey('trending-poster'),
      width: 128,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SwissRadius.field),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SwissRadius.field),
                boxShadow: [
                  BoxShadow(
                    color: scheme.shadow.withValues(alpha: 0.09),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(SwissRadius.field),
                child: AspectRatio(
                  key: const ValueKey('trending-cover'),
                  aspectRatio: 2 / 3,
                  child: CachedNetworkImage(
                    imageUrl: book.thumbnail ?? '',
                    memCacheWidth: (128 * dpr).round(),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => ColoredBox(
                      color: scheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.menu_book_outlined,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    errorWidget: (context, url, error) => ColoredBox(
                      color: scheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.title ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: SwissText.micro.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
