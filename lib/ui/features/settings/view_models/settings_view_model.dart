// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:openlib/app/app_settings.dart';
import 'package:openlib/app/di.dart';
import 'package:openlib/data/models/search_result.dart';
import 'package:openlib/data/repositories/library_repository.dart';
import 'package:openlib/data/repositories/mirror_repository.dart';
import 'package:openlib/data/repositories/search_repository.dart';
import 'package:openlib/data/services/search_manager.dart';
import 'package:openlib/ui/core/themes.dart' show AppPalette;

/// Owns the settings page's state. Themes, font scale, locale and the
/// download/browser preferences live in [AppSettings] so the rest of the app
/// reacts through its single notifier; this view model only forwards them.
/// The page keeps writing the database rows, because it also owns the keys
/// that never reach [AppSettings].
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required AppSettings settings,
    required SearchRepository search,
    required LibraryRepository library,
    MirrorRepository? mirrors,
  })  : _settings = settings,
        _search = search,
        _library = library,
        _mirrors = mirrors ?? MirrorRepository() {
    _settings.addListener(_notify);
  }

  factory SettingsViewModel.fromDi() => SettingsViewModel(
        settings: getIt<AppSettings>(),
        search: getIt<SearchRepository>(),
        library: getIt<LibraryRepository>(),
        mirrors: getIt<MirrorRepository>(),
      );

  final AppSettings _settings;
  final SearchRepository _search;
  final LibraryRepository _library;
  final MirrorRepository _mirrors;

  Set<SearchProviderId> _enabledSources = defaultSearchSourceOrder.toSet();
  List<SearchProviderId> _sourceOrder = defaultSearchSourceOrder;
  bool _sourcesLoaded = false;
  bool _mirrorSpeedFirst = true;
  bool _disposed = false;

  ThemeMode get themeMode => _settings.themeMode;

  AppPalette get themePalette => _settings.themePalette;

  double get fontSizeScale => _settings.fontSizeScale;

  Locale? get locale => _settings.locale;

  bool get showManualDownloadButton => _settings.showManualDownloadButton;

  bool get backgroundVerification => _settings.backgroundVerification;

  String get donationKey => _settings.donationKey;

  String get userAgent => _settings.userAgent;

  String get cookie => _settings.cookie;

  Set<SearchProviderId> get enabledSources => _enabledSources;

  List<SearchProviderId> get sourceOrder => _sourceOrder;

  /// True when the automatic mirror order puts the fastest mirror first,
  /// false when the easiest protection gate wins.
  bool get mirrorSpeedFirst => _mirrorSpeedFirst;

  /// False until the first successful read. The page keeps the source cards
  /// hidden until then, matching the old provider's loading state.
  bool get sourcesLoaded => _sourcesLoaded;

  void setThemeMode(ThemeMode mode) => _settings.setThemeMode(mode);

  void setThemePalette(AppPalette palette) => _settings.setThemePalette(palette);

  void setFontSizeScale(double scale) => _settings.setFontSizeScale(scale);

  void setLocale(Locale? value) => _settings.setLocale(value);

  void setShowManualDownloadButton(bool value) =>
      _settings.setShowManualDownloadButton(value);

  void setBackgroundVerification(bool value) =>
      _settings.setBackgroundVerification(value);

  void setDonationKey(String value) => _settings.setDonationKey(value);

  void setUserAgent(String value) => _settings.setUserAgent(value);

  void setCookie(String value) => _settings.setCookie(value);

  Future<void> loadSources() async {
    try {
      final enabled = await _search.enabledProviders();
      final order = await _search.sourceOrder();
      if (_disposed) return;
      _enabledSources = enabled;
      _sourceOrder = order;
      _sourcesLoaded = true;
      _notify();
    } catch (_) {
      // Keep the shipped fallback and leave the cards hidden, like the old
      // provider's error branch.
    }
  }

  Future<void> setEnabled(SearchProviderId id, bool enabled) async {
    await _search.setProviderEnabled(id, enabled);
    await loadSources();
  }

  Future<void> setSourceOrder(List<SearchProviderId> order) async {
    await _search.setSourceOrder(order);
    await loadSources();
  }

  Future<void> loadMirrorSort() async {
    try {
      final speedFirst = await _mirrors.isSpeedFirst();
      if (_disposed) return;
      _mirrorSpeedFirst = speedFirst;
      _notify();
    } catch (_) {
      // Keep the speed-first default.
    }
  }

  Future<void> setMirrorSpeedFirst(bool value) async {
    if (_mirrorSpeedFirst == value) return;
    _mirrorSpeedFirst = value;
    _notify();
    await _mirrors.setSpeedFirst(value);
  }

  /// Tells every library listener (download center, detail pages) that the
  /// database rows changed outside [LibraryRepository].
  void refreshLibrary() => _library.notifyChanged();

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _settings.removeListener(_notify);
    super.dispose();
  }
}
