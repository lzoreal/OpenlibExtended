// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:openlib/app/app_settings.dart';
import 'package:openlib/app/di.dart';
import 'package:openlib/data/models/book_data.dart';
import 'package:openlib/data/models/search_filters.dart';
import 'package:openlib/data/models/search_result.dart';
import 'package:openlib/data/repositories/cover_repository.dart';
import 'package:openlib/data/repositories/library_repository.dart';
import 'package:openlib/data/repositories/preferences_repository.dart';
import 'package:openlib/data/repositories/search_repository.dart';
import 'package:openlib/data/services/search_manager.dart';
import 'package:openlib/state/results_pager.dart';
import 'package:openlib/state/state.dart'
    show languageValues, sortValues, typeValues;
import 'package:openlib/ui/core/components/book_card_widget.dart'
    show getFileType, getLanguage;

/// Sort choices the results sheet offers, in display order.
const List<String> resultSortValues = [
  'Most Relevant',
  'Newest',
  'Oldest',
  'Largest',
  'Smallest',
];

const SearchManagerResult _emptyResult =
    SearchManagerResult(books: [], failedProviders: []);

/// Owns one results route: the streamed page one, the merge/pagination
/// cursors, the local filters and the lazily resolved covers.
class ResultsViewModel extends ChangeNotifier {
  ResultsViewModel({
    required String query,
    SearchProviderId? source,
    required SearchRepository search,
    required AppSettings settings,
    required PreferencesRepository preferences,
    required LibraryRepository library,
    required CoverRepository covers,
  })  : _query = query,
        _search = search,
        _settings = settings,
        _preferences = preferences,
        _library = library,
        _covers = covers,
        _pager = ResultsPager(routeSource: source);

  factory ResultsViewModel.fromDi({
    required String query,
    SearchProviderId? source,
  }) {
    return ResultsViewModel(
      query: query,
      source: source,
      search: getIt<SearchRepository>(),
      settings: getIt<AppSettings>(),
      preferences: getIt<PreferencesRepository>(),
      library: getIt<LibraryRepository>(),
      covers: getIt<CoverRepository>(),
    );
  }

  final String _query;
  final SearchRepository _search;
  final AppSettings _settings;
  final PreferencesRepository _preferences;
  final LibraryRepository _library;
  final CoverRepository _covers;
  final ResultsPager _pager;
  final Set<String> _formatFilters = {};
  final Set<String> _languageFilters = {};

  StreamSubscription<SearchManagerResult>? _subscription;
  Set<SearchProviderId> _enabledSources = defaultSearchSourceOrder.toSet();
  List<SearchProviderId> _sourceOrder = defaultSearchSourceOrder;
  Set<String> _downloadedIds = const {};
  bool _loading = true;
  bool _retrying = false;
  bool _forceLocalTimeouts = false;
  bool _disposed = false;
  Object? _error;
  StackTrace? _errorStackTrace;

  SearchManagerResult? get firstResult => _pager.firstResult;

  SearchProviderId? get selectedSource => _pager.selectedSource;

  /// The current view (merged or one source), pagination included.
  List<BookData> get books => _pager.booksFor(_pager.selectedSource);

  /// The merged view regardless of the current selection, for the total
  /// shown on the source card.
  List<BookData> get allBooks => _pager.booksFor(null);

  List<SearchSourceRun> get sources =>
      _pager.firstResult?.sources ?? const <SearchSourceRun>[];

  Set<String> get downloadedIds => _downloadedIds;

  Set<String> get formatFilters => Set.unmodifiable(_formatFilters);

  Set<String> get languageFilters => Set.unmodifiable(_languageFilters);

  /// [books] narrowed by the local format/language pills.
  List<BookData> get visibleBooks => <BookData>[
        for (final book in books)
          if (_formatFilters.isEmpty ||
              _formatFilters.contains(getFileType(book.info)?.toUpperCase()))
            if (_languageFilters.isEmpty ||
                _languageFilters.contains(getLanguage(book.info)))
              book,
      ];

  List<String> get availableFormats {
    return <String>{
      for (final book in books)
        if (getFileType(book.info) != null)
          getFileType(book.info)!.toUpperCase(),
    }.toList()
      ..sort((a, b) {
        const order = ['EPUB', 'PDF'];
        final aIndex = order.indexOf(a);
        final bIndex = order.indexOf(b);
        if (aIndex == -1 && bIndex == -1) return a.compareTo(b);
        if (aIndex == -1) return 1;
        if (bIndex == -1) return -1;
        return aIndex.compareTo(bIndex);
      });
  }

  List<String> get availableLanguages {
    return <String>{
      for (final book in books)
        if (getLanguage(book.info) != null) getLanguage(book.info)!,
    }.toList()
      ..sort();
  }

  String get sortValue => _settings.filters.sort;

  bool get fetchingNextPage => _pager.fetchingNextPage;

  bool get currentViewEnded => _pager.currentViewEnded;

  bool get forceLocalTimeouts => _forceLocalTimeouts;

  bool get retrying => _retrying;

  bool get loading => _loading;

  Object? get error => _error;

  StackTrace? get errorStackTrace => _errorStackTrace;

  List<SearchProviderId> get enabledSources =>
      List<SearchProviderId>.unmodifiable(_enabledSources);

  List<SearchProviderId> get sourceOrder =>
      List<SearchProviderId>.unmodifiable(_sourceOrder);

