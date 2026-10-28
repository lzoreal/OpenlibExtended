// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/data/models/book_data.dart' show BookData;
import 'package:openlib/data/models/search_result.dart';
import 'package:openlib/data/services/webview_challenge_solver.dart';
import 'package:openlib/ui/features/book_detail/views/book_info_page.dart';
import 'package:openlib/ui/features/shell/widgets/content_width.dart';
import 'package:openlib/ui/core/components/error_widget.dart';
import 'package:openlib/ui/core/components/inline_hint.dart';
import 'package:openlib/ui/core/components/language_names.dart';
import 'package:openlib/ui/features/results/view_models/results_view_model.dart';
import 'package:openlib/ui/features/results/widgets/search_result_card.dart';
import 'package:openlib/ui/core/components/search_source_meta.dart';
import 'package:openlib/ui/features/results/widgets/source_journey_card.dart';
import 'package:openlib/ui/core/swiss_grid.dart';

/// Search results across the enabled catalogs.
///
/// Page 1 queries every enabled source in parallel. The source card
/// switches between the merged list and one catalog's list; deeper pages
/// follow the currently selected view.
class ResultPage extends StatefulWidget {
  const ResultPage({
    super.key,
    required this.searchQuery,
    this.source,
    this.viewModel,
  });

  final String searchQuery;

  /// The source view this route opens on. Every source is still queried;
  /// null opens the merged list. The source card switches views in place.
  final SearchProviderId? source;

