// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Project imports:
import 'package:openlib/app/app_settings.dart';
import 'package:openlib/services/database.dart';

import 'helpers/fake_path_provider.dart';

void main() {
  final paths = FakePathProvider('app_settings');

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    PathProviderPlatform.instance = paths;
  });

  test('load falls back to documented defaults when rows are missing',
      () async {
    // onOpen seeds this row with 0 on a fresh database; drop it so the test
    // really exercises the missing-row fallback.
    final seeded = await MyLibraryDb.instance.database;
    await seeded.delete('preferences',
        where: 'name = ?', whereArgs: ['showManualDownloadButton']);

    final settings =
        await AppSettings.load(initialThemeMode: ThemeMode.system);

    expect(settings.themeMode, ThemeMode.system);
    expect(settings.fontSizeScale, 1.0);
    expect(settings.locale, isNull);
    expect(settings.showManualDownloadButton, isTrue);
    expect(settings.backgroundVerification, isTrue);
    expect(settings.donationKey, '');
    expect(settings.userAgent, '');
    expect(settings.cookie, '');
    expect(settings.filters.type, 'All');
    expect(settings.filters.sort, 'Most Relevant');
  });

  test('load reads stored preferences', () async {
    final db = MyLibraryDb.instance;
    await db.savePreference('fontSizeScale', '1.5');
    await db.savePreference('showManualDownloadButton', 0);
    await db.savePreference('backgroundVerification', 0);
    await db.savePreference('donationKey', 'abc');
    await db.savePreference('locale', 'de');
    await db.savePreference('filterType', 'Comic Books');

    final settings =
        await AppSettings.load(initialThemeMode: ThemeMode.dark, database: db);

    expect(settings.themeMode, ThemeMode.dark);
    expect(settings.fontSizeScale, 1.5);
    expect(settings.showManualDownloadButton, isFalse);
    expect(settings.backgroundVerification, isFalse);
    expect(settings.donationKey, 'abc');
    expect(settings.locale?.languageCode, 'de');
    expect(settings.filters.type, 'Comic Books');
  });

  test('setters update state and notify listeners', () async {
    final settings =
        await AppSettings.load(initialThemeMode: ThemeMode.system);
    var notified = 0;
    settings.addListener(() => notified++);

    settings.setThemeMode(ThemeMode.light);
    settings.setThemeMode(ThemeMode.light);

    expect(settings.themeMode, ThemeMode.light);
    expect(notified, 1, reason: 'a no-op update must not notify');
  });
}
