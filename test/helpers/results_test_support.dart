// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:openlib/app/app_settings.dart';
import 'package:openlib/data/models/my_book.dart';
import 'package:openlib/data/models/search_filters.dart';
import 'package:openlib/data/models/search_result.dart';
import 'package:openlib/data/repositories/cover_repository.dart';
import 'package:openlib/data/repositories/library_repository.dart';
import 'package:openlib/data/repositories/preferences_repository.dart';
import 'package:openlib/data/repositories/search_repository.dart';
import 'package:openlib/data/services/search_manager.dart';
import 'package:openlib/ui/features/results/view_models/results_view_model.dart';

/// Result-page fakes. The page takes its view model through the
/// constructor, so these tests need no Riverpod container at all.

/// Scripted search: [pageHandler] answers both the streamed page one and
/// later pages unless a dedicated handler is set.
class ScriptedSearchRepository extends SearchRepository {
  ScriptedSearchRepository({
    Set<SearchProviderId>? enabled,
    List<SearchProviderId>? order,
  })  : enabled = enabled ?? SearchProviderId.values.toSet(),
        order = order ?? defaultSearchSourceOrder,
        super(manager: SearchManager(providers: const []));

  final Set<SearchProviderId> enabled;
  final List<SearchProviderId> order;

  Future<SearchManagerResult> Function(SearchQuery query)? pageHandler;
  Stream<SearchManagerResult> Function(SearchQuery query)? watchHandler;
  Future<SearchManagerResult> Function(SearchQuery query)? searchHandler;

  final List<({SearchQuery query, bool forceLocalTimeouts})> watchCalls = [];
  final List<({SearchQuery query, bool forceLocalTimeouts})> searchCalls = [];

  @override
  Stream<SearchManagerResult> watch(
    SearchQuery query, {
    bool forceLocalTimeouts = false,
  }) {
    watchCalls.add((query: query, forceLocalTimeouts: forceLocalTimeouts));
    final handler = watchHandler;
    if (handler != null) return handler(query);
    final page = pageHandler;
    if (page != null) return Stream.fromFuture(page(query));
    return Stream.value(
        const SearchManagerResult(books: [], failedProviders: []));
  }

  @override
  Future<SearchManagerResult> search(
    SearchQuery query, {
    bool forceLocalTimeouts = false,
  }) {
    searchCalls.add((query: query, forceLocalTimeouts: forceLocalTimeouts));
    final handler = searchHandler ?? pageHandler;
    if (handler != null) return handler(query);
    return Future.value(
        const SearchManagerResult(books: [], failedProviders: []));
  }

  @override
  Future<Set<SearchProviderId>> enabledProviders() async => enabled;

  @override
  Future<List<SearchProviderId>> sourceOrder() async => order;
}

class TestResultsLibraryRepository extends LibraryRepository {
  TestResultsLibraryRepository([List<MyBook> books = const []])
      : books = List<MyBook>.of(books);

  List<MyBook> books;

  @override
  Future<List<MyBook>> allBooks() async => List<MyBook>.of(books);
}

class TestResultsPreferencesRepository extends PreferencesRepository {
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

class TestResultsCoverRepository extends CoverRepository {
  TestResultsCoverRepository([Map<String, String?>? covers])
      : covers = Map<String, String?>.of(covers ?? const {});

  final Map<String, String?> covers;
  final List<String> requests = [];

  @override
  Future<String?> coverFor(String url) async {
    requests.add(url);
    return covers[url];
  }
}

AppSettings testResultsSettings({
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

ResultsViewModel testResultsViewModel({
  String query = 'docker',
  SearchProviderId? source,
  SearchRepository? search,
  AppSettings? settings,
  PreferencesRepository? preferences,
  LibraryRepository? library,
  CoverRepository? covers,
}) {
  return ResultsViewModel(
    query: query,
    source: source,
    search: search ?? ScriptedSearchRepository(),
    settings: settings ?? testResultsSettings(),
    preferences: preferences ?? TestResultsPreferencesRepository(),
    library: library ?? TestResultsLibraryRepository(),
    covers: covers ?? TestResultsCoverRepository(),
  );
}
