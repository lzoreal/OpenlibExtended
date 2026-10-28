// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/data/services/database.dart';
import 'package:openlib/data/services/preferences.dart';

/// Startup values that used to be passed as ProviderScope overrides.
/// Pages listen to this instead of receiving a fresh override list.
class AppSettings extends ChangeNotifier {
  AppSettings({
    required this.themeMode,
    required this.fontSizeScale,
    required this.locale,
    required this.showManualDownloadButton,
    required this.backgroundVerification,
    required this.donationKey,
    required this.userAgent,
    required this.cookie,
    required this.filters,
  });

  ThemeMode themeMode;
  double fontSizeScale;
  Locale? locale;
  bool showManualDownloadButton;
  bool backgroundVerification;
  String donationKey;
  String userAgent;
  String cookie;
  SearchFilters filters;

  static Future<AppSettings> load({
    required ThemeMode initialThemeMode,
    required PreferencesService preferences,
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
}
