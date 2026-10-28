// Project imports:
import 'package:openlib/app/app_settings.dart';
import 'package:openlib/app/di.dart';
import 'package:openlib/data/models/my_book.dart';
import 'package:openlib/data/models/search_result.dart';
import 'package:openlib/data/repositories/cover_repository.dart';
import 'package:openlib/data/repositories/download_repository.dart';
import 'package:openlib/data/repositories/library_repository.dart';
import 'package:openlib/data/repositories/mirror_repository.dart';
import 'package:openlib/data/repositories/preferences_repository.dart';
import 'package:openlib/data/repositories/search_repository.dart';
import 'package:openlib/data/repositories/trending_repository.dart';
import 'package:openlib/data/services/search_manager.dart';

import 'search_test_support.dart';

/// Registers the repositories a page's `fromDi` constructor resolves.
/// Tests call this instead of `initDi` so no database or network is touched.
Future<void> setupTestDi({
  AppSettings? settings,
  SearchRepository? search,
  LibraryRepository? library,
  DownloadRepository? downloads,
  MirrorRepository? mirrors,
  CoverRepository? covers,
  PreferencesRepository? preferences,
  TrendingRepository? trending,
}) async {
  await resetDi();
  getIt.registerSingleton<AppSettings>(settings ?? testAppSettings());
  getIt.registerSingleton<PreferencesRepository>(
      preferences ?? TestPreferencesRepository());
  getIt.registerLazySingleton<SearchRepository>(
      () => search ?? StubSearchRepository());
  getIt.registerLazySingleton<LibraryRepository>(
      () => library ?? StubLibraryRepository());
  getIt.registerLazySingleton<DownloadRepository>(
      () => downloads ?? DownloadRepository());
  getIt.registerLazySingleton<MirrorRepository>(
      () => mirrors ?? TestMirrorRepository());
  getIt.registerLazySingleton<CoverRepository>(
      () => covers ?? StubCoverRepository());
  getIt.registerLazySingleton<TrendingRepository>(
      () => trending ?? TestTrendingRepository());
}

/// Answers every search with an empty page so pushed result routes settle.
class StubSearchRepository extends SearchRepository {
  StubSearchRepository() : super(manager: SearchManager(providers: const []));

  static const _empty = SearchManagerResult(books: [], failedProviders: []);

  @override
  Stream<SearchManagerResult> watch(SearchQuery query,
          {bool forceLocalTimeouts = false}) =>
      Stream.value(_empty);

  @override
  Future<SearchManagerResult> search(SearchQuery query,
          {bool forceLocalTimeouts = false}) async =>
      _empty;

  @override
  Future<Set<SearchProviderId>> enabledProviders() async =>
      SearchProviderId.values.toSet();

  @override
  Future<List<SearchProviderId>> sourceOrder() async =>
      defaultSearchSourceOrder;
}

class StubLibraryRepository extends LibraryRepository {
  @override
  Future<List<MyBook>> allBooks() async => const [];

  @override
  Future<bool> contains(String id) async => false;

  @override
  Future<MyBook?> bookById(String id) async => null;
}

class StubCoverRepository extends CoverRepository {
  @override
  Future<String?> coverFor(String url) async => null;
}
