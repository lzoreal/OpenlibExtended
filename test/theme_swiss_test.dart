import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/ui/core/themes.dart';

void main() {
  test('text theme maps the nine Swiss tokens', () {
    final t = lightTheme.textTheme;
    expect(t.headlineMedium!.fontSize, 26);
    expect(t.headlineMedium!.height, closeTo(32 / 26, 0.0001));
    expect(t.headlineMedium!.fontWeight, FontWeight.w800);
    expect(t.headlineSmall!.fontSize, 20);
    expect(t.headlineSmall!.height, closeTo(28 / 20, 0.0001));
    expect(t.titleMedium!.fontSize, 16);
    expect(t.titleMedium!.height, closeTo(24 / 16, 0.0001));
    expect(t.bodyMedium!.fontSize, 14);
    expect(t.bodyMedium!.height, closeTo(20 / 14, 0.0001));
    expect(t.labelLarge!.fontSize, 13);
    expect(t.labelLarge!.height, closeTo(20 / 13, 0.0001));
    expect(t.bodySmall!.fontSize, 12);
    expect(t.bodySmall!.height, closeTo(20 / 12, 0.0001));
    expect(t.labelSmall!.fontSize, 11);
    expect(t.labelSmall!.height, closeTo(16 / 11, 0.0001));
    expect(t.labelMedium!.fontSize, 10);
    expect(t.labelMedium!.height, closeTo(16 / 10, 0.0001));
  });

  test('component themes use the six radii', () {
    expect(lightTheme.cardTheme.shape, isA<RoundedRectangleBorder>());
    final card = lightTheme.cardTheme.shape! as RoundedRectangleBorder;
    expect(card.borderRadius, BorderRadius.circular(20));
    expect(lightTheme.dialogTheme.shape, isA<RoundedRectangleBorder>());
    final dialog = lightTheme.dialogTheme.shape! as RoundedRectangleBorder;
    expect(dialog.borderRadius, BorderRadius.circular(28));
  });
}
