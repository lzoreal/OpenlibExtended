// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/services/search_manager.dart';
import 'package:openlib/ui/components/search_source_meta.dart';
import 'package:openlib/ui/swiss_grid.dart';

/// Compact source switcher for the results page. Tapping a pill switches the
/// result list to that catalog; the first pill returns to the merged list.
class SourceJourneyCard extends StatelessWidget {
  const SourceJourneyCard({
    super.key,
    required this.sources,
    required this.selectedSource,
    required this.onSelect,
    required this.totalCount,
  });

  final List<SearchSourceRun> sources;
  final SearchProviderId? selectedSource;
  final ValueChanged<SearchProviderId?> onSelect;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _SourcePill(
          label: l10n.searchSourceAuto,
          count: '$totalCount',
          dot: _PillDot.active,
          selected: selectedSource == null,
          onTap: () => onSelect(null),
        ),
        for (final run in sources)
          _SourcePill(
            label: run.id == SearchProviderId.zlibrary
                ? l10n.sourceZlibShort
                : sourceShortLabel(l10n, run.id),
            count: switch (run.status) {
              SearchSourceStatus.pending => '…',
              SearchSourceStatus.failed => l10n.sourceStatusFailed,
              SearchSourceStatus.locallyUnreachable => '—',
              _ => '${run.resultCount}',
            },
            dot: switch (run.status) {
              SearchSourceStatus.pending => _PillDot.pending,
              SearchSourceStatus.failed => _PillDot.failed,
              SearchSourceStatus.empty => _PillDot.off,
              SearchSourceStatus.skipped => _PillDot.off,
              SearchSourceStatus.locallyUnreachable => _PillDot.off,
              SearchSourceStatus.hit => _PillDot.active,
            },
            selected: selectedSource == run.id,
            onTap: run.status == SearchSourceStatus.pending
                ? null
                : () => onSelect(run.id),
          ),
      ],
    );
  }
}

enum _PillDot { active, pending, failed, off }

class _SourcePill extends StatelessWidget {
  const _SourcePill({
    required this.label,
    required this.count,
    required this.dot,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String count;
  final _PillDot dot;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = selected ? scheme.onPrimary : scheme.onSurfaceVariant;
    final countColor =
        selected ? scheme.onPrimary.withValues(alpha: 0.72) : scheme.outline;

    return Semantics(
      button: onTap != null,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? scheme.primary : scheme.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? Colors.transparent : scheme.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: SizedBox(
            height: 34,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Dot(dot: dot, selected: selected),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: SwissText.micro.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    count,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SwissText.badge.copyWith(
                      color: countColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.dot, required this.selected});

  final _PillDot dot;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (dot) {
      _PillDot.active => selected ? scheme.onPrimary : scheme.primary,
      _PillDot.pending => Colors.transparent,
      _PillDot.failed => scheme.tertiary,
      _PillDot.off => scheme.outlineVariant,
    };
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: dot == _PillDot.pending
            ? Border.all(
                color: selected ? scheme.onPrimary : scheme.outline,
                width: 1.5,
              )
            : null,
      ),
    );
  }
}
