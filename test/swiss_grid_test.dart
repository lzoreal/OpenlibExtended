import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/ui/swiss_grid.dart';

void main() {
  test('grid spans follow the 4-column board', () {
    const g = GridMetrics(360);
    expect(g.column, 76);
    expect(g.span(2), 160);
    expect(g.span(3), 244);
    expect(g.span(4), 328);
  });

  test('grid stays proportional on wider screens', () {
    const g = GridMetrics(840);
    expect(g.span(4), closeTo(808, 0.01));
    expect(g.span(2), closeTo(400, 0.01));
  });

  test('text tokens keep line height as a multiple of the size', () {
    expect(SwissText.title.fontSize, 26);
    expect(SwissText.title.height, closeTo(32 / 26, 0.0001));
    expect(SwissText.title.fontWeight, FontWeight.w800);
    expect(SwissText.body.fontSize, 14);
    expect(SwissText.body.height, closeTo(20 / 14, 0.0001));
    expect(SwissText.badge.fontSize, 10);
    expect(SwissText.badge.height, closeTo(16 / 10, 0.0001));
    expect(SwissText.title.letterSpacing, -0.6);
  });
}