  /// Injected by tests; the route builds its own view model otherwise.
  final ResultsViewModel? viewModel;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final _scrollController = ScrollController();
  late final ResultsViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ??
        ResultsViewModel.fromDi(
          query: widget.searchQuery,
          source: widget.source,
        );
    _scrollController.addListener(_onScroll);
    unawaited(_viewModel.start());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (_ownsViewModel) _viewModel.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 240 &&
        !_viewModel.fetchingNextPage &&
        !_viewModel.currentViewEnded) {
      unawaited(_viewModel.loadNextPage());
    }
  }

  Future<void> _pickSort() async {
    final l10n = AppLocalizations.of(context);
    final current = _viewModel.sortValue;
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => _SortSheet(
        current: current,
        labelFor: (value) => _sortLabel(l10n, value),
      ),
    );
    if (selected == null || selected == current) return;
    await _viewModel.setSort(selected);
  }

  Future<void> _pickFormats(List<String> options) async {
    final picked = await _pickMultiSelect(
      title: AppLocalizations.of(context).filterFileTypeLabel,
      options: options,
      selected: _viewModel.formatFilters,
    );
    if (picked == null || !mounted) return;
    _viewModel.setFormatFilters(picked);
  }

  Future<void> _pickLanguages(List<String> options) async {
    final l10n = AppLocalizations.of(context);
    final picked = await _pickMultiSelect(
      title: l10n.languageSetting,
      options: options,
      labels: {
        for (final code in options) code: localizedLanguageName(l10n, code),
      },
      selected: _viewModel.languageFilters,
    );
    if (picked == null || !mounted) return;
    _viewModel.setLanguageFilters(picked);
  }

  Future<Set<String>?> _pickMultiSelect({
    required String title,
    required List<String> options,
    required Set<String> selected,
    Map<String, String>? labels,
  }) {
    return showModalBottomSheet<Set<String>>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _MultiSelectFilterSheet(
        title: title,
        options: options,
        labels: labels,
        selected: selected,
      ),
    );
  }

  Future<void> _openSourceSheet() async {
    final enabled = _viewModel.enabledSources.toSet();
    final available = _viewModel.sourceOrder
        .where((source) => enabled.contains(source))
        .toList(growable: false);
    final selection = await showModalBottomSheet<_SourceSelection>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return _SourcePickerSheet(
          query: widget.searchQuery,
          sources: available,
          runs: _viewModel.sources,
          currentSource: _viewModel.selectedSource,
        );
      },
    );
    if (!mounted || selection == null) return;
    _viewModel.selectSource(selection.auto ? null : selection.source);
  }

  Future<void> _openBook(BookData book) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookInfoPage(
          url: book.link,
          source: book.source,
          preview: book,
        ),
      ),
    );
    if (mounted) unawaited(_viewModel.refreshDownloadedIds());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 60,
        titleSpacing: 16,
        title: ContentWidth(
          maxWidth: 840,
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: const Icon(Icons.arrow_back_rounded, size: 19),
                style: IconButton.styleFrom(
                  fixedSize: const Size(34, 34),
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QueryPill(
                  query: widget.searchQuery,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ContentWidth(
        maxWidth: 840,
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) => _body(l10n),
        ),
      ),
    );
  }

  Widget _body(AppLocalizations l10n) {
    final vm = _viewModel;

    if (vm.error != null) {
      final source = vm.selectedSource;
      return CustomErrorWidget(
        error: vm.error!,
        stackTrace: vm.errorStackTrace ?? StackTrace.empty,
        onRefresh: vm.retryPageOne,
        contextLabel: l10n.results,
        contextDetails: 'query=${widget.searchQuery}'
            '${source == null ? '' : ' · source=${source.name}'}',
      );
    }

    final result = vm.firstResult;
    if (result == null) {
      return _LoadingResults(
        source: widget.source,
        enabledSources: vm.enabledSources,
        sourceOrder: vm.sourceOrder,
      );
    }

    if (vm.books.isEmpty) {
      return _EmptyResults(
        query: widget.searchQuery,
        result: result,
        selectedSource: vm.selectedSource,
        onSelectSource: vm.selectSource,
        onModify: () => Navigator.of(context).maybePop(),
        onClearFilters: vm.clearFiltersAndRetry,
        onRetrySkipped: vm.retryIgnoringLocalTimeouts,
        retrying: vm.retrying,
      );
    }

    return _successView(result: result);
  }

  Widget _successView({required SearchManagerResult result}) {
    final l10n = AppLocalizations.of(context);
    final vm = _viewModel;
    final selectedSource = vm.selectedSource;
    final allCount = vm.allBooks.length;

    SearchSourceRun? selectedRun;
    for (final run in result.sources) {
      if (run.id == selectedSource) {
        selectedRun = run;
        break;
      }
    }
    final rightLabel =
        selectedRun?.displayName ?? l10n.sourceCount(result.sources.length);

    final pending = <String>[
      for (final run in result.sources)
        if (run.status == SearchSourceStatus.pending)
          sourceShortLabel(l10n, run.id),
    ];

    String? otherSources;
    if (selectedSource != null) {
      final parts = <String>[];
      for (final run in result.sources) {
        if (run.id == selectedSource) continue;
        final status = switch (run.status) {
          SearchSourceStatus.pending => '…',
          SearchSourceStatus.failed => l10n.sourceStatusFailed,
          _ => '${run.resultCount}',
        };
        parts.add('${sourceShortLabel(l10n, run.id)} $status');
      }
      if (parts.isNotEmpty) {
        otherSources = l10n.otherSources(parts.join(' · '));
      }
    }

    final sortValue = vm.sortValue;

    return _ResultsView(
      result: result,
      visibleBooks: vm.visibleBooks,
      sortChipLabel: sortValue == 'Most Relevant'
          ? l10n.filterRelevance
          : _sortLabel(l10n, sortValue),
      allCount: allCount,
      rightLabel: rightLabel,
      pendingLabels: pending,
      formats: vm.availableFormats,
      languages: vm.availableLanguages,
      otherSources: otherSources,
      selectedSource: selectedSource,
      formatFilters: vm.formatFilters,
      languageFilters: vm.languageFilters,
      fetchingNextPage: vm.fetchingNextPage,
      reachedEnd: vm.currentViewEnded,
      scrollController: _scrollController,
      isDownloaded: vm.isDownloaded,
      resolveCover: vm.coverFor,
      onSelectSource: vm.selectSource,
      onOpenSourceSheet: _openSourceSheet,
      onPickSort: _pickSort,
      onPickFormats: _pickFormats,
      onPickLanguages: _pickLanguages,
      onClearFilters: vm.clearLocalFilters,
      onRetrySkipped: vm.retryIgnoringLocalTimeouts,
      onOpenBook: _openBook,
    );
  }

  String _sortLabel(AppLocalizations l10n, String value) {
    return switch (value) {
      'Newest' => l10n.sortNewest,
      'Oldest' => l10n.sortOldest,
      'Largest' => l10n.sortLargest,
      'Smallest' => l10n.sortSmallest,
      _ => l10n.sortMostRelevant,
    };
  }
}

String _filterLabel(String base, Set<String> selection) {
  if (selection.isEmpty) return base;
  if (selection.length == 1) return selection.first;
  return '$base · ${selection.length}';
}

