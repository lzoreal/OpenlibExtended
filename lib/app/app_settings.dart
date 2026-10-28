// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/data/models/search_filters.dart';
import 'package:openlib/data/repositories/preferences_repository.dart';
import 'package:openlib/data/services/database.dart';
import 'package:openlib/ui/core/themes.dart' show AppPalette;

/// Startup values shared by the shell and every page. Pages hold a
/// ViewModel that listens to this instead of receiving override lists.
class AppSettings extends ChangeNotifier {
  AppSettings({
    required this.themeMode,
    this.themePalette = AppPalette.emerald,
    required this.fontSizeScale,
    required this.locale,
    required this.showManualDownloadButton,
    required this.backgroundVerification,
    required this.donationKey,
    required this.userAgent,
    required this.cookie,
    required this.filters,
    this.searchAuthor = '',
    this.searchPublisher = '',
    this.filtersEnabled = true,
  });

  ThemeMode themeMode;
  AppPalette themePalette;
  double fontSizeScale;
  Locale? locale;
  bool showManualDownloadButton;
  bool backgroundVerification;
  String donationKey;
  String userAgent;
  String cookie;
  SearchFilters filters;
  String searchAuthor;
  String searchPublisher;
  bool filtersEnabled;

  static Future<AppSettings> load({
    required ThemeMode initialThemeMode,
    required PreferencesRepository preferences,
  }) async {
    final db = preferences.database;
    final filters = await preferences.loadSearchFilters();

    double fontSizeScale = 1.0;
    final fontSize = await _read(db, 'fontSizeScale');
    if (fontSize is num) {
      fontSizeScale = fontSize.toDouble();
    } else if (fontSize is String) {
      fontSizeScale = double.tryParse(fontSize) ?? 1.0;
    }

    final donationKey = await _read(db, 'donationKey');
    final localeCode = await _read(db, 'locale');

    Locale? locale;
    for (final candidate in AppLocalizations.supportedLocales) {
      if (candidate.languageCode == localeCode) locale = candidate;
    }

    return AppSettings(
      themeMode: initialThemeMode,
      themePalette: AppPalette.fromPreference(await _read(db, 'themePalette')),
      fontSizeScale: fontSizeScale,
      locale: locale,
      showManualDownloadButton:
          await _read(db, 'showManualDownloadButton') != 0,
      backgroundVerification: await _read(db, 'backgroundVerification') != 0,
      donationKey: donationKey is String ? donationKey : '',
      userAgent: await _readBrowserOption(db, 'userAgent'),
      cookie: await _readBrowserOption(db, 'cookie'),
      filters: filters,
    );
  }

  static Future<dynamic> _read(MyLibraryDb db, String key) async {
    try {
      return await db.getPreference(key);
    } catch (_) {
      return null;
    }
  }

  static Future<String> _readBrowserOption(MyLibraryDb db, String key) async {
    try {
      return await db.getBrowserOptions(key);
    } catch (_) {
      return '';
    }
  }

  void setThemeMode(ThemeMode mode) {
    if (themeMode == mode) return;
    themeMode = mode;
    notifyListeners();
  }

  void setThemePalette(AppPalette palette) {
    if (themePalette == palette) return;
    themePalette = palette;
    notifyListeners();
  }

  void setFontSizeScale(double scale) {
    if (fontSizeScale == scale) return;
    fontSizeScale = scale;
    notifyListeners();
  }

  void setLocale(Locale? value) {
    if (locale == value) return;
    locale = value;
    notifyListeners();
  }

  void setShowManualDownloadButton(bool value) {
    if (showManualDownloadButton == value) return;
    showManualDownloadButton = value;
    notifyListeners();
  }

  void setBackgroundVerification(bool value) {
    if (backgroundVerification == value) return;
    backgroundVerification = value;
    notifyListeners();
  }

  void setDonationKey(String value) {
    if (donationKey == value) return;
    donationKey = value;
    notifyListeners();
  }

  void setUserAgent(String value) {
    if (userAgent == value) return;
    userAgent = value;
    notifyListeners();
  }

  void setCookie(String value) {
    if (cookie == value) return;
    cookie = value;
    notifyListeners();
  }

  void setFilters(SearchFilters value) {
    filters = value;
    notifyListeners();
  }

  void setFilter(SearchFilterKind kind, String value) {
    final current = switch (kind) {
      SearchFilterKind.type => filters.type,
      SearchFilterKind.sort => filters.sort,
      SearchFilterKind.fileType => filters.fileType,
      SearchFilterKind.language => filters.language,
      SearchFilterKind.year => filters.year,
    };
    if (current == value) return;
    filters = switch (kind) {
      SearchFilterKind.type => filters.copyWith(type: value),
      SearchFilterKind.sort => filters.copyWith(sort: value),
      SearchFilterKind.fileType => filters.copyWith(fileType: value),
      SearchFilterKind.language => filters.copyWith(language: value),
      SearchFilterKind.year => filters.copyWith(year: value),
    };
    notifyListeners();
  }

  void resetSearchFilters() {
    const defaults = SearchFilters();
    final unchanged = filters.type == defaults.type &&
        filters.sort == defaults.sort &&
        filters.fileType == defaults.fileType &&
        filters.language == defaults.language &&
        filters.year == defaults.year &&
        searchAuthor.isEmpty &&
        searchPublisher.isEmpty;
    if (unchanged) return;
    filters = defaults;
    searchAuthor = '';
    searchPublisher = '';
    notifyListeners();
  }

  void setSearchAuthor(String value) {
    if (searchAuthor == value) return;
    searchAuthor = value;
    notifyListeners();
  }

  void setSearchPublisher(String value) {
    if (searchPublisher == value) return;
    searchPublisher = value;
    notifyListeners();
  }

  void setFiltersEnabled(bool value) {
    if (filtersEnabled == value) return;
    filtersEnabled = value;
    notifyListeners();
  }
}
