// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:openlib/ui/core/swiss_grid.dart';

/// Shared page title block: a small section label, a large title and an
/// optional trailing action. Every top-level page uses this so switching
/// tabs never changes the visual rhythm. Page headers carry no subtitle:
/// supporting copy belongs inside the content below.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.action,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 12),
  });

  final String title;
  final String? eyebrow;
  final Widget? action;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null) ...[
                  Text(
                    eyebrow!,
                    style: SwissText.badge.copyWith(
                      color: scheme.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SwissText.title.copyWith(color: scheme.onSurface),
                ),
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 8),
            action!,
          ],
        ],
      ),
    );
  }
}
