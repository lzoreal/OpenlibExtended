import 'package:flutter/material.dart';

/// Geometry of the 4-column Swiss grid the whole app is laid out on.
///
/// The prototype in `design/ui_prototype.html` is the source of truth: every
/// value here is measured from it, so a page that uses these constants can be
/// compared against the prototype one-to-one. Nothing in this file is a
/// colour or a text style — those come from `Theme.of` so light/dark keeps
/// working.
abstract final class SwissGrid {
  /// Design board width the prototype was drawn at.
  static const double board = 360;

  /// Page margin on both sides.
  static const double margin = 16;

  /// Space between two columns.
  static const double gutter = 8;

  static const int columns = 4;

  /// Usable width: `board - margin * 2`.
  static const double content = 328;

  /// Width of a single column: `(328 - 8 * 3) / 4`.
  static const double column = 76;

  /// Block widths that snap onto column lines.
  static const double span2 = 160;
  static const double span3 = 244;
  static const double span4 = 328;

  /// Everything vertical is a multiple of the 4 dp baseline; everyday spacing
  /// sticks to the 8 dp rhythm and 32 dp is the emphasis line.
  static const double unit = 4;
  static const double rhythm = 8;
  static const double emphasis = 32;

  /// Fixed vertical rhythm of the shared chrome.
  static const double pageHeader = 80;
  static const double appBar = 56;
  static const double navbar = 72;
  static const double bottomBar = 84;

  /// Row heights used by lists.
  static const double rowTall = 96;
  static const double row = 64;
}

/// Corner radius ladder. Only these six values are allowed; smaller radii
/// (1–4 dp) belong to inner details such as a progress bar, not to a surface.
abstract final class SwissRadius {
  static const double xs = 8;
  static const double sm = 12;
  static const double field = 16;
  static const double card = 20;
  static const double sheet = 28;
  static const double pill = 999;
}

/// The nine text sizes, each paired with a line height that is a multiple of
/// 4. Use these through `Theme.textTheme` rather than raw `TextStyle`s.
abstract final class SwissType {
  static const double display = 34;
  static const double displayLine = 40;
  static const double pageTitle = 26;
  static const double pageTitleLine = 32;
  static const double section = 20;
  static const double sectionLine = 28;
  static const double cardTitle = 16;
  static const double cardTitleLine = 24;
  static const double body = 14;
  static const double bodyLine = 20;
  static const double secondary = 13;
  static const double secondaryLine = 20;
  static const double meta = 12;
  static const double metaLine = 20;
  static const double caption = 11;
  static const double captionLine = 16;
  static const double badge = 10;
  static const double badgeLine = 16;

  /// Flutter's `TextStyle.height` is a multiplier, not a pixel value.
  static double heightOf(double size, double line) => line / size;
}

/// Resolves column widths against the real screen width so the structure
/// survives tablets and desktop windows instead of assuming 360 dp.
class GridMetrics {
  const GridMetrics(this.width);

  /// Width of the layout area, i.e. `LayoutBuilder`'s `maxWidth`.
  final double width;

  double get column =>
      (width -
          SwissGrid.margin * 2 -
          SwissGrid.gutter * (SwissGrid.columns - 1)) /
      SwissGrid.columns;

  /// Width of a block spanning [n] columns.
  double span(int n) => column * n + SwissGrid.gutter * (n - 1);
}

TextStyle swissText({
  required double size,
  required double line,
  FontWeight weight = FontWeight.w400,
  double letterSpacing = 0,
}) =>
    TextStyle(
      fontSize: size,
      height: line / size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

abstract final class SwissText {
  static final title = swissText(
    size: SwissType.pageTitle,
    line: SwissType.pageTitleLine,
    weight: FontWeight.w800,
    letterSpacing: -0.6,
  );
  static final headline = swissText(
    size: SwissType.section,
    line: SwissType.sectionLine,
    weight: FontWeight.w700,
  );
  static final subtitle = swissText(
    size: SwissType.cardTitle,
    line: SwissType.cardTitleLine,
    weight: FontWeight.w700,
  );
  static final body = swissText(
    size: SwissType.body,
    line: SwissType.bodyLine,
  );
  static final bodyStrong = swissText(
    size: SwissType.body,
    line: SwissType.bodyLine,
    weight: FontWeight.w600,
  );
  static final label = swissText(
    size: SwissType.secondary,
    line: SwissType.secondaryLine,
    weight: FontWeight.w700,
  );
  static final caption = swissText(
    size: SwissType.meta,
    line: SwissType.metaLine,
    weight: FontWeight.w500,
  );
  static final micro = swissText(
    size: SwissType.caption,
    line: SwissType.captionLine,
    weight: FontWeight.w600,
  );
  static final badge = swissText(
    size: SwissType.badge,
    line: SwissType.badgeLine,
    weight: FontWeight.w800,
  );
}
