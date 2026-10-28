// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import 'package:openlib/state/state.dart' show appSettingsProvider;
import 'package:openlib/ui/features/search/view_models/search_view_model.dart';

// Shared search-page fakes. The page takes its view model through the
// constructor, so widget tests only need Riverpod for the result page and
// the downloads strip it pushes or embeds.

class TestSearchRepository extends SearchRepository {
  TestSearchRepository({
    Set<SearchProviderId>? enabled,
    List<SearchProviderId>? order,
  })  : enabled = enabled ?? SearchProviderId.values.toSet(),
        order = order ?? defaultSearchSourceOrder,
        super(manager: SearchManager(providers: const []));

  final Set<SearchProviderId> enabled;
  final List<SearchProviderId> order;

  @override
  Future<Set<SearchProviderId>> enabledProviders() async => enabled;

  @override
  Future<List<SearchProviderId>> sourceOrder() async => order;
}

class TestTrendingRepository extends TrendingRepository {
  TestTrendingRepository([this.books = const []]) : super(sources: const []);

  final List<TrendingBookData> books;

  @override
  Future<List<TrendingBookData>> trendingBooks() async => books;
}

class TestSuggestions extends GoogleSuggestApi {
  TestSuggestions([this.values = const []]);

  final List<String> values;
  final List<String> queries = [];
  Future<List<String>> Function(String query)? handler;

  @override
  Future<List<String>> fetchSuggestions(String query) {
    queries.add(query);
    return handler?.call(query) ?? Future.value(values);
  }
}

class TestRecentStore implements RecentSearchStore {
  TestRecentStore([List<String> initial = const []])
      : stored = List<String>.of(initial);

  List<String> stored;
  final List<List<String>> saved = [];

  int get saves => saved.length;

  @override
  Future<List<String>> load() async => List<String>.of(stored);

  @override
  Future<void> save(List<String> searches) async {
    stored = List<String>.of(searches);
    saved.add(List<String>.of(searches));
  }
}

/// Filter writes are fire-and-forget in the view model; this keeps them off
/// the database without changing the call sequence.
class TestPreferencesRepository extends PreferencesRepository {
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

class TestMirrorRepository extends MirrorRepository {
  @override
  Future<List<InstanceView>> instances(MirrorService service,
          {bool force = false}) async =>
      const [];

  @override
  Future<Map<String, MirrorLatencyReading>> localLatencies() async => const {};

  @override
  Future<Map<String, int?>> measureLatency(Iterable<String> urls) async =>
      const {};

  @override
  Future<void> saveLocalLatencies(Map<String, int?> results,
      {DateTime? testedAt}) async {}
}

AppSettings testAppSettings({
  SearchFilters filters = const SearchFilters(),
  String searchAuthor = '',
  String searchPublisher = '',
  bool filtersEnabled = true,
}) {
  return AppSettings(
    themeMode: ThemeMode.system,
    fontSizeScale: 1.0,
    locale: null,
    showManualDownloadButton: true,
    backgroundVerification: true,
    donationKey: '',
    userAgent: '',
    cookie: '',
    filters: filters,
    searchAuthor: searchAuthor,
    searchPublisher: searchPublisher,
    filtersEnabled: filtersEnabled,
  );
}

final Expando<AppSettings> _settingsForViewModel =
    Expando<AppSettings>('search view model settings');

SearchViewModel testSearchViewModel({
  SearchRepository? search,
  PreferencesRepository? preferences,
  AppSettings? settings,
  MirrorRepository? mirrors,
  MirrorLatencyNotifier? mirrorLatency,
  TrendingRepository? trending,
  RecentSearchStore? recentStore,
  GoogleSuggestApi? suggestionsApi,
}) {
  final resolvedSettings = settings ?? testAppSettings();
  final resolvedMirrors = mirrors ?? TestMirrorRepository();
  final viewModel = SearchViewModel(
    search: search ?? TestSearchRepository(),
    preferences: preferences ?? TestPreferencesRepository(),
    settings: resolvedSettings,
    mirrors: resolvedMirrors,
    mirrorLatency: mirrorLatency ?? MirrorLatencyNotifier(resolvedMirrors),
    trending: trending ?? TestTrendingRepository(),
    recentStore: recentStore ?? TestRecentStore(),
    suggestionsApi: suggestionsApi ?? TestSuggestions(),
  );
  _settingsForViewModel[viewModel] = resolvedSettings;
  return viewModel;
}

/// The page no longer reads the source/mirror providers, but the result page
/// it pushes still reads its filters through [appSettingsProvider].
List<Override> testSearchOverrides({
  required SearchViewModel viewModel,
  AppSettings? settings,
}) {
  final resolved =
      settings ?? _settingsForViewModel[viewModel] ?? testAppSettings();
  return [
    appSettingsProvider.overrideWith((ref) => resolved),
  ];
}
