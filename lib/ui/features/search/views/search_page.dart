// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

import 'package:openlib/l10n/app_localizations.dart';

// Project imports:
import 'package:openlib/ui/core/components/swipeable_tab_view.dart';
import 'package:openlib/app/di.dart';
import 'package:openlib/data/models/search_filters.dart';
import 'package:openlib/data/models/trending_book_data.dart';
import 'package:openlib/data/services/mirror_latency.dart';
import 'package:openlib/data/services/mirror_latency_controller.dart';
import 'package:openlib/ui/core/filter_options.dart';
import 'package:openlib/ui/core/components/active_downloads_widget.dart';
import 'package:openlib/ui/features/shell/widgets/content_width.dart';
import 'package:openlib/ui/features/search/view_models/search_view_model.dart';
import 'package:openlib/ui/features/search/widgets/edge_fade.dart';
import 'package:openlib/ui/core/components/inline_hint.dart';
import 'package:openlib/ui/features/search/widgets/mirror_latency_hint.dart';
import 'package:openlib/ui/core/components/page_header.dart';
import 'package:openlib/ui/core/components/pill_tabs.dart';
import 'package:openlib/ui/core/components/search_source_meta.dart';
import 'package:openlib/ui/core/components/section_header.dart';
import 'package:openlib/ui/features/results/views/results_page.dart';
import 'package:openlib/ui/core/swiss_grid.dart';
import 'package:openlib/ui/core/components/snack_bar_widget.dart';

