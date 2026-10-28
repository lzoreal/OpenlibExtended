// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:openlib/app/app_settings.dart';
import 'package:openlib/data/models/search_filters.dart';
import 'package:openlib/data/models/search_result.dart';
import 'package:openlib/data/models/trending_book_data.dart';
import 'package:openlib/data/repositories/mirror_repository.dart';
import 'package:openlib/data/repositories/preferences_repository.dart';
import 'package:openlib/data/repositories/search_repository.dart';
import 'package:openlib/data/repositories/trending_repository.dart';
import 'package:openlib/data/services/google_suggest_api.dart';
import 'package:openlib/data/services/instance_manager.dart';
import 'package:openlib/data/services/mirror_latency_controller.dart';
import 'package:openlib/data/services/recent_searches.dart';
import 'package:openlib/data/services/search_manager.dart';

/// Owns the search page's transient state. Filter values, author and
/// publisher stay in [AppSettings] because the results page reads them too.
class SearchViewModel extends ChangeNotifier {
  SearchViewModel({
    required SearchRepository search,
    required PreferencesRepository preferences,
    required AppSettings settings,
    required MirrorRepository mirrors,
    required MirrorLatencyNotifier mirrorLatency,
    required TrendingRepository trending,
    RecentSearchStore? recentStore,
    GoogleSuggestApi? suggestionsApi,
    DateTime Function()? clock,
  })  : _search = search,
        _preferences = preferences,
        _settings = settings,
        _mirrors = mirrors,
        _mirrorLatency = mirrorLatency,
        _trendingRepository = trending,
        _recentStore = recentStore ?? DbRecentSearchStore(),
        _suggestionsApi = suggestionsApi ?? GoogleSuggestApi() {
    _recentsReady = _loadRecents();
    _latencyState = _mirrorLatency.state;
    _settings.addListener(_notify);
    _mirrorLatency.addListener(_onMirrorLatencyChanged);
  }

  static const Duration _suggestionDebounce = Duration(milliseconds: 420);

  final SearchRepository _search;
  final PreferencesRepository _preferences;
  final AppSettings _settings;
  final MirrorRepository _mirrors;
  final MirrorLatencyNotifier _mirrorLatency;
  final TrendingRepository _trendingRepository;
  final RecentSearchStore _recentStore;
  final GoogleSuggestApi _suggestionsApi;

  String _query = '';
  SearchProviderId? _selectedSource;
  Set<SearchProviderId> _enabledProviders = SearchProviderId.values.toSet();
  List<SearchProviderId> _sourceOrder = defaultSearchSourceOrder;
  bool _sourcesLoaded = false;
  List<TrendingBookData> _trending = const [];
  List<String> _suggestions = const [];
  bool _suggestionsLoading = false;
  List<String> _recentSearches = const [];
  // StateNotifier.state is protected; the listener keeps a readable copy.
  MirrorLatencyState _latencyState = const MirrorLatencyState();
  bool _loadStarted = false;
  bool _disposed = false;
  bool _mirrorTestStarting = false;
  late final Future<void> _recentsReady;
  Timer? _debounce;
  int _suggestionRequest = 0;

  String get query => _query;

  String get author => _settings.searchAuthor;

  String get publisher => _settings.searchPublisher;

  SearchFilters get filters => _settings.filters;

  bool get filtersEnabled => _settings.filtersEnabled;

  SearchProviderId? get selectedSource => _selectedSource;

  Set<SearchProviderId> get enabledProviders => _enabledProviders;

  List<SearchProviderId> get sourceOrder => _sourceOrder;

  bool get sourcesLoaded => _sourcesLoaded;

  List<TrendingBookData> get trending => _trending;

  List<String> get suggestions => _suggestions;

  bool get suggestionsLoading => _suggestionsLoading;

  List<String> get recentSearches => _recentSearches;

  MirrorLatencyState get mirrorLatency => _latencyState;

  int get advancedFilterCount => [
        _settings.searchAuthor.isNotEmpty,
        _settings.searchPublisher.isNotEmpty,
        filters.type != 'All',
        filters.sort != 'Most Relevant',
        filters.fileType != 'All',
        filters.language != 'All',
        filters.year != 'All',
      ].where((active) => active).length;

  Future<void> load() async {
    if (_loadStarted) return;
    _loadStarted = true;
    await Future.wait([
      _recentsReady,
      _loadSources(),
      _loadTrending(),
      _loadMirrorLatency(),
    ]);
  }

  Future<void> _loadRecents() async {
    try {
      final loaded = await _recentStore.load();
      if (_disposed) return;
      _recentSearches = List<String>.of(loaded);
      _notify();
    } catch (_) {
      // History is a convenience; the page renders without it.
    }
  }

