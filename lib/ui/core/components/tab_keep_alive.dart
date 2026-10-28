// Flutter imports:
import 'package:flutter/material.dart';

/// Keeps a bottom-navigation page mounted while it is off screen, so
/// switching back does not rebuild its whole tree or lose its scroll
/// position. Descendants read [TabVisibility] to pause work that only
/// matters while the tab is on screen.
class TabKeepAlive extends StatefulWidget {
  const TabKeepAlive({
    super.key,
    required this.active,
    required this.child,
  });

  final bool active;
  final Widget child;

  @override
  State<TabKeepAlive> createState() => _TabKeepAliveState();
}

class _TabKeepAliveState extends State<TabKeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Each page becomes its own layer, so sliding the PageView moves a
    // cached raster instead of repainting the whole page every frame.
    return TabVisibility(
      active: widget.active,
      child: RepaintBoundary(child: widget.child),
    );
  }
}

class TabVisibility extends InheritedWidget {
  const TabVisibility({
    super.key,
    required this.active,
    required super.child,
  });

  final bool active;

  /// Outside the tab shell (standalone pages, tests) a page is always
  /// considered visible.
  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TabVisibility>()?.active ??
      true;

  @override
  bool updateShouldNotify(TabVisibility oldWidget) =>
      active != oldWidget.active;
}
