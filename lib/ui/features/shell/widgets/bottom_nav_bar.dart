// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/ui/core/motion.dart';
import 'package:openlib/ui/core/swiss_grid.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.downloadCount,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final int downloadCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final labelHeight = MediaQuery.textScalerOf(context).scale(16);
    final barHeight = labelHeight + 56 < SwissGrid.navbar
        ? SwissGrid.navbar
        : labelHeight + 56;
    final items = [
      (
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: l10n.homeTitle,
        badge: null,
      ),
      (
        icon: Icons.search_outlined,
        selectedIcon: Icons.search,
        label: l10n.navSearch,
        badge: null,
      ),
      (
        icon: Icons.download_outlined,
        selectedIcon: Icons.download_rounded,
        label: l10n.navDownloads,
        badge: downloadCount == 0 ? null : downloadCount,
      ),
      (
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        label: l10n.navSettings,
        badge: null,
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: barHeight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                for (var index = 0; index < items.length; index++)
                  Expanded(
                    child: _DockItem(
                      icon: items[index].icon,
                      selectedIcon: items[index].selectedIcon,
                      label: items[index].label,
                      badge: items[index].badge,
                      selected: index == selectedIndex,
                      onTap: () => onSelected(index),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.badge,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int? badge;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // The icon sits on the tonal pill, the label on the bar's surface.
    // Sharing one colour made the label low-contrast on palettes whose
    // container is dark in light mode.
    final iconColor =
        selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;
    final labelColor = selected ? scheme.primary : scheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Tooltip(
        message: label,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(SwissRadius.field),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(SwissRadius.field),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      key: const ValueKey('nav-indicator'),
                      duration: kSelectionAnimationDuration,
                      curve: kSelectionAnimationCurve,
                      width: 56,
                      height: 32,
                      decoration: BoxDecoration(
                        color: selected
                            ? scheme.primaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(SwissRadius.field),
                      ),
                      child: TweenAnimationBuilder<Color?>(
                        tween: ColorTween(end: iconColor),
                        duration: kSelectionAnimationDuration,
                        curve: kSelectionAnimationCurve,
                        builder: (context, color, child) => Icon(
                          selected ? selectedIcon : icon,
                          size: 20,
                          color: color ?? iconColor,
                        ),
                      ),
                    ),
                    if (badge != null && badge! > 0)
                      Positioned(
                        top: -2,
                        right: 2,
                        child: Container(
                          constraints:
                              const BoxConstraints(minWidth: 16, minHeight: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: scheme.error,
                            borderRadius: BorderRadius.circular(SwissRadius.xs),
                            border: Border.all(color: scheme.surface, width: 1),
                          ),
                          child: Center(
                            child: Text(
                              badge! > 99 ? '99+' : '$badge',
                              style: SwissText.badge.copyWith(
                                color: scheme.onError,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  key: const ValueKey('nav-label'),
                  duration: kSelectionAnimationDuration,
                  curve: kSelectionAnimationCurve,
                  style: SwissText.badge.copyWith(
                    color: labelColor,
                    fontWeight: FontWeight.w700,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
