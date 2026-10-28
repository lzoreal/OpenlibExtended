// Coverage for the preference facade: filter keys default correctly when the
// row is missing, saved values round-trip, reset writes the five defaults, and
// the storage-directory read tolerates a missing row instead of throwing.

// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Project imports:
import 'package:openlib/data/services/database.dart';
import 'package:openlib/data/services/preferences.dart';

import 'helpers/fake_path_provider.dart';

void main() {
  final paths = FakePathProvider('preferences_service');

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    PathProviderPlatform.instance = paths;
  });

  test('loadSearchFilters falls back to defaults for missing rows', () async {
    final filters = await PreferencesService().loadSearchFilters();

    expect(filters.type, 'All');
    expect(filters.sort, 'Most Relevant');
    expect(filters.fileType, 'All');
    expect(filters.language, 'All');
    expect(filters.year, 'All');
  });

  test('saveSearchFilter persists each kind and loads it back', () async {
    final service = PreferencesService();

    await service.saveSearchFilter(SearchFilterKind.type, 'Fiction Books');
    await service.saveSearchFilter(SearchFilterKind.sort, 'Newest');
    await service.saveSearchFilter(SearchFilterKind.fileType, 'EPUB');
    await service.saveSearchFilter(SearchFilterKind.language, 'Chinese');
    await service.saveSearchFilter(SearchFilterKind.year, 'Before 1980');

    final filters = await service.loadSearchFilters();
    expect(filters.type, 'Fiction Books');
    expect(filters.sort, 'Newest');
    expect(filters.fileType, 'EPUB');
    expect(filters.language, 'Chinese');
    expect(filters.year, 'Before 1980');
  });

  test('resetSearchFilters restores the documented defaults', () async {
    final service = PreferencesService();

    await service.saveSearchFilter(SearchFilterKind.type, 'Comic Books');
    await service.saveSearchFilter(SearchFilterKind.year, 'Before 1980');

    await service.resetSearchFilters();

    final filters = await service.loadSearchFilters();
    expect(filters.type, 'All');
    expect(filters.sort, 'Most Relevant');
    expect(filters.fileType, 'All');
    expect(filters.language, 'All');
    expect(filters.year, 'All');
  });

  test('bookStorageDirectory returns the stored path', () async {
    const directory = '/tmp/openlib_preferences_storage';
    await MyLibraryDb.instance
        .savePreference('bookStorageDirectory', directory);

    expect(await PreferencesService().bookStorageDirectory(), directory);
  });

  test('bookStorageDirectory returns null when the row is missing', () async {
    final db = await MyLibraryDb.instance.database;
    await db.delete('preferences',
        where: 'name = ?', whereArgs: ['bookStorageDirectory']);

    expect(await PreferencesService().bookStorageDirectory(), isNull);
  });
}
