import 'package:flutter/material.dart';

/// Thin tray-and-arrow share glyph matching the design mockup, rather than
/// the filled platform icon.
class ShareIcon extends StatelessWidget {
  const ShareIcon({super.key, this.size = 22, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effective = color ??
        IconTheme.of(context).color ??
        Theme.of(context).colorScheme.onSurfaceVariant;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ShareIconPainter(effective)),
    );
  }
}

class _ShareIconPainter extends CustomPainter {
  const _ShareIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = size.width / 24;
    final h = size.height / 24;
    final path = Path()
      ..moveTo(12 * w, 16 * h)
      ..lineTo(12 * w, 4 * h)
      ..moveTo(7 * w, 9 * h)
      ..lineTo(12 * w, 4 * h)
      ..lineTo(17 * w, 9 * h)
      ..moveTo(5 * w, 14 * h)
      ..lineTo(5 * w, 20 * h)
      ..lineTo(19 * w, 20 * h)
      ..lineTo(19 * w, 14 * h);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ShareIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
