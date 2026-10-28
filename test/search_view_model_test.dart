// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
import 'package:openlib/data/services/mirror_latency.dart';
import 'package:openlib/data/services/mirror_latency_controller.dart';
import 'package:openlib/data/services/recent_searches.dart';
import 'package:openlib/data/services/search_manager.dart';
import 'package:openlib/ui/features/search/view_models/search_view_model.dart';

class _FakeSearchRepository extends SearchRepository {
  _FakeSearchRepository({
    Set<SearchProviderId>? enabled,
    List<SearchProviderId>? order,
    this.failure,
  })  : enabled = enabled ?? SearchProviderId.values.toSet(),
        order = order ?? defaultSearchSourceOrder,
        super(manager: SearchManager(providers: const []));

  final Set<SearchProviderId> enabled;
  final List<SearchProviderId> order;
  final Object? failure;
  int enabledCalls = 0;
  int orderCalls = 0;

  @override
  Future<Set<SearchProviderId>> enabledProviders() async {
    enabledCalls++;
    if (failure != null) throw failure!;
    return enabled;
  }

  @override
  Future<List<SearchProviderId>> sourceOrder() async {
    orderCalls++;
    if (failure != null) throw failure!;
    return order;
  }
}

class _FakePreferences extends PreferencesRepository {
  final List<({SearchFilterKind kind, String value})> saved = [];
  int resets = 0;

  @override
  Future<void> saveSearchFilter(SearchFilterKind kind, String value) async {
    saved.add((kind: kind, value: value));
  }

  @override
  Future<void> resetSearchFilters() async {
    resets++;
  }
}

class _FakeMirror extends MirrorRepository {
  _FakeMirror({
    Map<MirrorService, List<InstanceView>>? views,
    Map<String, int?>? latency,
  })  : views = views ?? const {},
        latency = latency ?? const {};

  final Map<MirrorService, List<InstanceView>> views;
  final Map<String, int?> latency;
  final List<MirrorService> requestedServices = [];
  int measureCalls = 0;
  Future<Map<String, int?>> Function(Iterable<String>)? measureHandler;

  @override
  Future<List<InstanceView>> instances(MirrorService service,
      {bool force = false}) async {
    requestedServices.add(service);
    return views[service] ?? const [];
  }

  @override
  Future<Map<String, MirrorLatencyReading>> localLatencies() async => const {};

  @override
  Future<Map<String, int?>> measureLatency(Iterable<String> urls) {
    measureCalls++;
    return measureHandler?.call(urls) ?? Future.value(latency);
  }

  @override
  Future<void> saveLocalLatencies(Map<String, int?> results,
      {DateTime? testedAt}) async {}
}

class _FakeTrending extends TrendingRepository {
  _FakeTrending(this.books, {this.failure}) : super(sources: const []);

  final List<TrendingBookData> books;
  final Object? failure;
  int calls = 0;

  @override
  Future<List<TrendingBookData>> trendingBooks() async {
    calls++;
    if (failure != null) throw failure!;
    return books;
  }
}

class _MemoryRecentStore implements RecentSearchStore {
  _MemoryRecentStore([List<String> initial = const []])
      : stored = List<String>.of(initial);

  List<String> stored;
  int saves = 0;

  @override
  Future<List<String>> load() async => List<String>.of(stored);

  @override
  Future<void> save(List<String> searches) async {
    stored = List<String>.of(searches);
    saves++;
  }
}

class _FakeSuggestions extends GoogleSuggestApi {
  _FakeSuggestions([this.results = const []]);

  final List<String> results;
  final List<String> queries = [];
  Future<List<String>> Function(String query)? handler;

  @override
  Future<List<String>> fetchSuggestions(String query) {
    queries.add(query);
    return handler?.call(query) ?? Future.value(results);
  }
}

AppSettings _settings() => AppSettings(
      themeMode: ThemeMode.system,
      fontSizeScale: 1.0,
      locale: null,
      showManualDownloadButton: true,
      backgroundVerification: true,
      donationKey: '',
      userAgent: '',
      cookie: '',
      filters: const SearchFilters(),
    );

