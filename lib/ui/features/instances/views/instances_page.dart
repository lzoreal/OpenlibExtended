// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/data/services/instance_manager.dart';
import 'package:openlib/data/services/mirror_latency.dart';
import 'package:openlib/data/services/mirror_latency_controller.dart'
    show MirrorLatencyState;
import 'package:openlib/ui/features/instances/view_models/instances_view_model.dart';
import 'package:openlib/ui/features/shell/widgets/content_width.dart';
import 'package:openlib/ui/core/components/settings_row.dart';
import 'package:openlib/ui/core/swiss_grid.dart';
import 'package:openlib/ui/core/components/inline_hint.dart';

/// Settings > Mirrors.
///
/// Every mirror the app can talk to, per service, exactly as
/// open-slum.org reports it - the app hardcodes no mirror URLs. Each row
/// shows SLUM's status, the protection gate and its latency, and can be
/// switched off. Ordering is automatic by default (easiest protection
/// first, then fastest); flipping the switch to manual lets the user
/// reorder the mirrors themselves. A mirror SLUM reports DOWN is shown
/// greyed out and is never contacted.
class InstancesPage extends StatefulWidget {
  const InstancesPage({super.key, this.viewModel});

  /// Test seam; production builds the view model from the DI container.
  final InstancesViewModel? viewModel;

  @override
  State<InstancesPage> createState() => _InstancesPageState();
}

