// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/ui/features/results/views/results_page.dart';
import 'package:openlib/ui/features/shell/widgets/content_width.dart';
import 'package:openlib/ui/core/components/error_widget.dart';
import 'package:openlib/ui/core/components/inline_hint.dart';
import 'package:openlib/ui/core/components/section_header.dart';
import 'package:openlib/ui/core/swiss_grid.dart';
import 'package:openlib/ui/features/trending/view_models/categories_view_model.dart';

class CategoryBook {
  final String title;
  final String thumbnail;
  final String tag;
  final String info;
  CategoryBook(
      {required this.title,
      required this.thumbnail,
      required this.tag,
      required this.info});
}

List<CategoryBook> categoriesTypeValues(AppLocalizations l10n) => [
      CategoryBook(
          info: l10n.categoryClassicsInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/1%20classic.jpeg",
          title: l10n.categoryClassicsTitle,
          tag: "list/tag/classics"),
      CategoryBook(
          info: l10n.categoryRomanceInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/2%20romance.jpeg",
          title: l10n.categoryRomanceTitle,
          tag: "list/tag/romance"),
      CategoryBook(
          info: l10n.categoryFictionInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/3%20fiction.jpeg",
          title: l10n.categoryFictionTitle,
          tag: "list/tag/fiction"),
      CategoryBook(
          info: l10n.categoryYoungAdultInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/4%20young%20adult.jpeg",
          title: l10n.categoryYoungAdultTitle,
          tag: "list/tag/young-adult"),
      CategoryBook(
          info: l10n.categoryFantasyInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/5%20fantasy%20book.jpeg",
          title: l10n.categoryFantasyTitle,
          tag: "list/tag/fantasy"),
      CategoryBook(
          info: l10n.categoryScienceFictionInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/6%20science%20fiction.jpeg",
          title: l10n.categoryScienceFictionTitle,
          tag: "list/tag/science-fiction"),
      CategoryBook(
          info: l10n.categoryNonfictionInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/7%20non%20fiction.jpeg",
          title: l10n.categoryNonfictionTitle,
          tag: "list/tag/non-fiction"),
      CategoryBook(
          info: l10n.categoryChildrenInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/8%20children.jpeg",
          title: l10n.categoryChildrenTitle,
          tag: "list/tag/children"),
      CategoryBook(
          info: l10n.categoryHistoryInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/9%20history.jpeg",
          title: l10n.categoryHistoryTitle,
          tag: "list/tag/history"),
      CategoryBook(
          info: l10n.categoryMysteryInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/10%20mystery.jpeg",
          title: l10n.categoryMysteryTitle,
          tag: "list/tag/mystery"),
      CategoryBook(
          info: l10n.categoryCoversInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/11%20covers.jpeg",
          title: l10n.categoryCoversTitle,
          tag: "list/tag/covers"),
      CategoryBook(
          info: l10n.categoryHorrorInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/12%20horror.jpeg",
          title: l10n.categoryHorrorTitle,
          tag: "list/tag/horror"),
      CategoryBook(
          info: l10n.categoryHistoricalFictionInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/13%20historical%20fiction.jpeg",
          title: l10n.categoryHistoricalFictionTitle,
          tag: "list/tag/historical-fiction"),
      CategoryBook(
          info: l10n.categoryBestInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/15%20best%20.jpeg",
          title: l10n.categoryBestTitle,
          tag: "list/tag/best"),
      CategoryBook(
          info: l10n.categoryTitlesInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/16%20titles.jpeg",
          title: l10n.categoryTitlesTitle,
          tag: "list/tag/titles"),
      CategoryBook(
          info: l10n.categoryMiddleGradeInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/17%20middle%20grade.jpeg",
          title: l10n.categoryMiddleGradeTitle,
          tag: "list/tag/middle-grade"),
      CategoryBook(
          info: l10n.categoryParanormalInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/18%20paranormal.jpeg",
          title: l10n.categoryParanormalTitle,
          tag: "list/tag/paranormal"),
      CategoryBook(
          info: l10n.categoryLoveInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/19%20love.jpeg",
          title: l10n.categoryLoveTitle,
          tag: "list/tag/love"),
      CategoryBook(
          info: l10n.categoryQueerInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/20%20queer.jpeg",
          title: l10n.categoryQueerTitle,
          tag: "list/tag/queer"),
      CategoryBook(
          info: l10n.categoryNonfictionInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/21%20nonfictino.jpeg",
          title: l10n.categoryNonfictionTitle,
          tag: "list/tag/nonfiction"),
      CategoryBook(
          info: l10n.categoryHistoricalRomanceInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/22%20historical%20romance.jpeg",
          title: l10n.categoryHistoricalRomanceTitle,
          tag: "list/tag/historical-romance"),
      CategoryBook(
          info: l10n.categoryContemporaryInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/24%20contemporary.jpeg",
          title: l10n.categoryContemporaryTitle,
          tag: "list/tag/contemporary"),
      CategoryBook(
          info: l10n.categoryThrillerInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/25%20thriller.jpeg",
          title: l10n.categoryThrillerTitle,
          tag: "list/tag/thriller"),
      CategoryBook(
          info: l10n.categoryWomenInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/26%20women.jpeg",
          title: l10n.categoryWomenTitle,
          tag: "list/tag/women"),
      CategoryBook(
          info: l10n.categoryBiographyInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/27%20biography.jpeg",
          title: l10n.categoryBiographyTitle,
          tag: "list/tag/biography"),
      CategoryBook(
          info: l10n.categoryLgbtqInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/28%20lgbtq.jpeg",
          title: l10n.categoryLgbtqTitle,
          tag: "list/tag/lgbtq"),
      CategoryBook(
          info: l10n.categorySeriesInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/29%20series%20.jpeg",
          title: l10n.categorySeriesTitle,
          tag: "list/tag/series"),
      CategoryBook(
          info: l10n.categoryTitleChallengeInfo,
          thumbnail:
              "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/30%20title%20chhallenge.jpeg",
          title: l10n.categoryTitleChallengeTitle,
          tag: "list/tag/title-challenge"),
    ];

