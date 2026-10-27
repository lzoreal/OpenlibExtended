// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/services/instance_manager.dart';
import 'package:openlib/services/mirror_latency.dart';
import 'package:openlib/state/state.dart';
import 'package:openlib/ui/components/content_width.dart';
import 'package:openlib/ui/components/settings_row.dart';
import 'package:openlib/ui/swiss_grid.dart';
import 'package:openlib/ui/components/inline_hint.dart';

/// Settings > Mirrors.
///
/// Every mirror the app can talk to, per service, exactly as
/// open-slum.org reports it - the app hardcodes no mirror URLs. Each row
/// shows SLUM's status, the protection gate and its latency, and can be
/// switched off. Ordering is automatic by default (easiest protection
/// first, then fastest); flipping the switch to manual lets the user
/// reorder the mirrors themselves. A mirror SLUM reports DOWN is shown
/// greyed out and is never contacted.
class InstancesPage extends ConsumerStatefulWidget {
  const InstancesPage({super.key});

  @override
  ConsumerState<InstancesPage> createState() => _InstancesPageState();
}

class _InstancesPageState extends ConsumerState<InstancesPage> {
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    // The manager persists the mode; the switch must show the value the
    // manager will actually apply, or a restart in manual mode displays
    // "Automatic mirror order" while using the user's pinned order.
    ref.read(instanceManagerProvider).isAutoMode().then((auto) {
      if (mounted && auto != ref.read(instanceAutoModeProvider)) {
        ref.read(instanceAutoModeProvider.notifier).state = auto;
      }
    });
    ref.read(mirrorLatencyProvider.notifier).load();
  }

  static const _serviceOrder = [
    MirrorService.libgen,
    MirrorService.zlibrary,
    MirrorService.welib,
    MirrorService.annasArchive,
  ];

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

  static String _statusLabel(AppLocalizations l10n, SlumStatus status) {
    return switch (status) {
      SlumStatus.up => l10n.mirrorStatusUp,
      SlumStatus.degraded => l10n.mirrorStatusDegraded,
      SlumStatus.protected => l10n.mirrorStatusProtected,
      SlumStatus.down => l10n.mirrorStatusDown,
      SlumStatus.unknown => l10n.unknown,
    };
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      final result = await ref.read(instanceManagerProvider).refresh();
      if (!mounted) return;
      for (final service in _serviceOrder) {
        ref.invalidate(serviceInstancesProvider(service));
      }
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
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _testLatency() async {
    if (ref.read(mirrorLatencyProvider).testing) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final views = <InstanceView>[];
    for (final service in _serviceOrder) {
      try {
        views.addAll(await ref.read(serviceInstancesProvider(service).future));
      } catch (_) {
        // A service with no catalogue answer simply has nothing to probe.
      }
    }
    if (!mounted) return;

    try {
      final result = await ref.read(mirrorLatencyProvider.notifier).test(views);
      if (!mounted) return;
      for (final service in _serviceOrder) {
        ref.invalidate(serviceInstancesProvider(service));
      }
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
    final autoMode = ref.watch(instanceAutoModeProvider);
    final latency = ref.watch(mirrorLatencyProvider);

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
            onPressed: _refreshing ? null : _refresh,
            tooltip: l10n.refreshMirrors,
            icon: _refreshing
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
                  message: l10n.mirrorFooterNote, icon: Icons.shield_outlined),
              for (final service in _serviceOrder)
                _serviceList(service, autoMode, latency),
              const SizedBox(height: 16),
              _buildModeCard(autoMode),
            ],
          ),
        ),
      ),
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
            await ref.read(instanceManagerProvider).setAutoMode(value);
            ref.read(instanceAutoModeProvider.notifier).state = value;
            for (final service in _serviceOrder) {
              ref.invalidate(serviceInstancesProvider(service));
            }
          },
        ),
      ),
    );
  }

  Widget _serviceList(
      MirrorService service, bool autoMode, MirrorLatencyState latency) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(serviceInstancesProvider(service));

    return async.when(
      data: (views) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionLabel(service, views.length, l10n),
            if (views.isEmpty)
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
              for (var i = 0; i < views.length; i++) ...[
                _mirrorCard(
                    service, views[i], i, views.length, autoMode, latency),
                if (i < views.length - 1) const SizedBox(height: 8),
              ],
          ],
        );
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionLabel(service, 0, l10n),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      error: (error, _) => Column(
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
      ),
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
                            await ref
                                .read(instanceManagerProvider)
                                .setEnabled(service, site.host, value);
                            ref.invalidate(serviceInstancesProvider(service));
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
                                    await ref
                                        .read(instanceManagerProvider)
                                        .move(service, site.host, -1);
                                    ref.invalidate(
                                        serviceInstancesProvider(service));
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
                                    await ref
                                        .read(instanceManagerProvider)
                                        .move(service, site.host, 1);
                                    ref.invalidate(
                                        serviceInstancesProvider(service));
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
