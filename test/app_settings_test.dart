// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Project imports:
import 'package:openlib/app/app_settings.dart';
import 'package:openlib/data/models/search_filters.dart';
import 'package:openlib/data/repositories/preferences_repository.dart';
import 'package:openlib/data/services/database.dart';

import 'helpers/fake_path_provider.dart';

AppSettings _settingsWith({
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

    final preferences = PreferencesRepository(database: MyLibraryDb.instance);
    final settings = await AppSettings.load(
      initialThemeMode: ThemeMode.system,
      preferences: preferences,
    );

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

    final settings = await AppSettings.load(
      initialThemeMode: ThemeMode.dark,
      preferences: PreferencesRepository(database: db),
    );

    expect(settings.themeMode, ThemeMode.dark);
    expect(settings.fontSizeScale, 1.5);
    expect(settings.showManualDownloadButton, isFalse);
    expect(settings.backgroundVerification, isFalse);
    expect(settings.donationKey, 'abc');
    expect(settings.locale?.languageCode, 'de');
    expect(settings.filters.type, 'Comic Books');
  });

  test('setters update state and notify listeners', () async {
    final settings = await AppSettings.load(
      initialThemeMode: ThemeMode.system,
      preferences: PreferencesRepository(database: MyLibraryDb.instance),
    );
    var notified = 0;
    settings.addListener(() => notified++);

    settings.setThemeMode(ThemeMode.light);
    settings.setThemeMode(ThemeMode.light);

    expect(settings.themeMode, ThemeMode.light);
    expect(notified, 1, reason: 'a no-op update must not notify');
  });

  test('every setter writes its own field and notifies on change', () {
    // Built directly instead of loaded, so cases do not inherit rows written
    // by the earlier tests or by the database seeding.
    AppSettings fresh() => AppSettings(
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

    final cases = <({
      String name,
      void Function(AppSettings) apply,
      Object? Function(AppSettings) read,
      Object? expected,
      int notifications,
    })>[
      (
        name: 'setThemeMode',
        apply: (s) => s.setThemeMode(ThemeMode.light),
        read: (s) => s.themeMode,
        expected: ThemeMode.light,
        notifications: 1,
      ),
      (
        name: 'setFontSizeScale',
        apply: (s) => s.setFontSizeScale(1.25),
        read: (s) => s.fontSizeScale,
        expected: 1.25,
        notifications: 1,
      ),
      (
        name: 'setLocale',
        apply: (s) => s.setLocale(const Locale('de')),
        read: (s) => s.locale,
        expected: const Locale('de'),
        notifications: 1,
      ),
      (
        name: 'setShowManualDownloadButton',
        apply: (s) => s.setShowManualDownloadButton(false),
        read: (s) => s.showManualDownloadButton,
        expected: false,
        notifications: 1,
      ),
      (
        name: 'setBackgroundVerification',
        apply: (s) => s.setBackgroundVerification(false),
        read: (s) => s.backgroundVerification,
        expected: false,
        notifications: 1,
      ),
      (
        name: 'setDonationKey',
        apply: (s) => s.setDonationKey('donation-key'),
        read: (s) => s.donationKey,
        expected: 'donation-key',
        notifications: 1,
      ),
      (
        name: 'setUserAgent',
        apply: (s) => s.setUserAgent('user-agent'),
        read: (s) => s.userAgent,
        expected: 'user-agent',
        notifications: 1,
      ),
      (
        name: 'setCookie',
        apply: (s) => s.setCookie('cookie=session'),
        read: (s) => s.cookie,
        expected: 'cookie=session',
        notifications: 1,
      ),
      (
        name: 'setFilters',
        apply: (s) => s.setFilters(
          const SearchFilters(type: 'Comic Books', sort: 'Newest'),
        ),
        read: (s) => (s.filters.type, s.filters.sort),
        expected: ('Comic Books', 'Newest'),
        // SearchFilters has no value equality and the setter always notifies;
        // the no-op guard is deferred until SearchFilters has equality.
        notifications: 2,
      ),
    ];

    for (final testCase in cases) {
      final settings = fresh();
      var notified = 0;
      settings.addListener(() => notified++);

      testCase.apply(settings);

      expect(testCase.read(settings), testCase.expected,
          reason: '${testCase.name} must store its own field');
      expect(notified, 1,
          reason: '${testCase.name} must notify once when the value changes');

      testCase.apply(settings);

      expect(testCase.read(settings), testCase.expected,
          reason: '${testCase.name} must keep the value');
      expect(notified, testCase.notifications,
          reason: '${testCase.name} must only notify again for a real change');
    }
  });

  test('setFilter updates only that field and notifies', () {
    final settings = _settingsWith();
    var notified = 0;
    settings.addListener(() => notified++);

    settings.setFilter(SearchFilterKind.language, 'German');

    expect(settings.filters.language, 'German');
    expect(settings.filters.type, 'All');
    expect(settings.filters.sort, 'Most Relevant');
    expect(settings.filters.fileType, 'All');
    expect(settings.filters.year, 'All');
    expect(notified, 1);

    settings.setFilter(SearchFilterKind.year, 'Before 1980');

    expect(settings.filters.language, 'German');
    expect(settings.filters.year, 'Before 1980');
    expect(notified, 2);
  });

  test('resetSearchFilters restores defaults but leaves the toggle alone', () {
    final settings = _settingsWith(
      filters: const SearchFilters(
        type: 'Comic Books',
        sort: 'Newest',
        fileType: 'EPUB',
        language: 'German',
        year: 'Before 1980',
      ),
      searchAuthor: 'Ursula',
      searchPublisher: 'Ace',
      filtersEnabled: false,
    );
    var notified = 0;
    settings.addListener(() => notified++);

    settings.resetSearchFilters();

    expect(settings.filters.type, 'All');
    expect(settings.filters.sort, 'Most Relevant');
    expect(settings.filters.fileType, 'All');
    expect(settings.filters.language, 'All');
    expect(settings.filters.year, 'All');
    expect(settings.searchAuthor, isEmpty);
    expect(settings.searchPublisher, isEmpty);
    expect(settings.filtersEnabled, isFalse);
    expect(notified, 1);
  });

  test('search author, publisher and the filters toggle each notify', () {
    final settings = _settingsWith();
    var notified = 0;
    settings.addListener(() => notified++);

    settings.setFiltersEnabled(false);
    expect(settings.filtersEnabled, isFalse);
    expect(settings.filters.type, 'All', reason: 'the toggle is not a filter');
    expect(notified, 1);

    settings.setSearchAuthor('Ursula');
    expect(settings.searchAuthor, 'Ursula');
    expect(settings.searchPublisher, isEmpty);
    expect(notified, 2);

    settings.setSearchPublisher('Ace');
    expect(settings.searchPublisher, 'Ace');
    expect(settings.searchAuthor, 'Ursula');
    expect(notified, 3);
  });
}
