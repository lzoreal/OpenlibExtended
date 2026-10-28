// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/data/models/trending_book_data.dart'
    show TrendingBookData;
import 'package:openlib/ui/features/trending/view_models/trending_view_model.dart';
import 'package:openlib/ui/features/trending/views/categories_page.dart'
    show GenreShortcutSection;
import 'package:openlib/ui/core/components/error_widget.dart';
import 'package:openlib/ui/core/components/section_header.dart';
import 'package:openlib/ui/features/results/views/results_page.dart';
import 'package:openlib/ui/core/swiss_grid.dart';

class TrendingPage extends StatefulWidget {
  const TrendingPage({super.key, this.viewModel});

  /// Injected by tests; the page builds its own view model otherwise.
  final TrendingViewModel? viewModel;

  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  late final TrendingViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? TrendingViewModel.fromDi();
    unawaited(_viewModel.load());
  }

  @override
  void dispose() {
    if (_ownsViewModel) _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labelHeight = MediaQuery.textScalerOf(context).scale(32);

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        if (_viewModel.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final error = _viewModel.error;
        if (error != null) {
          return CustomErrorWidget(
            error: error,
            stackTrace: _viewModel.errorStackTrace ?? StackTrace.empty,
            contextLabel: l10n.trending,
            onRefresh: _viewModel.refresh,
          );
        }
        final data = _viewModel.books;
        return RefreshIndicator(
          onRefresh: _viewModel.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                          _viewModel.prepareOpen(filtersEnabled: false);
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
          ),
        );
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
