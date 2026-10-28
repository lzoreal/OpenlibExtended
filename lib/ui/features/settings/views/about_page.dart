// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// Package imports:
import 'package:url_launcher/url_launcher.dart';
import 'package:yaml/yaml.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/ui/features/shell/widgets/content_width.dart';
import 'package:openlib/ui/core/components/settings_row.dart';
import 'package:openlib/ui/core/swiss_grid.dart';
import 'package:openlib/ui/core/components/snack_bar_widget.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final yamlString = await rootBundle.loadString('pubspec.yaml');
      final yamlMap = loadYaml(yamlString);
      final version = yamlMap['version'] as String;
      setState(() {
        _version = version;
      });
    } catch (e) {
      setState(() {
        _version = AppLocalizations.of(context).unknown;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.about)),
      body: ContentWidth(
        maxWidth: 840,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(SwissRadius.field),
                      child: Image.asset(
                        'assets/icons/appIcon.png',
                        width: 64,
                        height: 64,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'OpenlibExtended',
                      textAlign: TextAlign.center,
                      style: SwissText.headline.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.aboutDescription,
                      textAlign: TextAlign.center,
                      style: SwissText.body.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _AboutChip(
                          label:
                              '${l10n.version} ${_version.isEmpty ? l10n.loading : _version}',
                        ),
                        _AboutChip(label: l10n.gplLicense),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aboutForkNote,
                      style: SwissText.body.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.aboutOriginalNote,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _LinkTile(
                    icon: Icons.code,
                    text: l10n.thisForkByMaintainer,
                    url: 'https://github.com/lzoreal/OpenlibExtended',
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  _LinkTile(
                    icon: Icons.bug_report_outlined,
                    text: l10n.reportAnIssue,
                    url: 'https://github.com/lzoreal/OpenlibExtended/issues',
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  _LinkTile(
                    icon: Icons.history,
                    text: l10n.originalProject,
                    url: 'https://github.com/dstark5/Openlib',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              clipBehavior: Clip.antiAlias,
              child: _LinkTile(
                icon: Icons.gavel_outlined,
                text: l10n.gplLicense,
                subtitle: l10n.licence,
                url: 'https://www.gnu.org/licenses/gpl-3.0.en.html',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutChip extends StatelessWidget {
  const _AboutChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(SwissRadius.pill),
      ),
      child: Align(
        alignment: Alignment.center,
        widthFactor: 1,
        child: Text(
          label,
          style: SwissText.micro.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.text,
    required this.url,
    this.subtitle,
  });

  final IconData icon;
  final String text;
  final String? subtitle;
  final String url;

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      icon: icon,
      title: text,
      subtitle: subtitle,
      trailing: Icon(
        Icons.open_in_new,
        size: 16,
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: () async {
        final l10n = AppLocalizations.of(context);
        final uri = Uri.parse(url);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          final message = l10n.couldNotLaunch('$uri');
          // ignore: use_build_context_synchronously
          showSnackBar(context: context, message: message);
        }
      },
    );
  }
}
