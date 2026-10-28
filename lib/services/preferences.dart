// Project imports:
import 'package:openlib/services/database.dart';

enum SearchFilterKind { type, sort, fileType, language, year }

class SearchFilters {
  const SearchFilters({
    this.type = 'All',
    this.sort = 'Most Relevant',
    this.fileType = 'All',
    this.language = 'All',
    this.year = 'All',
  });

  final String type;
  final String sort;
  final String fileType;
  final String language;
  final String year;
}

/// Single owner of the preference keys that were previously read and written
/// from several pages, so a missing row has one documented fallback.
class PreferencesService {
  PreferencesService({MyLibraryDb? database})
      : _database = database ?? MyLibraryDb.instance;

  final MyLibraryDb _database;

  static const Map<SearchFilterKind, String> _keyByKind = {
    SearchFilterKind.type: 'filterType',
    SearchFilterKind.sort: 'filterSort',
    SearchFilterKind.fileType: 'filterFileType',
    SearchFilterKind.language: 'filterLanguage',
    SearchFilterKind.year: 'filterYear',
  };

  Future<SearchFilters> loadSearchFilters() async {
    const defaults = SearchFilters();
    return SearchFilters(
      type: await _readSearchFilter(SearchFilterKind.type, defaults.type),
      sort: await _readSearchFilter(SearchFilterKind.sort, defaults.sort),
      fileType:
          await _readSearchFilter(SearchFilterKind.fileType, defaults.fileType),
      language:
          await _readSearchFilter(SearchFilterKind.language, defaults.language),
      year: await _readSearchFilter(SearchFilterKind.year, defaults.year),
    );
  }

  Future<void> saveSearchFilter(SearchFilterKind kind, String value) {
    return _database.savePreference(_keyByKind[kind]!, value);
  }

  Future<void> resetSearchFilters() async {
    const defaults = SearchFilters();
    await Future.wait([
      saveSearchFilter(SearchFilterKind.type, defaults.type),
      saveSearchFilter(SearchFilterKind.sort, defaults.sort),
      saveSearchFilter(SearchFilterKind.fileType, defaults.fileType),
      saveSearchFilter(SearchFilterKind.language, defaults.language),
      saveSearchFilter(SearchFilterKind.year, defaults.year),
    ]);
  }

  Future<String?> bookStorageDirectory() async {
    try {
      final value = await _database.getPreference('bookStorageDirectory');
      return value is String ? value : null;
    } catch (_) {
      return null;
    }
  }

  Future<String> _readSearchFilter(
      SearchFilterKind kind, String fallback) async {
    try {
      final value = await _database.getPreference(_keyByKind[kind]!);
      return value is String ? value : fallback;
    } catch (_) {
      return fallback;
    }
  }
}