InstanceView _view(
  String host, {
  MirrorService service = MirrorService.libgen,
  bool enabled = true,
  SlumStatus status = SlumStatus.up,
}) =>
    InstanceView(
      site: SlumSite(
        service: service,
        url: 'https://$host',
        host: host,
        status: status,
        protection: Protection.none,
      ),
      enabled: enabled,
    );

SearchViewModel _vm({
  SearchRepository? search,
  PreferencesRepository? preferences,
  AppSettings? settings,
  MirrorRepository? mirrors,
  MirrorLatencyNotifier? mirrorLatency,
  TrendingRepository? trending,
  RecentSearchStore? recentStore,
  GoogleSuggestApi? suggestions,
}) {
  final mirror = mirrors ?? _FakeMirror();
  return SearchViewModel(
    search: search ?? _FakeSearchRepository(),
    preferences: preferences ?? _FakePreferences(),
    settings: settings ?? _settings(),
    mirrors: mirror,
    mirrorLatency: mirrorLatency ?? MirrorLatencyNotifier(mirror),
    trending: trending ?? _FakeTrending(const []),
    recentStore: recentStore ?? _MemoryRecentStore(),
    suggestionsApi: suggestions ?? _FakeSuggestions(),
  );
}

Future<void> _afterDebounce() async {
  await Future<void>.delayed(const Duration(milliseconds: 440));
  await pumpEventQueue();
}