  Future<void> start() async {
    _subscribe();
    await Future.wait([_loadDownloadedIds(), _loadSources()]);
  }

  /// Refreshes the "downloaded" badges, e.g. after returning from a detail
  /// page where the book was downloaded or deleted.
  Future<void> refreshDownloadedIds() => _loadDownloadedIds();

  Future<void> _loadDownloadedIds() async {
    try {
      final books = await _library.allBooks();
      if (_disposed) return;
      _downloadedIds = books.map((book) => book.id).toSet();
      _notify();
    } catch (_) {
      // The downloaded badge is a convenience; the list renders without it.
    }
  }

  Future<void> _loadSources() async {
    try {
      final enabled = await _search.enabledProviders();
      final order = await _search.sourceOrder();
      if (_disposed) return;
      _enabledSources = enabled;
      _sourceOrder = order;
      _notify();
    } catch (_) {
      // Keep the shipped fallback; the source sheet stays usable.
    }
  }

  void _subscribe() {
    _subscription?.cancel();
    _subscription = null;
    _loading = true;
    _error = null;
    _errorStackTrace = null;
    if (_query.isEmpty) {
      _pager.applyInitial(_emptyResult);
      _loading = false;
      _notify();
      return;
    }
    _notify();
    // Page one always queries every enabled source; [source] only picks
    // which view the route opens on.
    _subscription = _search
        .watch(_buildQuery(page: 1), forceLocalTimeouts: _forceLocalTimeouts)
        .listen(_applyResult, onError: _applyError);
  }

  void _applyResult(SearchManagerResult result) {
    if (_disposed) return;
    if (_pager.firstResult == null) {
      _pager.applyInitial(result);
    } else {
      _pager.merge(result);
    }
    _loading = false;
    _error = null;
    _errorStackTrace = null;
    _notify();
  }

  void _applyError(Object error, StackTrace stackTrace) {
    if (_disposed) return;
    _error = error;
    _errorStackTrace = stackTrace;
    _loading = false;
    _notify();
  }

  SearchQuery _buildQuery({required int page, SearchProviderId? source}) {
    final filters = _settings.filters;
    return SearchQuery(
      text: _query,
      content: typeValues[filters.type] ?? '',
      sort: sortValues[filters.sort] ?? '',
      fileType: filters.fileType == 'All' ? '' : filters.fileType.toLowerCase(),
      language: languageValues[filters.language] ?? '',
      year: filters.year == 'All' ? '' : filters.year,
      author: _settings.searchAuthor,
      publisher: _settings.searchPublisher,
      filtersEnabled: _settings.filtersEnabled,
      page: page,
      source: source,
    );
  }

  Future<void> loadNextPage() async {
    if (_disposed || _pager.fetchingNextPage || _pager.currentViewEnded) return;
    final view = _pager.selectedSource;
    final nextPage = _pager.pageOf(view) + 1;
    _pager.fetchingNextPage = true;
    _notify();
    try {
      final source =
          view != null && _enabledSources.contains(view) ? view : null;
      final result = _query.isEmpty
          ? _emptyResult
          : await _search.search(
              _buildQuery(page: nextPage, source: source),
              forceLocalTimeouts: _forceLocalTimeouts,
            );
      if (_disposed) return;
      _pager.appendPage(page: nextPage, view: view, result: result);
    } catch (_) {
      if (_disposed) return;
      _pager.fetchingNextPage = false;
    }
    _notify();
  }

  void selectSource(SearchProviderId? source) {
    if (_disposed || _pager.selectedSource == source) return;
    _pager.selectSource(source);
    _notify();
  }

  Future<void> retryPageOne() async {
    if (_disposed) return;
    _forceLocalTimeouts = false;
    _pager.reset();
    _subscribe();
  }

  Future<void> retryIgnoringLocalTimeouts() async {
    if (_disposed) return;
    _forceLocalTimeouts = true;
    _pager.reset();
    _subscribe();
  }

  Future<void> clearFiltersAndRetry() async {
    if (_disposed || _retrying) return;
    _retrying = true;
    _forceLocalTimeouts = false;
    _pager.reset();
    _settings.resetSearchFilters();
    _subscribe();
    unawaited(_persistFilterDefaults());
    _retrying = false;
    _notify();
  }

  Future<void> _persistFilterDefaults() async {
    try {
      await _preferences.resetSearchFilters();
    } catch (_) {
      // In-memory filters already reset; persistence is a convenience.
    }
  }

  Future<void> setSort(String value) async {
    if (_disposed || _settings.filters.sort == value) return;
    _settings.setFilter(SearchFilterKind.sort, value);
    await _preferences.saveSearchFilter(SearchFilterKind.sort, value);
    await retryPageOne();
  }

  void setFormatFilters(Set<String> value) {
    if (_disposed) return;
    _formatFilters
      ..clear()
      ..addAll(value);
    _notify();
  }

  void setLanguageFilters(Set<String> value) {
    if (_disposed) return;
    _languageFilters
      ..clear()
      ..addAll(value);
    _notify();
  }

  void clearLocalFilters() {
    if (_disposed) return;
    _formatFilters.clear();
    _languageFilters.clear();
    _notify();
  }

  Future<String?> coverFor(String link) => _covers.coverFor(link);

  bool isDownloaded(String? md5) => md5 != null && _downloadedIds.contains(md5);

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}