  Future<void> _loadSources() async {
    try {
      final enabled = await _search.enabledProviders();
      final order = await _search.sourceOrder();
      if (_disposed) return;
      _enabledProviders = enabled;
      _sourceOrder = order;
      _sourcesLoaded = true;
      _notify();
    } catch (_) {
      // Keep the all-sources/shipped-order fallbacks; the selector stays
      // hidden just like the old provider's error branch.
    }
  }

  Future<void> _loadTrending() async {
    try {
      final books = await _trendingRepository.trendingBooks();
      if (_disposed) return;
      // The trending provider shuffles too; keep "Try these" varied.
      _trending = List<TrendingBookData>.of(books)..shuffle();
    } catch (_) {
      if (_disposed) return;
      _trending = const [];
    }
    _notify();
  }

  Future<void> _loadMirrorLatency() async {
    try {
      await _mirrorLatency.load();
    } catch (_) {
      // Readings are optional; without them the hint simply stays hidden.
    }
  }

  void updateQuery(String value) {
    _query = value;
    if (_disposed) return;
    _debounce?.cancel();
    _debounce = null;
    // Drop suggestions from the previous query before the new ones arrive.
    _suggestions = const [];
    if (value.trim().isEmpty) {
      _suggestionRequest++;
      _suggestionsLoading = false;
    } else {
      _debounce = Timer(_suggestionDebounce, () {
        unawaited(_fetchSuggestions(value));
      });
    }
    _notify();
  }

  void clearQuery() {
    if (_disposed) return;
    _query = '';
    _debounce?.cancel();
    _debounce = null;
    _suggestionRequest++;
    _suggestions = const [];
    _suggestionsLoading = false;
    _notify();
  }

  Future<void> _fetchSuggestions(String raw) async {
    final clean = raw.trim();
    if (clean.isEmpty || _disposed) return;
    final request = ++_suggestionRequest;
    _suggestionsLoading = true;
    _notify();
    final List<String> fetched;
    try {
      fetched = await _suggestionsApi.fetchSuggestions(clean);
    } catch (_) {
      if (_disposed || request != _suggestionRequest) return;
      _suggestionsLoading = false;
      _notify();
      return;
    }
    if (_disposed || request != _suggestionRequest) return;
    final seen = <String>{};
    final cleaned = <String>[];
    for (final suggestion in fetched) {
      if (suggestion == 'Suggestion Error' ||
          suggestion == 'Network Error' ||
          suggestion.trim().isEmpty) {
        continue;
      }
      if (seen.add(suggestion)) cleaned.add(suggestion);
    }
    _suggestions = List<String>.unmodifiable(cleaned);
    _suggestionsLoading = false;
    _notify();
  }

  void selectSource(SearchProviderId? source) {
    _selectedSource = source;
    _notify();
  }

  void setFilter(SearchFilterKind kind, String value) {
    _settings.setFilter(kind, value);
    unawaited(_preferences.saveSearchFilter(kind, value));
  }

  void setAuthor(String value) {
    _settings.setSearchAuthor(value);
  }

  void setPublisher(String value) {
    _settings.setSearchPublisher(value);
  }

  void resetFilters() {
    _settings.resetSearchFilters();
    unawaited(_preferences.resetSearchFilters());
  }

  Future<String?> prepareSearch([String? value]) async {
    final trimmed = (value ?? _query).trim();
    if (trimmed.isEmpty) return null;
    await _recentsReady;
    _debounce?.cancel();
    _debounce = null;
    _suggestionRequest++;
    _query = trimmed;
    final next = withRecentSearch(_recentSearches, trimmed);
    if (!listEquals(next, _recentSearches)) {
      _recentSearches = next;
      unawaited(_recentStore.save(next));
    }
    _settings.setFiltersEnabled(true);
    _notify();
    return trimmed;
  }

  Future<MirrorLatencyResult> testMirrorLatency() async {
    if (_mirrorTestStarting || _latencyState.testing) {
      return const MirrorLatencyResult(
        total: 0,
        reachable: 0,
        fastestMs: null,
      );
    }
    _mirrorTestStarting = true;
    try {
      final views = <InstanceView>[];
      for (final service in MirrorService.values) {
        views.addAll(await _mirrors.instances(service));
      }
      return await _mirrorLatency.test(views);
    } finally {
      _mirrorTestStarting = false;
    }
  }

  void removeRecent(String query) {
    final next = withoutRecentSearch(_recentSearches, query);
    if (listEquals(next, _recentSearches)) return;
    _recentSearches = next;
    _notify();
    unawaited(_recentStore.save(next));
  }

  void clearRecents() {
    if (_recentSearches.isEmpty) return;
    _recentSearches = const [];
    _notify();
    unawaited(_recentStore.save(const []));
  }

  void _onMirrorLatencyChanged() {
    _latencyState = _mirrorLatency.state;
    _notify();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    _debounce = null;
    _suggestionRequest++;
    _settings.removeListener(_notify);
    _mirrorLatency.removeListener(_onMirrorLatencyChanged);
    super.dispose();
  }
}
