// Package imports:
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:openlib/app/app_settings.dart';
import 'package:openlib/data/repositories/book_info_repository.dart';
import 'package:openlib/data/repositories/cover_repository.dart';
import 'package:openlib/data/repositories/download_repository.dart';
import 'package:openlib/data/repositories/library_repository.dart';
import 'package:openlib/data/repositories/mirror_repository.dart';
import 'package:openlib/data/repositories/search_repository.dart';
import 'package:openlib/data/repositories/trending_repository.dart';
import 'package:openlib/data/services/database.dart';
import 'package:openlib/data/services/download_manager.dart';
import 'package:openlib/data/services/mirror_latency_controller.dart';
import 'package:openlib/data/repositories/preferences_repository.dart';
import 'package:openlib/ui/features/search/view_models/search_view_model.dart';

final GetIt getIt = GetIt.instance;

/// Called once from main(); a second call is a startup bug, not a reuse path.
Future<void> initDi({
  required AppSettings settings,
  required MyLibraryDb database,
  required PreferencesRepository preferences,
}) async {
  if (getIt.isRegistered<AppSettings>()) {
    throw StateError('initDi called twice');
  }

  getIt.registerSingleton<MyLibraryDb>(database);
  getIt.registerSingleton<AppSettings>(settings);
  getIt.registerLazySingleton<PreferencesRepository>(() => preferences);
  getIt.registerLazySingleton<LibraryRepository>(() => LibraryRepository(
        database: getIt<MyLibraryDb>(),
        preferences: getIt<PreferencesRepository>(),
      ));
  getIt.registerLazySingleton<SearchRepository>(() => SearchRepository());
  getIt.registerLazySingleton<DownloadManager>(() => DownloadManager());
  getIt.registerLazySingleton<DownloadRepository>(
      () => DownloadRepository(manager: getIt<DownloadManager>()));
  getIt.registerLazySingleton<MirrorRepository>(() => MirrorRepository());
  getIt.registerLazySingleton<TrendingRepository>(() => TrendingRepository());
  getIt.registerLazySingleton<CoverRepository>(() => CoverRepository());
  getIt.registerLazySingleton<BookInfoRepository>(() => BookInfoRepository());
  getIt.registerLazySingleton<MirrorLatencyNotifier>(
      () => MirrorLatencyNotifier(getIt<MirrorRepository>()));
  getIt.registerFactory<SearchViewModel>(() => SearchViewModel(
        search: getIt<SearchRepository>(),
        preferences: getIt<PreferencesRepository>(),
        settings: getIt<AppSettings>(),
        mirrors: getIt<MirrorRepository>(),
        mirrorLatency: getIt<MirrorLatencyNotifier>(),
        trending: getIt<TrendingRepository>(),
      ));
}

Future<void> resetDi() => getIt.reset();