void main() {
  test('initial state exposes the documented fallbacks', () {
    final vm = _vm();
    expect(vm.query, '');
    expect(vm.author, '');
    expect(vm.publisher, '');
    expect(vm.filters.type, 'All');
    expect(vm.filters.sort, 'Most Relevant');
    expect(vm.filtersEnabled, isTrue);
    expect(vm.selectedSource, isNull);
    expect(vm.enabledProviders, SearchProviderId.values.toSet());
    expect(vm.sourceOrder, defaultSearchSourceOrder);
    expect(vm.sourcesLoaded, isFalse);
    expect(vm.trending, isEmpty);
    expect(vm.suggestions, isEmpty);
    expect(vm.suggestionsLoading, isFalse);
    expect(vm.recentSearches, isEmpty);
    expect(vm.mirrorLatency.testing, isFalse);
    expect(vm.advancedFilterCount, 0);
    vm.dispose();
  });

  test('load populates sources, trending and recents', () async {
    final search = _FakeSearchRepository(
      enabled: {SearchProviderId.libgen, SearchProviderId.zlibrary},
      order: const [SearchProviderId.zlibrary, SearchProviderId.libgen],
    );
    final trending = _FakeTrending([
      TrendingBookData(title: 'Dune'),
      TrendingBookData(title: 'Emma'),
    ]);
    final store = _MemoryRecentStore(['Dune', 'Emma']);
    final vm = _vm(
      search: search,
      trending: trending,
      recentStore: store,
      mirrors: _FakeMirror(),
    );

    await vm.load();

    expect(vm.sourcesLoaded, isTrue);
    expect(vm.enabledProviders,
        {SearchProviderId.libgen, SearchProviderId.zlibrary});
    expect(
        vm.sourceOrder, [SearchProviderId.zlibrary, SearchProviderId.libgen]);
    // The list is shuffled on load, so only membership is stable.
    expect(vm.trending.map((book) => book.title).toSet(), {'Dune', 'Emma'});
    expect(vm.recentSearches, ['Dune', 'Emma']);
    expect(vm.mirrorLatency.loaded, isTrue);

    await vm.load();
    expect(search.enabledCalls, 1, reason: 'load must not repeat its work');
    expect(search.orderCalls, 1);
    expect(trending.calls, 1);
    vm.dispose();
  });

  test('load falls back to empty trending and shipped sources on errors',
      () async {
    final vm = _vm(
      search: _FakeSearchRepository(failure: Exception('no catalogue')),
      trending: _FakeTrending(const [], failure: Exception('offline')),
    );

    await vm.load();

    expect(vm.sourcesLoaded, isFalse);
    expect(vm.enabledProviders, SearchProviderId.values.toSet());
    expect(vm.sourceOrder, defaultSearchSourceOrder);
    expect(vm.trending, isEmpty);
    vm.dispose();
  });

  test('updateQuery debounces suggestion fetches by 420 ms', () async {
    final api = _FakeSuggestions(['Dune']);
    final vm = _vm(suggestions: api);

    vm.updateQuery('du');
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(api.queries, isEmpty, reason: 'the timer must not have fired yet');

    vm.updateQuery('dune');
    await _afterDebounce();

    expect(api.queries, ['dune'], reason: 'the first timer must be cancelled');
    expect(vm.suggestions, ['Dune']);
    expect(vm.suggestionsLoading, isFalse);
    vm.dispose();
  });

  test('suggestions drop sentinels and blanks and dedupe case-sensitively',
      () async {
    final api = _FakeSuggestions([
      'Dune',
      'Suggestion Error',
      'dune',
      'Dune',
      '   ',
      'Network Error',
      'Emma',
    ]);
    final vm = _vm(suggestions: api);

    vm.updateQuery('dune');
    await _afterDebounce();

    expect(vm.suggestions, ['Dune', 'dune', 'Emma']);
    vm.dispose();
  });

  test('blank queries clear suggestions and cancel the pending debounce',
      () async {
    final api = _FakeSuggestions(['Dune']);
    final vm = _vm(suggestions: api);

    vm.updateQuery('dune');
    await _afterDebounce();
    expect(vm.suggestions, ['Dune']);

    vm.updateQuery('   ');
    expect(vm.query, '   ');
    expect(vm.suggestions, isEmpty);
    expect(vm.suggestionsLoading, isFalse);

    await _afterDebounce();
    expect(api.queries, ['dune']);
    vm.dispose();
  });

  test('stale suggestion responses do not overwrite newer ones', () async {
    final first = Completer<List<String>>();
    final second = Completer<List<String>>();
    final api = _FakeSuggestions();
    api.handler = (query) => query == 'du' ? first.future : second.future;
    final vm = _vm(suggestions: api);

    vm.updateQuery('du');
    await _afterDebounce();
    vm.updateQuery('dune');
    await _afterDebounce();

    first.complete(['old']);
    second.complete(['new']);
    await pumpEventQueue();

    expect(vm.suggestions, ['new']);
    vm.dispose();
  });

  test('prepareSearch trims, records recents and enables filters', () async {
    final settings = _settings()..filtersEnabled = false;
    final store = _MemoryRecentStore(['Dune']);
    final vm = _vm(settings: settings, recentStore: store);

    final result = await vm.prepareSearch('  Emma  ');

    expect(result, 'Emma');
    expect(vm.query, 'Emma');
    expect(vm.recentSearches, ['Emma', 'Dune']);
    expect(store.stored, ['Emma', 'Dune']);
    expect(settings.filtersEnabled, isTrue);
    expect(settings.filters.type, 'All', reason: 'filters are not reset');

    final saves = store.saves;
    expect(await vm.prepareSearch('Emma'), 'Emma');
    expect(store.saves, saves, reason: 'a duplicate must not hit storage');

    expect(await vm.prepareSearch('   '), isNull);
    expect(vm.query, 'Emma');

    vm.updateQuery('Hyperion');
    expect(await vm.prepareSearch(), 'Hyperion');
    vm.dispose();
  });

  test('setFilter changes settings and persists the choice', () async {
    final preferences = _FakePreferences();
    final settings = _settings();
    final vm = _vm(preferences: preferences, settings: settings);

    vm.setFilter(SearchFilterKind.language, 'German');
    await pumpEventQueue();

    expect(settings.filters.language, 'German');
    expect(preferences.saved,
        [(kind: SearchFilterKind.language, value: 'German')]);
    vm.dispose();
  });

  test('resetFilters clears author and publisher and persists defaults',
      () async {
    final preferences = _FakePreferences();
    final settings = _settings();
    final vm = _vm(preferences: preferences, settings: settings);

    vm.setFilter(SearchFilterKind.type, 'Comic Books');
    vm.setAuthor('Ursula');
    vm.setPublisher('Ace');
    vm.setFilter(SearchFilterKind.fileType, 'EPUB');
    vm.setFilter(SearchFilterKind.language, 'German');
    vm.setFilter(SearchFilterKind.year, 'Before 1980');
    expect(vm.advancedFilterCount, 6);
    vm.setFilter(SearchFilterKind.sort, 'Newest');
    expect(vm.advancedFilterCount, 7);

    vm.resetFilters();
    await pumpEventQueue();

    expect(vm.filters.type, 'All');
    expect(vm.filters.sort, 'Most Relevant');
    expect(vm.filters.fileType, 'All');
    expect(vm.author, isEmpty);
    expect(vm.publisher, isEmpty);
    expect(vm.advancedFilterCount, 0);
    expect(preferences.resets, 1);
    vm.dispose();
  });

  test('removeRecent and clearRecents update state and storage', () async {
    final store = _MemoryRecentStore(['Dune', 'Emma', 'Hyperion']);
    final vm = _vm(recentStore: store);
    await vm.load();

    vm.removeRecent('Emma');
    await pumpEventQueue();
    expect(vm.recentSearches, ['Dune', 'Hyperion']);
    expect(store.stored, ['Dune', 'Hyperion']);

    vm.clearRecents();
    await pumpEventQueue();
    expect(vm.recentSearches, isEmpty);
    expect(store.stored, isEmpty);
    vm.dispose();
  });

  test('testMirrorLatency forwards every service and returns counts', () async {
    final mirror = _FakeMirror(
      views: {
        MirrorService.libgen: [_view('libgen.example')],
        MirrorService.zlibrary: [_view('zlib.example')],
      },
      latency: {'libgen.example': 40, 'zlib.example': null},
    );
    final latency = MirrorLatencyNotifier(mirror);
    final vm = _vm(mirrors: mirror, mirrorLatency: latency);

    final result = await vm.testMirrorLatency();

    expect(mirror.requestedServices, MirrorService.values);
    expect(result.total, 2);
    expect(result.reachable, 1);
    expect(result.fastestMs, 40);
    vm.dispose();
    latency.dispose();
  });

  test('testMirrorLatency ignores a second start while one is active',
      () async {
    final gate = Completer<Map<String, int?>>();
    final mirror = _FakeMirror(
      views: {
        MirrorService.libgen: [_view('libgen.example')],
      },
    );
    mirror.measureHandler = (_) => gate.future;
    final latency = MirrorLatencyNotifier(mirror);
    final vm = _vm(mirrors: mirror, mirrorLatency: latency);

    final first = vm.testMirrorLatency();
    await pumpEventQueue();
    final second = await vm.testMirrorLatency();

    expect(second.total, 0);
    expect(second.reachable, 0);
    expect(mirror.measureCalls, 1);

    gate.complete({'libgen.example': 25});
    final result = await first;
    expect(result.total, 1);
    expect(result.reachable, 1);
    expect(result.fastestMs, 25);
    vm.dispose();
    latency.dispose();
  });

  test('dispose detaches listeners and later commands never notify', () async {
    final settings = _settings();
    final vm = _vm(settings: settings);
    var notifications = 0;
    vm.addListener(() => notifications++);

    vm.updateQuery('dune');
    expect(notifications, 1);

    vm.dispose();
    vm.updateQuery('emma');
    vm.clearQuery();
    vm.selectSource(SearchProviderId.libgen);
    expect(notifications, 1, reason: 'no notification may follow dispose');

    settings.setSearchAuthor('Ursula');
    expect(notifications, 1);
    await _afterDebounce();
    expect(notifications, 1);
  });
}
