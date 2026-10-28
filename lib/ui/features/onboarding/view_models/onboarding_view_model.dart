// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:openlib/app/app_settings.dart';
import 'package:openlib/app/di.dart';
import 'package:openlib/data/repositories/library_repository.dart';

/// Onboarding's two cross-page values. The theme and the donation key live in
/// [AppSettings] so the shell and detail pages see the same state; an import
/// has to notify the download center because it lists completed records.
class OnboardingViewModel extends ChangeNotifier {
  OnboardingViewModel({
    required AppSettings settings,
    required LibraryRepository library,
  })  : _settings = settings,
        _library = library {
    _settings.addListener(_notify);
  }

  factory OnboardingViewModel.fromDi() => OnboardingViewModel(
        settings: getIt<AppSettings>(),
        library: getIt<LibraryRepository>(),
      );

  final AppSettings _settings;
  final LibraryRepository _library;
  bool _disposed = false;

  ThemeMode get themeMode => _settings.themeMode;

  String get donationKey => _settings.donationKey;

  void setThemeMode(ThemeMode mode) => _settings.setThemeMode(mode);

  void setDonationKey(String value) => _settings.setDonationKey(value);

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
