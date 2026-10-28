// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Project imports:
import 'package:openlib/app/app_settings.dart';
import 'package:openlib/app/di.dart';
import 'package:openlib/services/database.dart';
import 'package:openlib/services/download_manager.dart';
import 'package:openlib/services/instance_manager.dart';
import 'package:openlib/services/preferences.dart';

import 'helpers/fake_path_provider.dart';

void main() {
  final paths = FakePathProvider('di');

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    PathProviderPlatform.instance = paths;
  });

  tearDown(() async {
    await resetDi();
  });

  Future<AppSettings> settings() =>
      AppSettings.load(initialThemeMode: ThemeMode.system);

  test('registers services as resolvable singletons', () async {
    final s = await settings();
    await initDi(settings: s);

    expect(getIt<MyLibraryDb>(), same(MyLibraryDb.instance));
    expect(getIt<InstanceManager>(), same(getIt<InstanceManager>()));
    expect(getIt<PreferencesService>(), same(getIt<PreferencesService>()));
    expect(getIt<DownloadManager>(), same(getIt<DownloadManager>()));
    expect(getIt<AppSettings>(), same(s));
    expect(getIt<AppSettings>(), same(getIt<AppSettings>()));
  });

  test('resetDi forgets registrations', () async {
    await initDi(settings: await settings());
    await resetDi();

    expect(() => getIt<AppSettings>(), throwsA(anything));
  });
}