IconData _categoryIcon(String tag) {
  return switch (tag) {
    'list/tag/classics' => Icons.auto_stories_outlined,
    'list/tag/romance' => Icons.favorite_outline,
    'list/tag/fiction' => Icons.menu_book_outlined,
    'list/tag/young-adult' => Icons.school_outlined,
    'list/tag/fantasy' => Icons.auto_awesome_outlined,
    'list/tag/science-fiction' => Icons.rocket_launch_outlined,
    'list/tag/non-fiction' => Icons.fact_check_outlined,
    'list/tag/nonfiction' => Icons.fact_check_outlined,
    'list/tag/children' => Icons.child_care_outlined,
    'list/tag/history' => Icons.account_balance_outlined,
    'list/tag/mystery' => Icons.travel_explore_outlined,
    'list/tag/covers' => Icons.image_outlined,
    'list/tag/horror' => Icons.nights_stay_outlined,
    'list/tag/historical-fiction' => Icons.history_edu_outlined,
    'list/tag/best' => Icons.star_outline,
    'list/tag/titles' => Icons.title,
    'list/tag/middle-grade' => Icons.auto_stories,
    'list/tag/paranormal' => Icons.blur_on_outlined,
    'list/tag/love' => Icons.favorite_border,
    'list/tag/queer' => Icons.diversity_3_outlined,
    'list/tag/historical-romance' => Icons.history_outlined,
    'list/tag/contemporary' => Icons.location_city_outlined,
    'list/tag/thriller' => Icons.bolt_outlined,
    'list/tag/women' => Icons.person_outline,
    'list/tag/biography' => Icons.person_outline,
    'list/tag/lgbtq' => Icons.groups_outlined,
    'list/tag/series' => Icons.collections_bookmark_outlined,
    'list/tag/title-challenge' => Icons.emoji_events_outlined,
    _ => Icons.category_outlined,
  };
}

void _openCategory(BuildContext context, CategoryBook category) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CategoryListingPage(
        url: category.tag,
        title: category.title,
      ),
    ),
  );
}

