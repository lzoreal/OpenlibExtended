// Readability guard for every palette: text roles must clear WCAG AA on the
// surfaces they actually sit on. A new seed must not ship text that is hard
// to read on the paper background.

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/ui/core/themes.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  for (final palette in AppPalette.values) {
    for (final brightness in Brightness.values) {
      final theme = buildAppTheme(palette, brightness);
      final scheme = theme.colorScheme;
      final surface = scheme.surface;
      final paper = theme.scaffoldBackgroundColor;
      final name = '${palette.name}/${brightness.name}';

      void expectContrast(Color fg, Color bg, String label, double ratio) {
        final value = _contrast(fg, bg);
        expect(
          value,
          greaterThanOrEqualTo(ratio),
          reason: '$name $label: ${value.toStringAsFixed(2)}:1 '
              '(${fg.toARGB32().toRadixString(16)} on '
              '${bg.toARGB32().toRadixString(16)})',
        );
      }

      test('$name body text is readable', () {
        expectContrast(scheme.onSurface, paper, 'onSurface on paper', 7);
        expectContrast(scheme.onSurface, surface, 'onSurface on surface', 7);
        expectContrast(
            scheme.onSurfaceVariant, surface, 'onSurfaceVariant', 4.5);
        expectContrast(scheme.onSurfaceVariant, paper, 'onSurfaceVariant/paper',
            4.5);
        expectContrast(scheme.onSurfaceVariant, scheme.surfaceContainerHigh,
            'onSurfaceVariant/containerHigh', 4.5);
        expectContrast(scheme.onSurfaceVariant, scheme.surfaceContainerHighest,
            'onSurfaceVariant/containerHighest', 4.5);
        expectContrast(scheme.onSurface, scheme.surfaceContainerHighest,
            'onSurface/containerHighest', 4.5);
      });

      test('$name accent text is readable', () {
        // Section labels, eyebrows and links use primary directly on paper.
        expectContrast(scheme.primary, paper, 'primary on paper', 4.5);
        expectContrast(scheme.primary, surface, 'primary on surface', 4.5);
        expectContrast(scheme.tertiary, paper, 'tertiary on paper', 4.5);
        expectContrast(scheme.error, surface, 'error on surface', 4.5);
      });

      test('$name chips and highlighted text are readable', () {
        expectContrast(scheme.onSurface, scheme.surfaceContainerHigh,
            'onSurface on containerHigh', 4.5);
        expectContrast(scheme.onSurfaceVariant, scheme.surfaceContainerHigh,
            'onSurfaceVariant on containerHigh', 4.5);
        expectContrast(scheme.secondary, surface, 'secondary on surface', 4.5);
        expectContrast(scheme.inversePrimary, scheme.inverseSurface,
            'inversePrimary', 3.0);
      });

      test('$name bottom bar is readable', () {
        // Icon on the tonal pill, label on the bar surface.
        expectContrast(
            scheme.onPrimaryContainer, scheme.primaryContainer, 'nav icon', 4.5);
        expectContrast(scheme.primary, scheme.surface, 'nav selected label', 4.5);
        expectContrast(
            scheme.onSurfaceVariant, scheme.surface, 'nav label', 4.5);
      });

      test('$name filled and tonal pairs are readable', () {
        expectContrast(scheme.onPrimary, scheme.primary, 'onPrimary', 4.5);
        expectContrast(scheme.onPrimaryContainer, scheme.primaryContainer,
            'onPrimaryContainer', 4.5);
        expectContrast(scheme.onSecondaryContainer, scheme.secondaryContainer,
            'onSecondaryContainer', 4.5);
        expectContrast(scheme.onTertiaryContainer, scheme.tertiaryContainer,
            'onTertiaryContainer', 4.5);
        expectContrast(
            scheme.onErrorContainer, scheme.errorContainer, 'onError', 4.5);
      });
    }
  }
}
