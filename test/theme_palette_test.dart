// Every palette must build a usable light/dark theme, keep the editorial
// paper background, and leave the default emerald look untouched.

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/ui/core/themes.dart';

void main() {
  test('the preference value round-trips and falls back to emerald', () {
    expect(AppPalette.fromPreference('violet'), AppPalette.violet);
    expect(AppPalette.fromPreference('graphite'), AppPalette.graphite);
    expect(AppPalette.fromPreference('nonsense'), AppPalette.emerald);
    expect(AppPalette.fromPreference(null), AppPalette.emerald);
  });

  test('every palette builds light and dark themes', () {
    for (final palette in AppPalette.values) {
      final light = buildAppTheme(palette, Brightness.light);
      final dark = buildAppTheme(palette, Brightness.dark);
      expect(light.brightness, Brightness.light, reason: palette.name);
      expect(dark.brightness, Brightness.dark, reason: palette.name);
      expect(light.scaffoldBackgroundColor, isNot(dark.scaffoldBackgroundColor),
          reason: '${palette.name} needs distinct paper backgrounds');
    }
  });

  test('the emerald default keeps its warm paper background', () {
    expect(
      buildAppTheme(AppPalette.emerald, Brightness.light)
          .scaffoldBackgroundColor,
      const Color(0xFFF4EFE6),
    );
    expect(
      buildAppTheme(AppPalette.emerald, Brightness.dark)
          .scaffoldBackgroundColor,
      const Color(0xFF151310),
    );
  });

  test('palettes are visibly different from each other', () {
    final primaries = {
      for (final palette in AppPalette.values)
        buildAppTheme(palette, Brightness.light).colorScheme.primary,
    };
    expect(primaries, hasLength(AppPalette.values.length));
  });
}
