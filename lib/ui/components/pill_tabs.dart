// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:openlib/ui/swiss_grid.dart';

/// Pill-shaped tab strip on a tonal track, matching the home mode switch
/// and the download filters. The tab bar itself still drives a
/// [TabBarView], so existing controllers and swipe behaviour are kept.
class PillTabs extends StatelessWidget {
  const PillTabs({
    super.key,
    required this.controller,
    required this.tabs,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 8),
  });

  final TabController controller;
  final List<Tab> tabs;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: padding,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Container(
            key: const ValueKey('pill-tabs-track'),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(SwissRadius.pill),
            ),
            child: SizedBox(
              height: 40,
              child: TabBar(
                controller: controller,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerHeight: 0,
                labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(SwissRadius.pill),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                splashBorderRadius: BorderRadius.circular(SwissRadius.pill),
                overlayColor: WidgetStatePropertyAll(
                  scheme.onSurface.withValues(alpha: 0.05),
                ),
                labelColor: scheme.onSurface,
                unselectedLabelColor: scheme.onSurfaceVariant,
                labelStyle: SwissText.caption.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: SwissText.caption.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                tabs: tabs,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