enum _SearchMode { suggestions, advanced }

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.viewModel, this.onManageSources});

  /// Tests inject their own instance; the app resolves the shared one.
  final SearchViewModel? viewModel;
  final VoidCallback? onManageSources;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late final SearchViewModel _vm;
  late final bool _ownsVm;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late final TabController _modeController;
  _SearchMode _mode = _SearchMode.suggestions;
  bool _mirrorTestStarting = false;

  @override
  void initState() {
    super.initState();
    _vm = widget.viewModel ?? getIt<SearchViewModel>();
    _ownsVm = widget.viewModel == null;
    _modeController = TabController(
      length: _SearchMode.values.length,
      vsync: this,
      initialIndex: _mode.index,
    );
    _modeController.addListener(_syncMode);
    _searchController = TextEditingController(text: _vm.query);
    _searchFocusNode = FocusNode();
    _vm.addListener(_syncController);
    unawaited(_vm.load());
  }

  // The search bar owns the caret while typing, so only adopt the query when
  // something else (submit, clear, restore) changed it.
  void _syncController() {
    final query = _vm.query;
    if (_searchController.text == query) return;
    _searchController.text = query;
    _searchController.selection =
        TextSelection.fromPosition(TextPosition(offset: query.length));
  }

  Future<void> _runMirrorLatencyTest() async {
    if (_mirrorTestStarting || _vm.mirrorLatency.testing) {
      return;
    }
    _mirrorTestStarting = true;

    final l10n = AppLocalizations.of(context);
    try {
      final result = await _vm.testMirrorLatency();
      if (!mounted) return;
      final message = result.total == 0
          ? l10n.mirrorLatencyNoTargets
          : result.reachable == 0
              ? l10n.mirrorLatencyAllTimedOut
              : l10n.mirrorLatencyDone(
                  result.reachable,
                  result.total,
                  formatMirrorLatency(result.fastestMs!),
                );
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mirrorLatencyFailed('$e'))),
      );
    } finally {
      _mirrorTestStarting = false;
    }
  }

  void _syncMode() {
    final mode = _SearchMode.values[_modeController.index];
    if (_mode != mode) {
      setState(() => _mode = mode);
    }
  }

  @override
  void dispose() {
    _vm.removeListener(_syncController);
    if (_ownsVm) {
      _vm.dispose();
    }
    _modeController.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchQueryChanged(String value) {
    _vm.updateQuery(value);
  }

  void _clearQuery() {
    _searchController.clear();
    _vm.clearQuery();
    _searchFocusNode.requestFocus();
  }

  void _setMode(_SearchMode mode) {
    if (_mode == mode) return;
    setState(() => _mode = mode);
    if (_modeController.index != mode.index) {
      _modeController.animateTo(mode.index);
    }
    if (mode == _SearchMode.advanced) {
      _searchFocusNode.unfocus();
    }
  }

  Future<void> _submit([String? value]) async {
    final query = await _vm.prepareSearch(value);
    if (!mounted) return;
    if (query == null) {
      showSnackBar(
          context: context,
          message: AppLocalizations.of(context).searchEmptyQuery);
      if (_mode != _SearchMode.suggestions) {
        _setMode(_SearchMode.suggestions);
      }
      _searchFocusNode.requestFocus();
      return;
    }
    _syncController();
    _searchFocusNode.unfocus();

    final selected = _vm.selectedSource;
    final source = selected != null && _vm.enabledProviders.contains(selected)
        ? selected
        : null;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultPage(searchQuery: query, source: source),
      ),
    );
  }

  void _resetFilters() {
    _vm.resetFilters();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        final theme = Theme.of(context);
        final l10n = AppLocalizations.of(context);
        final query = _vm.query;
        final advancedCount = _vm.advancedFilterCount;

        return ContentWidth(
          maxWidth: 840,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PageHeader(
                      eyebrow: l10n.searchEyebrow,
                      title: l10n.navSearch,
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
                    ),
                    const ActiveDownloadsWidget(),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.08),
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: SearchBar(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        hintText: l10n.homeSearchHint,
                        backgroundColor:
                            WidgetStatePropertyAll(theme.colorScheme.surface),
                        shape: WidgetStatePropertyAll(
                          StadiumBorder(
                            side: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        constraints: const BoxConstraints(
                          minHeight: 52,
                          maxHeight: 52,
                        ),
                        padding: const WidgetStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 16),
                        ),
                        textStyle: WidgetStatePropertyAll(SwissText.body),
                        hintStyle: WidgetStatePropertyAll(
                          SwissText.caption.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        leading: const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.search_rounded),
                        ),
                        trailing: [
                          if (query.isNotEmpty)
                            IconButton(
                              tooltip: l10n.clearSearch,
                              onPressed: _clearQuery,
                              icon: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHigh,
                                fixedSize: const Size(32, 32),
                                minimumSize: Size.zero,
                                padding: EdgeInsets.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(left: 3, right: 2),
                            child: IconButton(
                              tooltip: l10n.navSearch,
                              onPressed: _submit,
                              icon: const Icon(Icons.arrow_forward_rounded,
                                  size: 18),
                              style: IconButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                fixedSize: const Size(32, 32),
                                minimumSize: Size.zero,
                                padding: EdgeInsets.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ],
                        onChanged: _onSearchQueryChanged,
                        onSubmitted: (_) => _submit(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              PillTabs(
                controller: _modeController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                tabs: [
                  Tab(text: l10n.searchSuggestionsTitle),
                  Tab(
                    text: advancedCount > 0
                        ? '${l10n.advancedSearch} ($advancedCount)'
                        : l10n.advancedSearch,
                  ),
                ],
              ),
              Expanded(
                child: SwipeableTabView(
                  controller: _modeController,
                  children: [
                    ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      children: [
                        _SuggestionsTab(
                          vm: _vm,
                          onSearch: (value) => _submit(value),
                          onTestMirrors: () =>
                              unawaited(_runMirrorLatencyTest()),
                          onManageSources: widget.onManageSources,
                        ),
                      ],
                    ),
                    ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      children: [
                        _AdvancedSearchTab(
                          vm: _vm,
                          onApply: () => _submit(),
                          onReset: _resetFilters,
                          onManageSources: widget.onManageSources,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _typeFilterLabel(AppLocalizations l10n, String value) {
  return switch (value) {
    'All' => l10n.filterAll,
    'Any Books' => l10n.typeAnyBooks,
    'Unknown Books' => l10n.typeUnknownBooks,
    'Fiction Books' => l10n.typeFictionBooks,
    'Non-fiction Books' => l10n.typeNonfictionBooks,
    'Comic Books' => l10n.typeComicBooks,
    'Magazine' => l10n.typeMagazine,
    'Standards Document' => l10n.typeStandardsDocument,
    'Journal Article' => l10n.typeJournalArticle,
    _ => value,
  };
}

String _sortFilterLabel(AppLocalizations l10n, String value) {
  return switch (value) {
    'Most Relevant' => l10n.sortMostRelevant,
    'Newest' => l10n.sortNewest,
    'Oldest' => l10n.sortOldest,
    'Largest' => l10n.sortLargest,
    'Smallest' => l10n.sortSmallest,
    _ => value,
  };
}

String _fileTypeFilterLabel(AppLocalizations l10n, String value) {
  return value == 'All' ? l10n.filterAll : value.toUpperCase();
}

String _yearFilterLabel(AppLocalizations l10n, String value) {
  return switch (value) {
    'All' => l10n.filterAll,
    'Before 1980' => l10n.yearBefore1980,
    _ => value,
  };
}

String _languageFilterLabel(AppLocalizations l10n, String value) {
  return switch (value) {
    'All' => l10n.filterAll,
    'English' => l10n.langEnglish,
    'Spanish' => l10n.langSpanish,
    'French' => l10n.langFrench,
    'German' => l10n.langGerman,
    'Italian' => l10n.langItalian,
    'Portuguese' => l10n.langPortuguese,
    'Russian' => l10n.langRussian,
    'Chinese' => l10n.langChinese,
    'Japanese' => l10n.langJapanese,
    'Korean' => l10n.langKorean,
    'Arabic' => l10n.langArabic,
    'Hindi' => l10n.langHindi,
    'Malayalam' => l10n.langMalayalam,
    'Dutch' => l10n.langDutch,
    'Polish' => l10n.langPolish,
    'Turkish' => l10n.langTurkish,
    'Swedish' => l10n.langSwedish,
    'Indonesian' => l10n.langIndonesian,
    'Vietnamese' => l10n.langVietnamese,
    'Czech' => l10n.langCzech,
    'Greek' => l10n.langGreek,
    'Romanian' => l10n.langRomanian,
    'Hungarian' => l10n.langHungarian,
    'Ukrainian' => l10n.langUkrainian,
    'Hebrew' => l10n.langHebrew,
    'Thai' => l10n.langThai,
    'Persian' => l10n.langPersian,
    'Bengali' => l10n.langBengali,
    'Finnish' => l10n.langFinnish,
    'Norwegian' => l10n.langNorwegian,
    'Danish' => l10n.langDanish,
    _ => value,
  };
}

/// MD3 filter chip that opens a single-choice bottom sheet. Keeping the
/// current value in the chip label makes the active filters visible
/// without the five oversized dropdown fields the old page used.
Future<String?> _showFilterSheet({
  required BuildContext context,
  required String title,
  required List<String> options,
  required String value,
  required String Function(String) display,
}) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final theme = Theme.of(context);
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Text(title, style: theme.textTheme.titleMedium),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = option == value;
                  return ListTile(
                    title: Text(display(option)),
                    trailing: isSelected
                        ? Icon(Icons.check, color: theme.colorScheme.primary)
                        : null,
                    selected: isSelected,
                    onTap: () => Navigator.pop(context, option),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _AdvancedValueField extends StatelessWidget {
  const _AdvancedValueField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SwissRadius.field),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 2, 8, 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: SwissText.badge.copyWith(color: scheme.outline),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SwissText.caption.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.expand_more_rounded,
                    size: 16,
                    color: scheme.outline,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdvancedTextField extends StatelessWidget {
  const _AdvancedTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(SwissRadius.field),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: SwissText.badge.copyWith(color: scheme.outline),
          ),
          const SizedBox(height: 2),
          TextField(
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.next,
            style: SwissText.caption.copyWith(
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              hintText: hint,
              hintStyle: SwissText.caption.copyWith(color: scheme.outline),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectableFilterChip extends StatelessWidget {
  const _SelectableFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SizedBox(
      height: 32,
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
        backgroundColor: scheme.surface,
        selectedColor: scheme.primaryContainer,
        side: BorderSide(
          color: selected ? Colors.transparent : scheme.outlineVariant,
        ),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        labelPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        labelStyle: SwissText.micro.copyWith(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _FilterSectionLabel extends StatelessWidget {
  const _FilterSectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: SwissText.micro.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.66,
      ),
    );
  }
}

class _AdvancedSearchTab extends StatefulWidget {
  const _AdvancedSearchTab({
    required this.vm,
    required this.onApply,
    required this.onReset,
    required this.onManageSources,
  });

  final SearchViewModel vm;
  final VoidCallback onApply;
  final VoidCallback onReset;
  final VoidCallback? onManageSources;

  @override
  State<_AdvancedSearchTab> createState() => _AdvancedSearchTabState();
}

class _AdvancedSearchTabState extends State<_AdvancedSearchTab> {
  late final TextEditingController _authorController;
  late final TextEditingController _publisherController;

  @override
  void initState() {
    super.initState();
    _authorController = TextEditingController(text: widget.vm.author);
    _publisherController = TextEditingController(text: widget.vm.publisher);
  }

  @override
  void dispose() {
    _authorController.dispose();
    _publisherController.dispose();
    super.dispose();
  }

  Future<void> _pickType() async {
    final l10n = AppLocalizations.of(context);
    final selected = await _showFilterSheet(
      context: context,
      title: l10n.filterTypeLabel,
      options: typeValues.keys.toList(),
      value: widget.vm.filters.type,
      display: (value) => _typeFilterLabel(l10n, value),
    );
    if (selected == null) return;
    widget.vm.setFilter(SearchFilterKind.type, selected);
  }

  Future<void> _pickYear() async {
    final l10n = AppLocalizations.of(context);
    final selected = await _showFilterSheet(
      context: context,
      title: l10n.filterYearLabel,
      options: yearValues,
      value: widget.vm.filters.year,
      display: (value) => _yearFilterLabel(l10n, value),
    );
    if (selected == null) return;
    widget.vm.setFilter(SearchFilterKind.year, selected);
  }

  Future<void> _pickLanguage() async {
    final l10n = AppLocalizations.of(context);
    final selected = await _showFilterSheet(
      context: context,
      title: l10n.languageSetting,
      options: languageValues.keys.toList(),
      value: widget.vm.filters.language,
      display: (value) => _languageFilterLabel(l10n, value),
    );
    if (selected == null) return;
    widget.vm.setFilter(SearchFilterKind.language, selected);
  }

  void _reset() {
    _authorController.clear();
    _publisherController.clear();
    widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final filters = widget.vm.filters;
    final typeValue = filters.type;
    final sortValue = filters.sort;
    final fileTypeValue = filters.fileType;
    final languageValue = filters.language;
    final yearValue = filters.year;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          key: const ValueKey('advanced-search-card'),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(SwissRadius.card),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SearchSourceSelector(
                vm: widget.vm,
                horizontal: true,
                onManageSources: widget.onManageSources,
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = (constraints.maxWidth - 8) / 2;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SizedBox(
                        width: width,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 48),
                          child: _AdvancedTextField(
                            controller: _authorController,
                            label: l10n.author,
                            hint: l10n.anyValue,
                            onChanged: (value) =>
                                widget.vm.setAuthor(value.trim()),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 48),
                          child: _AdvancedTextField(
                            controller: _publisherController,
                            label: l10n.publisher,
                            hint: l10n.anyValue,
                            onChanged: (value) =>
                                widget.vm.setPublisher(value.trim()),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 48),
                          child: _AdvancedValueField(
                            label: l10n.publishedYearLabel,
                            value: _yearFilterLabel(l10n, yearValue),
                            onTap: _pickYear,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 48),
                          child: _AdvancedValueField(
                            label: l10n.languageSetting,
                            value: _languageFilterLabel(l10n, languageValue),
                            onTap: _pickLanguage,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _FilterSectionLabel(title: l10n.filterFileTypeLabel),
                  const Spacer(),
                  Flexible(
                    child: TextButton(
                      onPressed: _pickType,
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        '${l10n.filterTypeLabel}: ${_typeFilterLabel(l10n, typeValue)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: SwissText.micro.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final value in fileType)
                    _SelectableFilterChip(
                      label: _fileTypeFilterLabel(l10n, value),
                      selected: fileTypeValue == value,
                      onTap: () {
                        widget.vm.setFilter(SearchFilterKind.fileType, value);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _FilterSectionLabel(title: l10n.filterSortLabel),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final value in sortValues.keys)
                    _SelectableFilterChip(
                      label: _sortFilterLabel(l10n, value),
                      selected: sortValue == value,
                      onTap: () {
                        widget.vm.setFilter(SearchFilterKind.sort, value);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            OutlinedButton(
              onPressed: _reset,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                textStyle: SwissText.label,
              ),
              child: Text(l10n.resetFilters),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: FilledButton.icon(
                onPressed: widget.onApply,
                icon: const Icon(Icons.search_rounded, size: 18),
                label: Text(l10n.searchApply),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  textStyle:
                      SwissText.label.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SuggestionsTab extends StatelessWidget {
  const _SuggestionsTab({
    required this.vm,
    required this.onSearch,
    required this.onTestMirrors,
    required this.onManageSources,
  });

  final SearchViewModel vm;
  final ValueChanged<String> onSearch;
  final VoidCallback onTestMirrors;
  final VoidCallback? onManageSources;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final trimmed = vm.query.trim();
    if (trimmed.isEmpty) {
      final showLatencyHint = shouldShowMirrorLatencyHint(
        vm.mirrorLatency,
        DateTime.now(),
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SearchSourceSelector(
            vm: vm,
            onManageSources: onManageSources,
          ),
          if (showLatencyHint) ...[
            const SizedBox(height: 12),
            MirrorLatencyHint(
              show: true,
              testing: vm.mirrorLatency.testing,
              onTest: onTestMirrors,
            ),
          ],
          _RecentSearchesSection(vm: vm, onSearch: onSearch),
          _TryTheseSection(trending: vm.trending, onSearch: onSearch),
          const SizedBox(height: 16),
          InlineHint(message: l10n.searchSupportHint),
        ],
      );
    }
    return _InlineSuggestions(vm: vm, onSearch: onSearch);
  }
}

class _InlineSuggestions extends StatelessWidget {
  const _InlineSuggestions({required this.vm, required this.onSearch});

  final SearchViewModel vm;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final query = vm.query.trim();
    final suggestions = vm.suggestions;
    final loading = vm.suggestionsLoading;
    final selected = vm.selectedSource;
    final enabled = vm.enabledProviders;
    final order = vm.sourceOrder;
    final chain = order
        .where((source) => enabled.contains(source))
        .toList(growable: false);
    final restricted =
        selected != null && enabled.contains(selected) ? selected : null;
    final visible = suggestions.take(4).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(SwissRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 12,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          restricted == null
                              ? l10n.searchAutoScope(chain.length)
                              : l10n.searchSourceOnlyScope(
                                  sourceShortLabel(l10n, restricted),
                                ),
                          style: SwissText.badge.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      restricted == null
                          ? l10n.resultsAutoMerged
                          : l10n.searchSourceOnlyHint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: SwissText.micro.copyWith(color: scheme.outline),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    l10n.searchSuggestionsTitle,
                    style: SwissText.micro.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  if (loading)
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: scheme.primary,
                      ),
                    )
                  else
                    Text(
                      l10n.searchSuggestionsLive,
                      style: SwissText.micro.copyWith(color: scheme.outline),
                    ),
                ],
              ),
              if (loading) ...[
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: scheme.surfaceContainerHigh,
                  ),
                ),
              ],
              const SizedBox(height: 2),
              for (var index = 0; index < visible.length; index++) ...[
                if (index > 0)
                  Divider(
                    height: 1,
                    color: scheme.outlineVariant.withValues(alpha: 0.55),
                  ),
                _InlineSuggestionRow(
                  text: visible[index],
                  query: query,
                  onTap: () => onSearch(visible[index]),
                ),
              ],
              const SizedBox(height: 10),
              _InlineSearchAction(
                label: restricted == null
                    ? l10n.searchInAllSources(query)
                    : l10n.searchInSource(
                        query,
                        sourceLabel(l10n, restricted),
                      ),
                onTap: () => onSearch(query),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        InlineHint(
          icon: Icons.tune_rounded,
          message: l10n.searchAdvancedHint,
        ),
      ],
    );
  }
}

class _InlineSuggestionRow extends StatelessWidget {
  const _InlineSuggestionRow({
    required this.text,
    required this.query,
    required this.onTap,
  });

  final String text;
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SwissRadius.xs),
      child: SizedBox(
        height: 48,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(Icons.search_rounded, size: 16, color: scheme.outline),
              const SizedBox(width: 8),
              Expanded(
                child: _HighlightedQuery(
                  text: text,
                  query: query,
                  style: SwissText.caption.copyWith(color: scheme.onSurface),
                  highlightStyle: SwissText.caption.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(Icons.north_east_rounded, size: 16, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightedQuery extends StatelessWidget {
  const _HighlightedQuery({
    required this.text,
    required this.query,
    required this.style,
    required this.highlightStyle,
  });

  final String text;
  final String query;
  final TextStyle? style;
  final TextStyle highlightStyle;

  @override
  Widget build(BuildContext context) {
    final clean = query.trim();
    if (clean.isEmpty) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }
    final lower = text.toLowerCase();
    final lowerQuery = clean.toLowerCase();
    final spans = <TextSpan>[];
    var index = 0;
    while (index < text.length) {
      final match = lower.indexOf(lowerQuery, index);
      if (match < 0) {
        spans.add(TextSpan(text: text.substring(index)));
        break;
      }
      if (match > index) {
        spans.add(TextSpan(text: text.substring(index, match)));
      }
      spans.add(TextSpan(
        text: text.substring(match, match + clean.length),
        style: highlightStyle,
      ));
      index = match + clean.length;
    }
    return Text.rich(
      TextSpan(style: style, children: spans),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _InlineSearchAction extends StatelessWidget {
  const _InlineSearchAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.primaryContainer,
      borderRadius: BorderRadius.circular(SwissRadius.field),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    size: 16,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SwissText.micro.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: scheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentSearchesSection extends StatelessWidget {
  const _RecentSearchesSection({required this.vm, required this.onSearch});

  final SearchViewModel vm;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final recents = vm.recentSearches.take(3).toList();
    if (recents.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l10n.recentSearchesTitle,
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
          action: TextButton(
            onPressed: vm.clearRecents,
            style: TextButton.styleFrom(
              foregroundColor: scheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              l10n.clearAll,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        for (var index = 0; index < recents.length; index++) ...[
          _RecentSearchRow(
            text: recents[index],
            subtitle: l10n.searchAllSourcesLabel,
            removeTooltip: l10n.removeRecentSearch(recents[index]),
            onTap: () => onSearch(recents[index]),
            onRemove: () => vm.removeRecent(recents[index]),
          ),
          if (index < recents.length - 1)
            Divider(
              height: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.55),
            ),
        ],
      ],
    );
  }
}

class _RecentSearchRow extends StatelessWidget {
  const _RecentSearchRow({
    required this.text,
    required this.subtitle,
    required this.removeTooltip,
    required this.onTap,
    required this.onRemove,
  });

  final String text;
  final String subtitle;
  final String removeTooltip;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 0, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SwissText.label,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SwissText.micro.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              tooltip: removeTooltip,
              icon: Icon(Icons.close_rounded, size: 15),
              style: IconButton.styleFrom(
                foregroundColor: scheme.onSurfaceVariant,
                fixedSize: const Size(32, 32),
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TryTheseSection extends StatelessWidget {
  const _TryTheseSection({required this.trending, required this.onSearch});

  final List<TrendingBookData> trending;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final suggestions = <String>[];
    for (final book in trending) {
      final title = book.title?.trim();
      if (title != null && title.isNotEmpty && !suggestions.contains(title)) {
        suggestions.add(title);
      }
      if (suggestions.length == 4) break;
    }
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tryThese,
            style: SwissText.micro.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final half = (constraints.maxWidth - 8) / 2;
              final maxWidth = half < 220 ? half : 220.0;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final suggestion in suggestions)
                    _QueryChip(
                      label: suggestion,
                      maxWidth: maxWidth,
                      onTap: () => onSearch(suggestion),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QueryChip extends StatelessWidget {
  const _QueryChip({
    required this.label,
    required this.maxWidth,
    required this.onTap,
  });

  final String label;
  final double maxWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surface,
      shape: StadiumBorder(side: BorderSide(color: scheme.outlineVariant)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SizedBox(
            height: 32,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SwissText.micro.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchSourceSelector extends StatelessWidget {
  const _SearchSourceSelector({
    required this.vm,
    this.onManageSources,
    this.horizontal = false,
  });

  final SearchViewModel vm;
  final VoidCallback? onManageSources;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    if (!vm.sourcesLoaded) return const SizedBox.shrink();

    final selected = vm.selectedSource;
    final effective =
        selected != null && vm.enabledProviders.contains(selected)
            ? selected
            : null;
    final sources = vm.sourceOrder
        .where((source) => vm.enabledProviders.contains(source))
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.searchSourcesTitle,
                style: SwissText.micro.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.66,
                ),
              ),
            ),
            TextButton(
              onPressed: () => onManageSources?.call(),
              style: TextButton.styleFrom(
                foregroundColor: scheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.settingsManage,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (horizontal)
          EdgeFade(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _SourceChoiceChip(
                    mark: l10n.sourceMarkAll,
                    label: l10n.searchSourceAuto,
                    selected: effective == null,
                    onTap: () => vm.selectSource(null),
                  ),
                  for (final source in sources) ...[
                    const SizedBox(width: 8),
                    _SourceChoiceChip(
                      mark: sourceMark(source),
                      label: sourceShortLabel(l10n, source),
                      selected: effective == source,
                      onTap: () => vm.selectSource(source),
                    ),
                  ],
                ],
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SourceChoiceChip(
                mark: l10n.sourceMarkAll,
                label: l10n.searchSourceAuto,
                selected: effective == null,
                onTap: () => vm.selectSource(null),
              ),
              for (final source in sources)
                _SourceChoiceChip(
                  mark: sourceMark(source),
                  label: sourceShortLabel(l10n, source),
                  selected: effective == source,
                  onTap: () => vm.selectSource(source),
                ),
            ],
          ),
      ],
    );
  }
}

class _SourceChoiceChip extends StatelessWidget {
  const _SourceChoiceChip({
    required this.mark,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String mark;
  final String label;
  final bool selected;
  final VoidCallback onTap;

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
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 32,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? scheme.onPrimary.withValues(alpha: 0.16)
                        : scheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(SwissRadius.xs),
                  ),
                  child: Text(
                    mark,
                    style: SwissText.badge.copyWith(
                      color:
                          selected ? scheme.onPrimary : scheme.onSurfaceVariant,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: SwissText.micro.copyWith(
                    color:
                        selected ? scheme.onPrimary : scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
