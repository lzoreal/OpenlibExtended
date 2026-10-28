import 'package:flutter/material.dart';

import 'package:openlib/ui/core/swiss_grid.dart';

class SwissGridOverlay extends CustomPainter {
  const SwissGridOverlay({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = GridMetrics(size.width);
    final columns = Paint()
      ..color = (dark ? Colors.white : Colors.black).withValues(alpha: 0.06);
    final baselines = Paint()
      ..color = (dark ? Colors.white : Colors.black).withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (var i = 0; i < SwissGrid.columns; i++) {
      final x = SwissGrid.margin + i * (metrics.column + SwissGrid.gutter);
      canvas.drawRect(
          Rect.fromLTWH(x, 0, metrics.column, size.height), columns);
    }
    for (double y = 0; y < size.height; y += SwissGrid.unit) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), baselines);
    }
  }

  @override
  bool shouldRepaint(covariant SwissGridOverlay oldDelegate) =>
      oldDelegate.dark != dark;
}