class _InstancesPageState extends State<InstancesPage> {
  late final InstancesViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? InstancesViewModel.fromDi();
    unawaited(_viewModel.load());
  }

  @override
  void dispose() {
    if (_ownsViewModel) _viewModel.dispose();
    super.dispose();
  }

  static String _statusLabel(AppLocalizations l10n, SlumStatus status) {
    return switch (status) {
      SlumStatus.up => l10n.mirrorStatusUp,
      SlumStatus.degraded => l10n.mirrorStatusDegraded,
      SlumStatus.protected => l10n.mirrorStatusProtected,
      SlumStatus.down => l10n.mirrorStatusDown,
      SlumStatus.unknown => l10n.unknown,
    };
  }

  static const _serviceTitles = {
    MirrorService.libgen: 'Library Genesis',
    MirrorService.zlibrary: 'Z-Library',
    MirrorService.welib: 'WeLib',
    MirrorService.annasArchive: "Anna's Archive",
  };

  static const _serviceMarks = {
    MirrorService.libgen: 'LG',
    MirrorService.zlibrary: 'ZL',
    MirrorService.welib: 'WL',
    MirrorService.annasArchive: 'AA',
  };

  Future<void> _refresh() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      final result = await _viewModel.refresh();
      if (!mounted || result == null) return;
      if (!result.hasMirrorList) {
        // Nothing is known - saying "up to date" would claim the empty
        // list is SLUM's answer.
        messenger.showSnackBar(SnackBar(
          content: Text(l10n.mirrorCatalogueUnreachable),
        ));
        return;
      }
      messenger.showSnackBar(SnackBar(
        content: Text(result.changes.isEmpty
            ? l10n.mirrorListUpToDate
            : l10n.mirrorListUpdated(result.changes.length)),
        duration: const Duration(seconds: 2),
      ));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.mirrorRefreshFailed('$e')),
      ));
    }
  }

  Future<void> _testLatency() async {
    if (_viewModel.latency.testing) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      final result = await _viewModel.testLatency();
      if (!mounted || result == null) return;
      final String message;
      if (result.total == 0) {
        message = l10n.mirrorLatencyNoTargets;
      } else if (result.reachable == 0) {
        message = l10n.mirrorLatencyAllTimedOut;
      } else {
        message = l10n.mirrorLatencyDone(
          result.reachable,
          result.total,
          formatMirrorLatency(result.fastestMs!),
        );
      }
      messenger.showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.mirrorLatencyFailed('$e')),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final autoMode = _viewModel.autoMode;
        final latency = _viewModel.latency;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.mirrorsAndProviders),
            actions: [
              IconButton(
                key: const ValueKey('mirror-latency-test'),
                onPressed: latency.testing ? null : _testLatency,
                tooltip: l10n.mirrorLatencyTestTooltip,
                icon: latency.testing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.speed_rounded, size: 20),
              ),
              IconButton(
                onPressed: _viewModel.refreshing ? null : _refresh,
                tooltip: l10n.refreshMirrors,
                icon: _viewModel.refreshing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded, size: 20),
              ),
            ],
          ),
          body: ContentWidth(
            maxWidth: 840,
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  InlineHint(
                      message: l10n.mirrorFooterNote,
                      icon: Icons.shield_outlined),
                  for (final service in InstancesViewModel.serviceOrder)
                    _serviceList(service, autoMode, latency),
                  const SizedBox(height: 16),
                  _buildModeCard(autoMode),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeCard(bool autoMode) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: SettingsRow(
        icon: autoMode ? Icons.auto_awesome : Icons.touch_app,
        title: l10n.automaticMirrorOrder,
        subtitle:
            autoMode ? l10n.mirrorOrderAutoHint : l10n.mirrorOrderManualHint,
        trailing: Switch(
          value: autoMode,
          onChanged: (value) async {
            await _viewModel.setAutoMode(value);
          },
        ),
      ),
    );
  }

  Widget _serviceList(
      MirrorService service, bool autoMode, MirrorLatencyState latency) {
    final l10n = AppLocalizations.of(context);
    final views = _viewModel.instances[service];
    final error = _viewModel.errorFor(service);

    if (_viewModel.isLoading(service)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionLabel(service, 0, l10n),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionLabel(service, 0, l10n),
          Card(
            child: SettingsRow(
              icon: Icons.error_outline,
              title: l10n.couldNotLoadMirrors,
              subtitle: '$error',
            ),
          ),
        ],
      );
    }

    final list = views ?? const <InstanceView>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(service, list.length, l10n),
        if (list.isEmpty)
          Card(
            child: SettingsRow(
              icon: Icons.cloud_off,
              title: l10n.noMirrorsReported,
              subtitle: l10n.noMirrorsReportedHint,
              trailing: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refresh,
              ),
            ),
          )
        else
          for (var i = 0; i < list.length; i++) ...[
            _mirrorCard(service, list[i], i, list.length, autoMode, latency),
            if (i < list.length - 1) const SizedBox(height: 8),
          ],
      ],
    );
  }

  Widget _sectionLabel(
    MirrorService service,
    int count,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        '${_serviceTitles[service]} · ${l10n.mirrorNodeCount(count)}',
        style: SwissText.micro.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.66,
        ),
      ),
    );
  }

  Widget _mirrorCard(MirrorService service, InstanceView view, int index,
      int total, bool autoMode, MirrorLatencyState latency) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final site = view.site;
    final down = site.isDown;
    final mark = _serviceMarks[service] ?? '?';
    final (logoBackground, logoForeground) = switch (mark) {
      'AA' => (scheme.primaryContainer, scheme.onPrimaryContainer),
      'ZL' => (scheme.tertiaryContainer, scheme.tertiary),
      _ => (scheme.surfaceContainer, scheme.onSurfaceVariant),
    };
    final subtitle = site.protection == Protection.none
        ? l10n.mirrorStatusUp
        : site.protection.label;

    return Opacity(
      opacity: down ? 0.55 : 1,
      child: Card(
        margin: EdgeInsets.zero,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SwissRadius.card),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: logoBackground,
                      borderRadius: BorderRadius.circular(SwissRadius.sm),
                    ),
                    child: Text(
                      mark,
                      style: SwissText.micro.copyWith(
                        color: logoForeground,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          site.host,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SwissText.label.copyWith(
                            color: scheme.onSurface,
                            decoration:
                                down ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SwissText.micro.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: view.enabled && !down,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: down
                        ? null
                        : (value) async {
                            await _viewModel.setEnabled(
                                service, site.host, value);
                          },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: scheme.outlineVariant.withValues(alpha: 0.55),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: _statusColor(scheme, site.status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            [
                              _statusLabel(l10n, site.status),
                              if (site.latencyMs != null)
                                'SLUM ${formatMirrorLatency(site.latencyMs!)}',
                              if (down) l10n.reportedDownNeverContacted,
                            ].join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: SwissText.micro.copyWith(
                              color: down
                                  ? scheme.tertiary
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (!autoMode) ...[
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_up, size: 18),
                            visualDensity: VisualDensity.compact,
                            tooltip: l10n.moveUp,
                            onPressed: index == 0
                                ? null
                                : () async {
                                    await _viewModel.move(
                                        service, site.host, -1);
                                  },
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.keyboard_arrow_down, size: 18),
                            visualDensity: VisualDensity.compact,
                            tooltip: l10n.moveDown,
                            onPressed: index == total - 1
                                ? null
                                : () async {
                                    await _viewModel.move(
                                        service, site.host, 1);
                                  },
                          ),
                        ],
                      ],
                    ),
                    if (!down) ...[
                      const SizedBox(height: 4),
                      _localLatencyLine(view, latency),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _localLatencyLine(InstanceView view, MirrorLatencyState latency) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final site = view.site;
    final reading = latency.readings[site.host];
    final testing = latency.testing && latency.testingHosts.contains(site.host);

    Widget dot(Color color) => Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );

    Widget line(Widget leading, String text, Color color) {
      return Row(
        key: ValueKey('mirror-local-latency-${site.host}'),
        children: [
          leading,
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SwissText.micro.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    }

    if (testing) {
      return line(
        const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(strokeWidth: 1.5),
        ),
        l10n.mirrorLatencyTesting,
        scheme.onSurfaceVariant,
      );
    }
    if (reading == null) {
      return line(
        dot(scheme.outlineVariant),
        l10n.mirrorLatencyNotTested,
        scheme.outline,
      );
    }

    final milliseconds = reading.milliseconds;
    if (milliseconds == null) {
      return line(
        dot(scheme.error),
        l10n.mirrorLatencyTimeout,
        scheme.error,
      );
    }

    final now = DateTime.now();
    final stale = !reading.isFreshAt(now);
    final parts = [l10n.mirrorLatencyLocal(formatMirrorLatency(milliseconds))];
    if (view.site.protection != Protection.none) {
      parts.add(l10n.mirrorLatencyNeedsVerification);
    }
    if (stale) {
      parts.add(l10n.mirrorLatencyExpired);
    } else {
      final age = now.difference(reading.testedAt);
      if (!age.isNegative && age < const Duration(minutes: 1)) {
        parts.add(l10n.mirrorLatencyJustNow);
      }
    }
    final color = stale
        ? scheme.outline
        : milliseconds >= 1000
            ? scheme.tertiary
            : scheme.primary;
    return line(dot(color), parts.join(' · '), color);
  }

  Color _statusColor(ColorScheme scheme, SlumStatus status) {
    return switch (status) {
      SlumStatus.up => scheme.primary,
      SlumStatus.degraded => scheme.tertiary,
      SlumStatus.protected => scheme.secondary,
      SlumStatus.down => scheme.error,
      SlumStatus.unknown => scheme.outline,
    };
  }
}
