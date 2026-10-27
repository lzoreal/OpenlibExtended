import 'package:flutter/material.dart';

/// Sticky action bar shared by the book detail states.
class DetailBottomBar extends StatelessWidget {
  const DetailBottomBar({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('detail-bottom-bar'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            scheme.surface.withValues(alpha: 0),
            Theme.of(context).scaffoldBackgroundColor,
          ],
          stops: const [0, 0.34],
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: SizedBox(
              height: 48,
              child: Row(children: children),
            ),
          ),
        ),
      ),
    );
  }
}
