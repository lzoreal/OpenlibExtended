// Flutter imports:
import 'package:flutter/material.dart';


// Package imports:
import 'package:flutter_markdown/flutter_markdown.dart';

// Project imports:
import 'package:openlib/ui/core/components/swipeable_tab_view.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/main.dart' show MainScreen;
import 'package:openlib/data/services/update_checker.dart';
import 'package:openlib/ui/core/components/pill_tabs.dart';
import 'package:openlib/ui/features/whats_new/view_models/whats_new_view_model.dart';

/// Shown once after an app upgrade (not on first install): what's
/// new, plus a tab that offers re-syncing the stored mirror list
/// with the shipped defaults and re-enabling all search providers.
///
/// The features tab prefers the GitHub release description of the
/// running version (rendered as markdown, matching what the release
/// page shows) and falls back to short built-in notes offline.
class WhatsNewPage extends StatefulWidget {
  const WhatsNewPage(
      {super.key,
      required this.fromVersion,
      required this.toVersion,
      this.viewModel});

  /// Version the user upgraded from ('' when unknown).
  final String fromVersion;

  /// Version now running.
  final String toVersion;

  /// Injected by tests; the page builds its own view model otherwise.
  final WhatsNewViewModel? viewModel;

  @override
  State<WhatsNewPage> createState() => _WhatsNewPageState();
}

class _WhatsNewPageState extends State<WhatsNewPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 2, vsync: this);
  late final WhatsNewViewModel _viewModel =
      widget.viewModel ?? WhatsNewViewModel.fromDi();

  bool _instancesUpdated = false;
  List<String> _changes = const [];
  bool _updating = false;

  /// GitHub release description of the running version; null until
  /// fetched, '' when unavailable (offline, rate-limited) - the UI
  /// then shows the built-in notes instead.
  String? _releaseNotes;

  @override
  void initState() {
    super.initState();
    _loadReleaseNotes();
  }

  Future<void> _loadReleaseNotes() async {
    final notes = await UpdateCheckerService().fetchReleaseNotes();
    if (mounted) {
      setState(() => _releaseNotes = notes ?? '');
    }
  }

  Future<void> _updateInstances() async {
    setState(() => _updating = true);
    try {
      final result = await _viewModel.updateInstances();
      if (mounted) {
        setState(() {
          _instancesUpdated = true;
          _changes = result.changes;
        });
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  void _continue() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.upgrade_rounded,
                          size: 34, color: theme.colorScheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.whatsNewTitle(widget.toVersion),
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(l10n.whatsNewIntro,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            PillTabs(
              controller: _tabController,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              tabs: [
                Tab(text: l10n.whatsNewTabFeatures),
                Tab(text: l10n.whatsNewTabSources),
              ],
            ),
            Expanded(
              child: SwipeableTabView(
                controller: _tabController,
                children: [
                  _FeaturesTab(releaseNotes: _releaseNotes ?? ''),
                  _SourcesTab(
                    updated: _instancesUpdated,
                    updating: _updating,
                    changes: _changes,
                    onUpdate: _updateInstances,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: FilledButton(
                onPressed: _continue,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(l10n.whatsNewContinue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturesTab extends StatelessWidget {
  const _FeaturesTab({required this.releaseNotes});

  /// GitHub release description of the running version, '' when it
  /// could not be fetched (offline, rate-limited) - then the built-in
  /// notes render instead.
  final String releaseNotes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // The release description is the single source of truth for what
    // shipped; the built-in list below only covers the gap when it
    // cannot be loaded.
    if (releaseNotes.isNotEmpty) {
      return Markdown(
        data: releaseNotes,
        padding: const EdgeInsets.all(20),
        styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
          h2: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
          h3: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          p: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          listBullet: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          a: TextStyle(color: theme.colorScheme.primary),
        ),
      );
    }

    final notes = [
      (Icons.speed_rounded, l10n.whatsNewFeatureSpeed),
      (Icons.source_rounded, l10n.whatsNewFeatureSourceLabels),
      (Icons.image_rounded, l10n.whatsNewFeatureCovers),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        for (final (icon, text) in notes)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: ListTile(
                leading: Icon(icon, color: theme.colorScheme.primary),
                title: Text(text),
              ),
            ),
          ),
      ],
    );
  }
}

class _SourcesTab extends StatelessWidget {
  const _SourcesTab({
    required this.updated,
    required this.updating,
    required this.changes,
    required this.onUpdate,
  });

  final bool updated;
  final bool updating;
  final List<String> changes;
  final Future<void> Function() onUpdate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(l10n.whatsNewProvidersHint,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 16),
        if (updated) ...[
          Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(l10n.whatsNewInstancesUpdated,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          if (changes.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final change in changes)
              Padding(
                padding: const EdgeInsets.only(left: 28, bottom: 4),
                child: Text(change,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ),
          ],
        ] else
          FilledButton.tonalIcon(
            onPressed: updating ? null : () => onUpdate(),
            icon: updating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync_rounded),
            label: Text(l10n.whatsNewUpdateInstances),
          ),
      ],
    );
  }
}