class GenresPage extends StatelessWidget {
  const GenresPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = categoriesTypeValues(l10n);
    final tileHeight = _genreTileHeight(context);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: tileHeight,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = categories[index];
                return _GenreCard(
                  category: category,
                  onTap: () => _openCategory(context, category),
                );
              },
              childCount: categories.length,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          sliver: SliverToBoxAdapter(
            child: InlineHint(
              message: l10n.categoryInfoHint,
              icon: Icons.info_outline,
            ),
          ),
        ),
      ],
    );
  }
}

class GenreShortcutSection extends StatelessWidget {
  const GenreShortcutSection({
    super.key,
    required this.title,
    this.count = 4,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 16),
  });

  final String title;
  final int count;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = categoriesTypeValues(l10n).take(count).toList();
    final tileHeight = _genreTileHeight(context);
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: title,
            hint: l10n.categoryCount(categoriesTypeValues(l10n).length),
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: tileHeight,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _GenreCard(
                category: category,
                onTap: () => _openCategory(context, category),
              );
            },
          ),
        ],
      ),
    );
  }
}

double _genreTileHeight(BuildContext context) {
  final scaler = MediaQuery.textScalerOf(context);
  final content = 16 + scaler.scale(20) + 4 + scaler.scale(16);
  return content < 64 ? 64 : content;
}

class _GenreCard extends StatelessWidget {
  const _GenreCard({required this.category, required this.onTap});

  final CategoryBook category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SwissRadius.field),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(SwissRadius.sm),
                ),
                child: Icon(
                  _categoryIcon(category.tag),
                  size: 16,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SwissText.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.info,
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
      ),
    );
  }
}

class CategoryListingPage extends StatefulWidget {
  const CategoryListingPage(
      {super.key, required this.url, required this.title, this.viewModel});
  final String url;
  final String title;

  /// Injected by tests; the page builds its own view model otherwise.
  final CategoriesViewModel? viewModel;

  @override
  State<CategoryListingPage> createState() => _CategoryListingPageState();
}

class _CategoryListingPageState extends State<CategoryListingPage> {
  late final CategoriesViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel =
        widget.viewModel ?? CategoriesViewModel.fromDi(url: widget.url);
    unawaited(_viewModel.load());
  }

  @override
  void dispose() {
    if (_ownsViewModel) _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final width = MediaQuery.sizeOf(context).width;
    final contentWidth = (width > 840 ? 840.0 : width) - 32;
    final columns = width < 600
        ? 2
        : width < 900
            ? 3
            : 4;
    final cardWidth = (contentWidth - 8 * (columns - 1)) / columns;
    // 72 covers the two-line title plus author and meta lines; 30 is the
    // vertical gaps and card padding around them.
    final textHeight = MediaQuery.textScalerOf(context).scale(72);
    final cardHeight = cardWidth * 1.5 + textHeight + 30;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ContentWidth(
        maxWidth: 840,
        child: ListenableBuilder(
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
                contextLabel: AppLocalizations.of(context).genres,
                contextDetails: '${widget.title} · ${widget.url}',
                onRefresh: _viewModel.refresh,
              );
            }
            final data = _viewModel.books;
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: cardWidth / cardHeight,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final book = data[index];
                        final rating = book.rating;
                        final published = book.published;
                        final meta = [
                          if (rating != null && rating.isNotEmpty) '★ $rating',
                          if (published != null && published.isNotEmpty)
                            published,
                        ].join(' · ');
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              _viewModel.prepareOpen();
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return ResultPage(searchQuery: book.title!);
                              }));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 2 / 3,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          SwissRadius.field),
                                      child: CachedNetworkImage(
                                        imageUrl: book.thumbnail!,
                                        memCacheWidth:
                                            (cardWidth * dpr).round(),
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            ColoredBox(
                                          color: scheme.surfaceContainerHighest,
                                          child: Icon(
                                            Icons.menu_book_outlined,
                                            color: scheme.onSurfaceVariant,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            ColoredBox(
                                          color: scheme.surfaceContainerHighest,
                                          child: Icon(
                                            Icons.image_not_supported_outlined,
                                            color: scheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    book.title!,
                                    style: SwissText.label,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (book.author != null &&
                                      book.author!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      book.author!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: SwissText.micro.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                  if (meta.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      meta,
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
                          ),
                        );
                      },
                      childCount: data.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
