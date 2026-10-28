// Flutter imports:
import 'package:flutter/material.dart';

/// Softens the right edge of a horizontally scrolling strip so the cut-off
/// item reads as "more to scroll" instead of a layout bug.
class EdgeFade extends StatelessWidget {
  const EdgeFade({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Colors.black, Colors.black, Colors.transparent],
        stops: [0, 0.9, 1],
      ).createShader(bounds),
      child: child,
    );
  }
}
