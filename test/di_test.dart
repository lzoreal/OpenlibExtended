// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Project imports:
import 'package:openlib/app/app_settings.dart';
import 'package:openlib/app/di.dart';
import 'package:openlib/data/models/search_filters.dart';
import 'package:openlib/data/repositories/preferences_repository.dart';
import 'package:openlib/data/services/database.dart';
import 'package:openlib/data/services/download_manager.dart';

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

  Future<AppSettings> settings() => AppSettings.load(
        initialThemeMode: ThemeMode.system,
        preferences: PreferencesRepository(database: MyLibraryDb.instance),
      );

  test('registers services as resolvable singletons', () async {
    final preferences = PreferencesRepository(database: MyLibraryDb.instance);
    final s = await settings();
    await initDi(
      settings: s,
      database: MyLibraryDb.instance,
      preferences: preferences,
    );

    expect(getIt<MyLibraryDb>(), same(MyLibraryDb.instance));
    expect(getIt<PreferencesRepository>(), same(preferences));
    expect(getIt<PreferencesRepository>(), same(getIt<PreferencesRepository>()));
    expect(getIt<DownloadManager>(), same(getIt<DownloadManager>()));
    expect(getIt<AppSettings>(), same(s));
    expect(getIt<AppSettings>(), same(getIt<AppSettings>()));
  });

  test('resetDi forgets registrations', () async {
    final preferences = PreferencesRepository(database: MyLibraryDb.instance);
    await initDi(
      settings: await settings(),
      database: MyLibraryDb.instance,
      preferences: preferences,
    );
    await resetDi();

    expect(() => getIt<AppSettings>(), throwsA(anything));
  });

  test('a second initDi throws instead of silently keeping stale state',
      () async {
    final preferences = PreferencesRepository(database: MyLibraryDb.instance);
    await initDi(
      settings: await settings(),
      database: MyLibraryDb.instance,
      preferences: preferences,
    );

    expect(
      () => initDi(
        settings: AppSettings(
          themeMode: ThemeMode.light,
          fontSizeScale: 1,
          locale: null,
          showManualDownloadButton: true,
          backgroundVerification: true,
          donationKey: '',
          userAgent: '',
          cookie: '',
          filters: const SearchFilters(),
        ),
        database: MyLibraryDb.instance,
        preferences: preferences,
      ),
      throwsA(isA<StateError>()),
    );
  });
}