SearchProviderId? _sourceIdForBook(
  SearchManagerResult result,
  BookData book,
  SearchProviderId? selectedSource,
) {
  for (final run in result.sources) {
    if (run.displayName == book.source) return run.id;
  }
  return selectedSource;
}

/// The scrollable results surface: header, filter capsules, the list and
/// the pagination footer. Filters live in [ResultsViewModel] so they
/// survive a retry's loading flash; this widget only renders and forwards
/// intents.
class _ResultsView extends StatelessWidget {
  const _ResultsView({
    required this.result,
    required this.visibleBooks,
    required this.sortChipLabel,
    required this.allCount,
    required this.rightLabel,
    required this.pendingLabels,
    required this.formats,
    required this.languages,
    required this.otherSources,
    required this.selectedSource,
    required this.formatFilters,
    required this.languageFilters,
    required this.fetchingNextPage,
    required this.reachedEnd,
    required this.scrollController,
    required this.isDownloaded,
    required this.resolveCover,
    required this.onSelectSource,
    required this.onOpenSourceSheet,
    required this.onPickSort,
    required this.onPickFormats,
    required this.onPickLanguages,
    required this.onClearFilters,
    required this.onRetrySkipped,
    required this.onOpenBook,
  });

  final SearchManagerResult result;
  final List<BookData> visibleBooks;
  final String sortChipLabel;
  final int allCount;
  final String rightLabel;
  final List<String> pendingLabels;
  final List<String> formats;
  final List<String> languages;
  final String? otherSources;
  final SearchProviderId? selectedSource;
  final Set<String> formatFilters;
  final Set<String> languageFilters;
  final bool fetchingNextPage;
  final bool reachedEnd;
  final ScrollController scrollController;
  final bool Function(String? md5) isDownloaded;
  final Future<String?> Function(String link) resolveCover;
  final ValueChanged<SearchProviderId?> onSelectSource;
  final VoidCallback onOpenSourceSheet;
  final VoidCallback onPickSort;
  final ValueChanged<List<String>> onPickFormats;
  final ValueChanged<List<String>> onPickLanguages;
  final VoidCallback onClearFilters;
  final VoidCallback onRetrySkipped;
  final ValueChanged<BookData> onOpenBook;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final filterChips = <Widget>[
      FilterChip(
        selected: true,
        showCheckmark: false,
        avatar: Icon(
          Icons.tune_rounded,
          size: 16,
          color: scheme.onPrimaryContainer,
        ),
        label: Text(sortChipLabel),
        onSelected: (_) => onPickSort(),
      ),
      // One capsule per dimension: the picker behind it is multi-select,
      // so results pages no longer grow a chip per format and language.
      _FilterCapsule(
        key: const ValueKey('format-filter-capsule'),
        label: _filterLabel(l10n.filterFileTypeLabel, formatFilters),
        active: formatFilters.isNotEmpty,
        onTap: formats.isEmpty ? null : () => onPickFormats(formats),
      ),
      _FilterCapsule(
        key: const ValueKey('language-filter-capsule'),
        label: _filterLabel(
          l10n.languageSetting,
          languageFilters
              .map((code) => localizedLanguageName(l10n, code))
              .toSet(),
        ),
        active: languageFilters.isNotEmpty,
        onTap: languages.isEmpty ? null : () => onPickLanguages(languages),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: CustomScrollView(
        controller: scrollController,
        scrollCacheExtent: const ScrollCacheExtent.pixels(600),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ResultsHeading(
                  count: visibleBooks.length,
                  rightLabel: rightLabel,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onLongPress: onOpenSourceSheet,
                  child: SourceJourneyCard(
                    sources: result.sources,
                    selectedSource: selectedSource,
                    onSelect: onSelectSource,
                    totalCount: allCount,
                  ),
                ),
                _ChallengeHint(pendingLabels: pendingLabels),
                _SkippedSourcesHint(
                  sources: [
                    for (final run in result.sources)
                      if (run.status == SearchSourceStatus.locallyUnreachable)
                        run,
                  ],
                  onRetry: onRetrySkipped,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: filterChips,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          if (visibleBooks.isEmpty)
            SliverToBoxAdapter(
              child: _NoMatchesHint(onClearFilters: onClearFilters),
            )
          else
            DecoratedSliver(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(SwissRadius.card),
                border: Border.all(color: scheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: scheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              sliver: SliverList.builder(
                itemCount: visibleBooks.length,
                itemBuilder: (context, index) {
                  final book = visibleBooks[index];
                  return Column(
                    key: ValueKey(book.md5.isNotEmpty ? book.md5 : book.link),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ResultRow(
                        book: book,
                        sourceId: _sourceIdForBook(
                          result,
                          book,
                          selectedSource,
                        ),
                        downloaded: isDownloaded(book.md5),
                        resolveCover: resolveCover,
                        onTap: () => onOpenBook(book),
                      ),
                      if (index < visibleBooks.length - 1)
                        Divider(
                          height: 1,
                          color: scheme.outlineVariant.withValues(alpha: 0.55),
                        ),
                    ],
                  );
                },
              ),
            ),
          if (otherSources != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: InlineHint(
                  icon: Icons.public,
                  message: otherSources!,
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: _PaginationFooter(
              fetching: fetchingNextPage,
              reachedEnd: reachedEnd,
              label: l10n.loadMoreResults,
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter dimension capsule: a label plus an expand affordance.
class _FilterCapsule extends StatelessWidget {
  const _FilterCapsule({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilterChip(
      selected: active,
      showCheckmark: false,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 2),
          Icon(
            Icons.expand_more_rounded,
            size: 16,
            color: active ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
          ),
        ],
      ),
      onSelected: onTap == null ? null : (_) => onTap!(),
    );
  }
}

/// "Still searching" / "needs verification" banner above the list.
class _ChallengeHint extends StatelessWidget {
  const _ChallengeHint({required this.pendingLabels});

  final List<String> pendingLabels;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: Listenable.merge([
        WebviewChallengeSolver.pendingChallenges,
        WebviewChallengeSolver.failedChallenges,
      ]),
      builder: (context, _) {
        final pendingUrls = WebviewChallengeSolver.pendingChallenges.value;
        final failedUrls = WebviewChallengeSolver.failedChallenges.value;
        if (pendingUrls.isEmpty &&
            failedUrls.isEmpty &&
            pendingLabels.isEmpty) {
          return const SizedBox.shrink();
        }

        final challengeUrl = failedUrls.isNotEmpty
            ? failedUrls.first
            : (pendingUrls.isNotEmpty ? pendingUrls.first : null);
        if (challengeUrl == null) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: InlineHint(
              icon: Icons.refresh_rounded,
              message: pendingLabels.length == 1
                  ? l10n.sourceStillSearching(pendingLabels.first)
                  : l10n.sourceStillSearching(pendingLabels.join(' · ')),
            ),
          );
        }

        final needsRetry = failedUrls.isNotEmpty;
        // A source is stuck on a challenge: offer the verification page now
        // instead of letting the invisible solve run out its timeout first.
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Expanded(
                child: InlineHint(
                  icon: Icons.shield_outlined,
                  tone: InlineHintTone.warning,
                  message: needsRetry
                      ? l10n.challengeNeedsVerificationRetry
                      : l10n.challengeNeedsVerification,
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => unawaited(
                  WebviewChallengeSolver.requestVisibleSolve(challengeUrl),
                ),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.challengeVerifyNow,
                  style: SwissText.micro.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.book,
    required this.sourceId,
    required this.downloaded,
    required this.resolveCover,
    required this.onTap,
  });

  final BookData book;
  final SearchProviderId? sourceId;
  final bool downloaded;
  final Future<String?> Function(String link) resolveCover;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final id = sourceId;
    return SearchResultCard(
      title: book.title,
      author: book.author ?? '',
      thumbnail: book.thumbnail,
      info: book.info,
      link: book.link,
      md5: book.md5,
      sourceLabel: id == null ? book.source : sourceShortLabel(l10n, id),
      downloaded: downloaded,
      resolveCover: resolveCover,
      onClick: onTap,
    );
  }
}

class _NoMatchesHint extends StatelessWidget {
  const _NoMatchesHint({required this.onClearFilters});

  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Text(l10n.noResultsFound, style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          TextButton(
            onPressed: onClearFilters,
            child: Text(l10n.clearFiltersRetry),
          ),
        ],
      ),
    );
  }
}

/// Sort picker shown from the first filter capsule.
class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.current, required this.labelFor});

  final String current;
  final String Function(String) labelFor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: Text(
              l10n.filterSortLabel,
              style: theme.textTheme.titleMedium,
            ),
          ),
          for (final value in resultSortValues)
            ListTile(
              title: Text(labelFor(value)),
              trailing: value == current
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              selected: value == current,
              onTap: () => Navigator.pop(context, value),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _QueryPill extends StatelessWidget {
  const _QueryPill({required this.query, required this.onTap});

  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = StadiumBorder(
      side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
    );
    return Material(
      color: scheme.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: SizedBox(
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.search_rounded, size: 16, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    query,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SwissText.caption.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: scheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultsHeading extends StatelessWidget {
  const _ResultsHeading({required this.count, required this.rightLabel});

  final int count;
  final String rightLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(
            l10n.resultsCount(count),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SwissText.headline.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          rightLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: SwissText.micro.copyWith(color: scheme.outline),
        ),
      ],
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.fetching,
    required this.reachedEnd,
    required this.label,
  });

  final bool fetching;
  final bool reachedEnd;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (reachedEnd && !fetching) return const SizedBox(height: 12);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: fetching
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: scheme.primary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: scheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: SwissText.micro.copyWith(color: scheme.outline),
                  ),
                ],
              ),
      ),
    );
  }
}

