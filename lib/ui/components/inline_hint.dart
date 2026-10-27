// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:openlib/ui/swiss_grid.dart';

enum InlineHintTone { info, warning }

/// Compact contextual hint used under sections and inside cards.
class InlineHint extends StatelessWidget {
  const InlineHint({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.tone = InlineHintTone.info,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  });

  final String message;
  final IconData icon;
  final InlineHintTone tone;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final warning = tone == InlineHintTone.warning;
    final background = warning
        ? scheme.tertiaryContainer
        : Color.alphaBlend(
            scheme.primary.withValues(alpha: 0.07),
            scheme.surface,
          );
    final foreground = warning ? scheme.tertiary : scheme.onPrimaryContainer;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(SwissRadius.field),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 16, color: foreground),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: SwissText.micro.copyWith(
                color: foreground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
