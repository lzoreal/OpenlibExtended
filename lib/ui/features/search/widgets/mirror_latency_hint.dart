// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/ui/core/swiss_grid.dart';

/// Compact search-page nudge shown when this device has no fresh local
/// mirror readings. It never starts a test by itself; the action opens
/// the mirrors page so the user stays in control of the traffic.
class MirrorLatencyHint extends StatelessWidget {
  const MirrorLatencyHint({
    super.key,
    required this.show,
    required this.onTest,
    this.testing = false,
  });

  final bool show;
  final VoidCallback onTest;
  final bool testing;

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = scheme.onTertiaryContainer;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(SwissRadius.field),
      ),
      child: Row(
        children: [
          Icon(Icons.speed_rounded, size: 16, color: foreground),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.mirrorLatencyHint,
              style: SwissText.micro.copyWith(
                color: foreground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 4),
          if (testing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: scheme.tertiary,
                ),
              ),
            )
          else
            TextButton(
              onPressed: onTest,
              style: TextButton.styleFrom(
                foregroundColor: scheme.tertiary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.mirrorLatencyGoTest,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
        ],
      ),
    );
  }
}
