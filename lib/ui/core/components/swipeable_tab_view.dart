// Tab pages that switch on a deliberate swipe, not only on a fling.
//
// Flutter's TabBarView snaps back when a drag covers less than half a page
// and is released slowly - which is exactly what a careful swipe looks
// like, so the first swipe appeared to be ignored and the second (quicker)
// one worked. This keeps the stock TabBarView for the motion and commits
// the neighbour itself once a horizontal drag crossed a small fraction of
// the page.

// Flutter imports:
import 'package:flutter/material.dart';

class SwipeableTabView extends StatefulWidget {
  const SwipeableTabView({
    super.key,
    required this.controller,
    required this.children,
  });

  final TabController controller;
  final List<Widget> children;

  @override
  State<SwipeableTabView> createState() => _SwipeableTabViewState();
}

class _SwipeableTabViewState extends State<SwipeableTabView> {
  /// A drag past this fraction of the page commits, even when the finger
  /// stopped before lifting. 15% is about 65 dp on a phone.
  static const double _commitFraction = 0.15;

  double? _startPage;
  double? _lastPage;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: TabBarView(
        controller: widget.controller,
        children: widget.children,
      ),
    );
  }

  bool _onScroll(ScrollNotification notification) {
    // depth > 0 is an inner list (a horizontal chip row, a vertical list);
    // only the tab pages' own PageView may drive the switch.
    if (notification.depth != 0) return false;
    final metrics = notification.metrics;
    if (metrics.viewportDimension <= 0) return false;
    final page = metrics.pixels / metrics.viewportDimension;

    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _startPage = page;
      _lastPage = page;
      return false;
    }
    if (notification is ScrollUpdateNotification) {
      if (notification.dragDetails != null) {
        _lastPage = page;
        return false;
      }
      if (_startPage == null) return false;
    }
    if (notification is ScrollUpdateNotification ||
        notification is ScrollEndNotification) {
      final start = _startPage;
      final end = _lastPage;
      _startPage = null;
      _lastPage = null;
      if (start == null || end == null) return false;
      final delta = end - start;
      if (delta.abs() < _commitFraction) return false;
      final index = widget.controller.index;
      // Pixels grow towards the next tab; dragging back shrinks them.
      final next = delta > 0 ? index + 1 : index - 1;
      if (next < 0 || next >= widget.controller.length) return false;
      widget.controller.animateTo(next);
    }
    return false;
  }
}
