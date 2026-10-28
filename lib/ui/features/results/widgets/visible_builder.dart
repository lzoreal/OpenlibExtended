// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// Builds its child with whether this widget intersects the nearest
/// scrollable viewport. Rows outside the viewport never build the cover
/// that watches the lazy-cover provider, so a long result list does not
/// fire one lookup per row.
class VisibilityBuilder extends StatefulWidget {
  const VisibilityBuilder({
    super.key,
    required this.builder,
    this.prefetchExtent = 0,
  });

  final Widget Function(BuildContext context, bool visible) builder;

  /// Treat rows this many logical pixels outside the viewport as visible,
  /// so their cover lookup starts before they scroll onto the screen.
  final double prefetchExtent;

  @override
  State<VisibilityBuilder> createState() => _VisibilityBuilderState();
}

class _VisibilityBuilderState extends State<VisibilityBuilder> {
  ScrollPosition? _position;
  bool _visible = false;
  bool _checkScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (position != _position) {
      _position?.removeListener(_scheduleCheck);
      _position = position;
      _position?.addListener(_scheduleCheck);
    }
    if (_position == null) {
      _visible = true;
    } else {
      _scheduleCheck();
    }
  }

  void _scheduleCheck() {
    if (_checkScheduled) return;
    _checkScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _checkScheduled = false;
      if (!mounted) return;
      _updateVisibility();
    });
  }

  void _updateVisibility() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final viewport = RenderAbstractViewport.maybeOf(box) as RenderBox?;
    if (viewport == null || !viewport.hasSize) {
      // No scrolling ancestor: there is nothing to hide behind.
      if (!_visible) setState(() => _visible = true);
      return;
    }

    final top = box.localToGlobal(Offset.zero, ancestor: viewport).dy;
    final margin = widget.prefetchExtent;
    final visible = top + box.size.height > -margin &&
        top < viewport.size.height + margin;
    if (visible != _visible) {
      setState(() => _visible = visible);
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_scheduleCheck);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _visible);
}
