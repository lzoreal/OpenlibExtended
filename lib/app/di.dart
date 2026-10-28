// Package imports:
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:openlib/app/app_settings.dart';
import 'package:openlib/services/database.dart';
import 'package:openlib/services/download_manager.dart';
import 'package:openlib/services/instance_manager.dart';
import 'package:openlib/services/preferences.dart';

final GetIt getIt = GetIt.instance;

/// Single assembly point. Pages resolve view models from here; nothing
/// registers itself on first use.
Future<void> initDi({
  required AppSettings settings,
  MyLibraryDb? database,
}) async {
  final db = database ?? MyLibraryDb.instance;

  if (!getIt.isRegistered<MyLibraryDb>()) {
    getIt.registerSingleton<MyLibraryDb>(db);
  }
  getIt.registerSingleton<AppSettings>(settings);
  getIt.registerLazySingleton<PreferencesService>(
      () => PreferencesService(database: getIt<MyLibraryDb>()));
  getIt.registerLazySingleton<DownloadManager>(() => DownloadManager());
  getIt.registerLazySingleton<InstanceManager>(() => InstanceManager());
}

Future<void> resetDi() => getIt.reset();
