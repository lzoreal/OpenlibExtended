// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:openlib/app/app_settings.dart';
import 'package:openlib/app/di.dart';
import 'package:openlib/data/repositories/download_repository.dart';
import 'package:openlib/data/services/download_manager.dart';
import 'package:openlib/data/services/stream_throttle.dart';
import 'package:openlib/ui/core/themes.dart';

/// Owns the app shell's state: the root tab index, the download badge and
/// the appearance values MaterialApp rebuilds on. Appearance stays in
/// [AppSettings]; this only mirrors them so the shell does not rebuild the
/// whole app when unrelated settings change.
class ShellViewModel extends ChangeNotifier {
  ShellViewModel({
    required AppSettings settings,
    required DownloadRepository downloads,
  })  : _settings = settings,
        _downloads = downloads {
    _themeMode = settings.themeMode;
    _themePalette = settings.themePalette;
    _fontSizeScale = settings.fontSizeScale;
    _locale = settings.locale;
    _activeDownloadCount = _countActive(downloads.active);
    _settings.addListener(_onSettingsChanged);
    _subscription = throttleLatest(
      downloads.updates,
      const Duration(milliseconds: 100),
    ).listen(_onDownloads);
  }

  factory ShellViewModel.fromDi() => getIt<ShellViewModel>();

  final AppSettings _settings;
  final DownloadRepository _downloads;

  StreamSubscription<Map<String, DownloadTask>>? _subscription;
  ThemeMode _themeMode = ThemeMode.system;
  AppPalette _themePalette = AppPalette.emerald;
  double _fontSizeScale = 1.0;
  Locale? _locale;
  int _tabIndex = 0;
  int _activeDownloadCount = 0;
  bool _disposed = false;

  ThemeMode get themeMode => _themeMode;

  AppPalette get themePalette => _themePalette;

  double get fontSizeScale => _fontSizeScale;

  Locale? get locale => _locale;

  int get tabIndex => _tabIndex;

  int get activeDownloadCount => _activeDownloadCount;

  void selectTab(int index) {
    if (_tabIndex == index) return;
    _tabIndex = index;
    _notify();
  }

  Future<void> resumeInterrupted() => _downloads.resumeInterrupted();

  static int _countActive(Map<String, DownloadTask> tasks) => tasks.values
      .where((task) =>
          task.status != DownloadStatus.completed &&
          task.status != DownloadStatus.cancelled)
      .length;

  void _onSettingsChanged() {
    final themeMode = _settings.themeMode;
    final themePalette = _settings.themePalette;
    final fontSizeScale = _settings.fontSizeScale;
    final locale = _settings.locale;
    if (themeMode == _themeMode &&
        themePalette == _themePalette &&
        fontSizeScale == _fontSizeScale &&
        locale == _locale) {
      return;
    }
    if (themeMode != _themeMode || themePalette != _themePalette) {
      updateSystemUi(themeMode, themePalette);
    }
    _themeMode = themeMode;
    _themePalette = themePalette;
    _fontSizeScale = fontSizeScale;
    _locale = locale;
    _notify();
  }

  void _onDownloads(Map<String, DownloadTask> tasks) {
    final count = _countActive(tasks);
    if (count == _activeDownloadCount) return;
    _activeDownloadCount = count;
    _notify();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _settings.removeListener(_onSettingsChanged);
    _subscription?.cancel();
    super.dispose();
  }
}