class _LoadingResults extends StatelessWidget {
  const _LoadingResults({
    required this.source,
    required this.enabledSources,
    required this.sourceOrder,
  });

  final SearchProviderId? source;
  final List<SearchProviderId> enabledSources;
  final List<SearchProviderId> sourceOrder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final enabled = enabledSources.toSet();
    final chain = source != null
        ? [source!]
        : sourceOrder.where(enabled.contains).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      l10n.searchingTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SwissText.headline.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              source == null
                  ? l10n.sourceCount(chain.length)
                  : sourceLabel(l10n, source!),
              style: SwissText.micro.copyWith(color: scheme.outline),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _LoadingSourcePill(
              label: l10n.searchSourceAuto,
              selected: true,
            ),
            for (final id in chain)
              _LoadingSourcePill(
                label: id == SearchProviderId.zlibrary
                    ? l10n.sourceZlibShort
                    : sourceShortLabel(l10n, id),
                selected: false,
              ),
          ],
        ),
        const SizedBox(height: 8),
        InlineHint(
          icon: Icons.refresh_rounded,
          message: l10n.searchSourceAutoHint,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              selected: true,
              showCheckmark: false,
              avatar: Icon(
                Icons.tune_rounded,
                size: 16,
                color: scheme.onPrimaryContainer,
              ),
              label: Text(l10n.filterRelevance),
              onSelected: (_) {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(SwissRadius.card),
            border: Border.all(color: scheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < 4; i++) ...[
                const _SkeletonRow(),
                if (i < 3)
                  Divider(
                    height: 1,
                    color: scheme.outlineVariant.withValues(alpha: 0.55),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LoadingSourcePill extends StatelessWidget {
  const _LoadingSourcePill({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: selected ? scheme.primary : scheme.surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? Colors.transparent : scheme.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 34,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: selected ? scheme.onPrimary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: selected
                      ? null
                      : Border.all(color: scheme.outline, width: 1.5),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: SwissText.micro.copyWith(
                  color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '…',
                style: SwissText.badge.copyWith(
                  color: selected
                      ? scheme.onPrimary.withValues(alpha: 0.72)
                      : scheme.outline,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fill = scheme.surfaceContainerHigh;
    Widget line(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 80,
        child: Row(
          children: [
            Container(
              width: 56,
              height: 80,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(SwissRadius.sm),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  line(double.infinity, 12),
                  const SizedBox(height: 8),
                  line(150, 8),
                  const SizedBox(height: 8),
                  line(110, 8),
                  const Spacer(),
                  line(96, 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({
    required this.query,
    required this.result,
    required this.selectedSource,
    required this.onSelectSource,
    required this.onModify,
    required this.onClearFilters,
    required this.onRetrySkipped,
    required this.retrying,
  });

  final String query;
  final SearchManagerResult result;
  final SearchProviderId? selectedSource;
  final ValueChanged<SearchProviderId?> onSelectSource;
  final VoidCallback onModify;
  final VoidCallback onClearFilters;
  final VoidCallback onRetrySkipped;
  final bool retrying;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final responded = result.sources
        .where((run) =>
            run.status != SearchSourceStatus.pending &&
            run.status != SearchSourceStatus.skipped &&
            run.status != SearchSourceStatus.locallyUnreachable)
        .length;
    final failed = result.sources
        .where((run) => run.status == SearchSourceStatus.failed)
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _ResultsHeading(
          count: 0,
          rightLabel: selectedSource != null
              ? sourceLabel(l10n, selectedSource!)
              : l10n.sourcesResponded(responded),
        ),
        if (result.sources.isNotEmpty) ...[
          const SizedBox(height: 10),
          SourceJourneyCard(
            sources: result.sources,
            selectedSource: selectedSource,
            onSelect: onSelectSource,
            totalCount: 0,
          ),
        ],
        _SkippedSourcesHint(
          sources: [
            for (final run in result.sources)
              if (run.status == SearchSourceStatus.locallyUnreachable) run,
          ],
          onRetry: onRetrySkipped,
        ),
        const SizedBox(height: 30),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    size: 38,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.noResultsFor(query),
                  textAlign: TextAlign.center,
                  style: SwissText.subtitle.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.noResultsSourcesBody,
                  textAlign: TextAlign.center,
                  style: SwissText.micro.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.tonalIcon(
                  onPressed: onModify,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(l10n.searchAgain),
                ),
                TextButton(
                  onPressed: retrying ? null : onClearFilters,
                  child: retrying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.clearFiltersRetry),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        if (result.sources.isNotEmpty)
          _SourceStatusCard(
            sources: result.sources,
            responded: responded,
            failed: failed,
          ),
      ],
    );
  }
}

class _SourceStatusCard extends StatelessWidget {
  const _SourceStatusCard({
    required this.sources,
    required this.responded,
    required this.failed,
  });

  final List<SearchSourceRun> sources;
  final int responded;
  final int failed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 19,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.sourceStatusTitle,
                      style: SwissText.label,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.sourceStatusSummary(responded, failed),
                      style: SwissText.micro.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (var index = 0; index < sources.length; index++) ...[
            if (index > 0)
              Divider(
                height: 1,
                color: scheme.outlineVariant.withValues(alpha: 0.55),
              ),
            _SourceStatusRow(run: sources[index]),
          ],
        ],
      ),
    );
  }
}

class _SkippedSourcesHint extends StatelessWidget {
  const _SkippedSourcesHint({required this.sources, required this.onRetry});

  final List<SearchSourceRun> sources;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final names = sources.map((run) => run.displayName).join(' · ');

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: InlineHint(
              icon: Icons.cloud_off_rounded,
              message: l10n.sourcesSkippedLocally(names),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(l10n.retryAnyway),
          ),
        ],
      ),
    );
  }
}

class _SourceStatusRow extends StatelessWidget {
  const _SourceStatusRow({required this.run});

  final SearchSourceRun run;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final label = run.id == SearchProviderId.annasArchive
        ? l10n.sourceAnnasShort
        : sourceLabel(l10n, run.id);
    final (status, color) = switch (run.status) {
      SearchSourceStatus.failed => (l10n.sourceTimedOut, scheme.error),
      SearchSourceStatus.pending => (
          l10n.sourceStatusSearching,
          scheme.outline,
        ),
      SearchSourceStatus.skipped => (
          l10n.sourceStatusUntried,
          scheme.outline,
        ),
      SearchSourceStatus.locallyUnreachable => (
          l10n.sourceStatusLocallyUnreachable,
          scheme.outline,
        ),
      _ => (l10n.sourceResponded(run.resultCount), scheme.secondary),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: SwissText.micro.copyWith(color: scheme.outline),
            ),
          ),
          Text(
            status,
            textAlign: TextAlign.right,
            style: SwissText.micro.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceSelection {
  const _SourceSelection.auto()
      : source = null,
        auto = true;

  const _SourceSelection.source(this.source) : auto = false;

  final SearchProviderId? source;
  final bool auto;
}

class _SourcePickerSheet extends StatelessWidget {
  const _SourcePickerSheet({
    required this.query,
    required this.sources,
    required this.runs,
    required this.currentSource,
  });

  final String query;
  final List<SearchProviderId> sources;
  final List<SearchSourceRun> runs;
  final SearchProviderId? currentSource;

  SearchSourceRun? _runFor(SearchProviderId id) {
    return runs.where((run) => run.id == id).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.sourceSheetTitle,
                          style: SwissText.subtitle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.sourceSheetSubtitle(query),
                          style: SwissText.badge.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip:
                        MaterialLocalizations.of(context).closeButtonTooltip,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: scheme.surfaceContainerHigh,
                      foregroundColor: scheme.onSurfaceVariant,
                      fixedSize: const Size(28, 28),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _SourceOptionRow(
                      selected: currentSource == null,
                      leading: _AutoSourceIcon(scheme: scheme),
                      title: l10n.sourceAutoRecommended,
                      subtitle: l10n.searchSourceAutoHint,
                      onTap: () => Navigator.of(context)
                          .pop(const _SourceSelection.auto()),
                    ),
                    for (final source in sources)
                      _SourceOptionRow(
                        selected: currentSource == source,
                        leading: _SourceMarkBox(
                          scheme: scheme,
                          id: source,
                        ),
                        title: sourceLabel(l10n, source),
                        subtitle: _runLabel(l10n, _runFor(source)),
                        failed: _runFor(source)?.status ==
                            SearchSourceStatus.failed,
                        onTap: () => Navigator.of(context)
                            .pop(_SourceSelection.source(source)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.only(top: 9),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: scheme.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 12, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        l10n.sourceSheetNote,
                        style: SwissText.badge.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
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

  String _runLabel(AppLocalizations l10n, SearchSourceRun? run) {
    if (run == null) return l10n.sourceStatusUntried;
    return switch (run.status) {
      SearchSourceStatus.pending => l10n.sourceStatusSearching,
      SearchSourceStatus.hit ||
      SearchSourceStatus.empty =>
        l10n.sourceResultCount(run.resultCount),
      SearchSourceStatus.failed => l10n.sourceStatusFailed,
      SearchSourceStatus.locallyUnreachable =>
        l10n.sourceStatusLocallyUnreachable,
      SearchSourceStatus.skipped => l10n.sourceStatusUntried,
    };
  }
}

class _SourceOptionRow extends StatelessWidget {
  const _SourceOptionRow({
    required this.selected,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.failed = false,
  });

  final bool selected;
  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? scheme.primaryContainer : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SwissRadius.field),
          side: BorderSide(
            color: selected ? scheme.primary : Colors.transparent,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: SwissText.micro.copyWith(
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? scheme.onPrimaryContainer
                                    : scheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SwissText.badge.copyWith(
                          color: failed
                              ? scheme.tertiary
                              : (selected
                                  ? scheme.onPrimaryContainer
                                  : scheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 16,
                  height: 16,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? scheme.primary : Colors.transparent,
                    border: Border.all(
                      color: selected ? scheme.primary : scheme.outlineVariant,
                      width: 1.5,
                    ),
                  ),
                  child: selected
                      ? Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: scheme.onPrimary,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AutoSourceIcon extends StatelessWidget {
  const _AutoSourceIcon({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.auto_awesome, size: 14, color: scheme.primary),
    );
  }
}

class _SourceMarkBox extends StatelessWidget {
  const _SourceMarkBox({required this.scheme, required this.id});

  final ColorScheme scheme;
  final SearchProviderId id;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        sourceMark(id),
        style: SwissText.badge.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Multi-select picker behind the format and language capsules.
class _MultiSelectFilterSheet extends StatefulWidget {
  const _MultiSelectFilterSheet({
    required this.title,
    required this.options,
    required this.selected,
    this.labels,
  });

  final String title;
  final List<String> options;
  final Set<String> selected;

  /// Display name per value (language codes show their localized name).
  final Map<String, String>? labels;

  @override
  State<_MultiSelectFilterSheet> createState() =>
      _MultiSelectFilterSheetState();
}

class _MultiSelectFilterSheetState extends State<_MultiSelectFilterSheet> {
  late final Set<String> _selected = {...widget.selected};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 8, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(widget.title, style: theme.textTheme.titleMedium),
                ),
                TextButton(
                  onPressed: _selected.isEmpty
                      ? null
                      : () => setState(_selected.clear),
                  child: Text(l10n.clearAll),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final option in widget.options)
                  CheckboxListTile(
                    value: _selected.contains(option),
                    title: Text(widget.labels?[option] ?? option),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (checked) {
                      setState(() {
                        if (checked ?? false) {
                          _selected.add(option);
                        } else {
                          _selected.remove(option);
                        }
                      });
                    },
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: FilledButton(
              onPressed: () => Navigator.pop(context, _selected),
              child: Text(l10n.done),
            ),
          ),
        ],
      ),
    );
  }
}
