// Dart imports:
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:openlib/services/backup_service.dart';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/services/files.dart';
import 'package:openlib/services/platform_utils.dart';
import 'package:openlib/services/update_checker.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:openlib/services/book_format.dart';
import 'package:openlib/services/database.dart';
import 'package:openlib/services/logger.dart';
import 'package:openlib/services/search_manager.dart';
import 'package:openlib/services/webview_challenge_solver.dart';
import 'package:openlib/ui/components/content_width.dart';
import 'package:openlib/ui/components/page_header.dart';
import 'package:openlib/ui/components/pill_tabs.dart';
import 'package:openlib/ui/components/settings_row.dart';
import 'package:openlib/ui/swiss_grid.dart';
import 'package:openlib/ui/components/search_source_meta.dart';
import 'package:openlib/ui/components/snack_bar_widget.dart';
import 'package:openlib/ui/about_page.dart';
import 'package:openlib/ui/instances_page.dart';
import 'package:openlib/ui/onboarding/onboarding_page.dart';
import 'package:openlib/ui/themes.dart' show openlibColorScheme;

import 'package:openlib/state/state.dart'
    show
        themeModeProvider,
        fontSizeScaleProvider,
        showManualDownloadButtonProvider,
        backgroundVerificationProvider,
        donationKeyProvider,
        myLibraryProvider,
        searchProviderToggles,
        searchSourceOrderProvider,
        localeOverrideProvider,
        downloadManagerProvider;

// Scans a directory for book files (epub, pdf) and imports them to the library database
Future<void> scanAndImportBooks(
    String directoryPath, MyLibraryDb database, WidgetRef ref) async {
  try {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) return;

    final files = directory.listSync(recursive: false);
    int importedCount = 0;

    for (var entity in files) {
      if (entity is File) {
        final fileName = entity.path.split(Platform.pathSeparator).last;
        final extension = fileName.split('.').last.toLowerCase();

        if (isSupportedBookFormat(extension)) {
          // Extract the md5 hash from the filename (the part before the extension)
          final parts = fileName.split('.');
          if (parts.length >= 2) {
            final md5 = parts.sublist(0, parts.length - 1).join('.');

            // Check if this book already exists in the database
            final exists = await database.checkIdExists(md5);
            if (!exists) {
              // Create a minimal book entry for the imported file
              final book = MyBook(
                id: md5,
                title:
                    md5, // Use filename as title since we don't have metadata
                author: "Unknown",
                thumbnail: "",
                link: "",
                publisher: "",
                info: "",
                description: "",
                format: extension,
              );
              await database.insert(book);
              importedCount++;
            }
          }
        }
      }
    }

    // Refresh the library provider to show new books
    if (importedCount > 0) {
      // ignore: unused_result
      ref.refresh(myLibraryProvider);
    }
  } catch (e) {
    // Silently fail - don't interrupt user flow
  }
}

Future<void> requestStoragePermission() async {
  // Desktop platforms don't require runtime storage permissions
  if (PlatformUtils.isDesktop) return;

  // Check whether the device is running Android 11 or higher
  DeviceInfoPlugin plugin = DeviceInfoPlugin();
  AndroidDeviceInfo android = await plugin.androidInfo;
  // Android < 11
  if (android.version.sdkInt < 33) {
    if (await Permission.storage.request().isGranted) {
      // Permission granted
    } else if (await Permission.storage.request().isPermanentlyDenied) {
      await openAppSettings();
    }
  }
  // Android > 11
  else {
    if (await Permission.manageExternalStorage.request().isGranted) {
      // Permission granted
    } else if (await Permission.manageExternalStorage
        .request()
        .isPermanentlyDenied) {
      await openAppSettings();
    } else if (await Permission.manageExternalStorage.request().isDenied) {
      // Permission denied
    }
  }
}

// ---------------------------------------------------------------------------
// Shared building blocks: every settings row renders through these, so all
// sections share one card shape, spacing and typography.
// ---------------------------------------------------------------------------

/// Groups rows into one card with an optional in-card section label.
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                title!.toUpperCase(),
                style: SwissText.micro.copyWith(
                  color: scheme.outline,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.32,
                ),
              ),
            ),
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0) const Divider(height: 1),
            children[index],
          ],
        ],
      ),
    );
  }
}

/// Tappable row with optional icon, subtitle and trailing element. Pass a
/// [busy] flag to swap the trailing chevron for a progress spinner.
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    this.subtitle,
    this.icon,
    this.busy = false,
    this.showChevron = true,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool busy;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget? resolvedTrailing = busy
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : showChevron
            ? const Icon(Icons.chevron_right, size: 20)
            : null;

    return SettingsRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: resolvedTrailing,
      onTap: onTap,
    );
  }
}

/// Switch row in the same card shape as [_SettingsTile].
class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.title,
    this.subtitle,
    this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
      onTap: onChanged == null ? null : () => onChanged!(!value),
    );
  }
}

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 4, vsync: this);

  // Kept on the State instead of being rebuilt in build(): a new future
  // per build meant a database query and a platform-channel call every
  // time the page rebuilt, including while switching tabs.
  late Future<dynamic> _storageDirectory = _readStorageDirectory();
  late final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  Future<dynamic> _readStorageDirectory() async {
    try {
      return await MyLibraryDb.instance.getPreference('bookStorageDirectory');
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showManualDownload = ref.watch(showManualDownloadButtonProvider);
    final backgroundVerification = ref.watch(backgroundVerificationProvider);
    final l10n = AppLocalizations.of(context);
    final dataBase = MyLibraryDb.instance;

    return ContentWidth(
      maxWidth: 900,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: PageHeader(
              eyebrow: l10n.settingsEyebrow,
              title: l10n.settingsTitle,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            ),
          ),
          PillTabs(
            controller: _tabController,
            tabs: [
              Tab(text: l10n.searchProvidersSection),
              Tab(text: l10n.appearanceSection),
              Tab(text: l10n.advancedSection),
              Tab(text: l10n.aboutSection),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _sourcesTab(context, ref, dataBase, l10n),
                _appearanceTab(context, ref, dataBase, l10n),
                _advancedTab(context, ref, dataBase, l10n, showManualDownload,
                    backgroundVerification),
                _aboutTab(context, ref, dataBase, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sourcesTab(BuildContext context, WidgetRef ref, MyLibraryDb dataBase,
      AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const _SearchProvidersWidget(),
        const SizedBox(height: 12),
        _SettingsGroup(
          title: l10n.sourceBehaviorSection,
          children: [
            _SettingsTile(
              title: l10n.mirrorsAndProviders,
              icon: Icons.dns,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const InstancesPage()));
              },
            ),
            _SettingsTile(
              title: l10n.donationKeyTitle,
              subtitle: l10n.enterKeyForFasterDownloads,
              icon: Icons.key,
              onTap: () => _showDonationKeyDialog(context, ref, dataBase),
            ),
          ],
        ),
      ],
    );
  }

  Widget _appearanceTab(BuildContext context, WidgetRef ref,
      MyLibraryDb dataBase, AppLocalizations l10n) {
    return ListView(
      key: const ValueKey('appearance-list'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _SettingsGroup(
          children: const [_LanguageSelectorWidget()],
        ),
        _SettingsGroup(
          title: l10n.themeTitle,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _ThemeSelectorWidget(),
            ),
          ],
        ),
        _SettingsGroup(
          title: l10n.displaySection,
          children: [
            _FontSizeSelector(dataBase: dataBase),
          ],
        ),
      ],
    );
  }

  Widget _advancedTab(
      BuildContext context,
      WidgetRef ref,
      MyLibraryDb dataBase,
      AppLocalizations l10n,
      bool showManualDownload,
      bool backgroundVerification) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _SettingsGroup(
          title: l10n.generalSection,
          children: [
            FutureBuilder<dynamic>(
              future: _storageDirectory,
              builder: (context, snapshot) {
                String subtitle = l10n.changeStorageHint;
                if (snapshot.hasData && snapshot.data is String) {
                  subtitle = snapshot.data as String;
                }
                return _SettingsTile(
                  title: l10n.storageLocation,
                  subtitle: subtitle,
                  icon: Icons.folder,
                  onTap: () async {
                    final currentDirectory =
                        await dataBase.getPreference('bookStorageDirectory');
                    String? pickedDirectory = await pickBookStorageDirectory();
                    if (pickedDirectory == null) return;
                    await requestStoragePermission();

                    if (currentDirectory != pickedDirectory) {
                      await moveLibraryFiles(currentDirectory, pickedDirectory);
                    }

                    await dataBase.savePreference(
                        'bookStorageDirectory', pickedDirectory);
                    await scanAndImportBooks(pickedDirectory, dataBase, ref);
                    // ignore: unused_result
                    ref.refresh(myLibraryProvider);
                    if (!mounted) return;
                    setState(() {
                      _storageDirectory = Future.value(pickedDirectory);
                    });
                  },
                );
              },
            ),
          ],
        ),
        _SettingsGroup(
          title: l10n.behaviorSection,
          children: [
            _SettingsSwitchTile(
              title: l10n.manualDownloadButton,
              subtitle: l10n.showManualDownloadHint,
              icon: Icons.download_outlined,
              value: showManualDownload,
              onChanged: (val) {
                ref.read(showManualDownloadButtonProvider.notifier).state = val;
                dataBase.savePreference('showManualDownloadButton', val);
              },
            ),
            _SettingsSwitchTile(
              title: l10n.backgroundVerification,
              subtitle: l10n.backgroundVerificationHint,
              icon: Icons.verified_user_outlined,
              value: backgroundVerification,
              onChanged: (val) {
                ref.read(backgroundVerificationProvider.notifier).state = val;
                WebviewChallengeSolver.headlessEnabled = val;
                dataBase.savePreference('backgroundVerification', val ? 1 : 0);
              },
            ),
          ],
        ),
        const _UpdateSettingsWidget(),
        _BackupSettingsWidget(database: dataBase),
        _SettingsGroup(
          title: l10n.maintenanceSection,
          children: [
            _SettingsTile(
              title: l10n.exportLogs,
              subtitle: l10n.shareDiagnosticLogs,
              icon: Icons.bug_report,
              onTap: () => _exportLogs(context),
            ),
            _SettingsTile(
              title: l10n.redoOnboarding,
              subtitle: l10n.resetAppSetup,
              icon: Icons.restart_alt,
              onTap: () => _redoOnboarding(context, dataBase),
            ),
          ],
        ),
      ],
    );
  }

  Widget _aboutTab(BuildContext context, WidgetRef ref, MyLibraryDb dataBase,
      AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        FutureBuilder<PackageInfo>(
          future: _packageInfo,
          builder: (context, snapshot) {
            final version =
                snapshot.hasData ? 'v${snapshot.data!.version}' : '';
            final scheme = Theme.of(context).colorScheme;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.primary.withValues(alpha: 0.24),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/icons/appIcon.png',
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OpenlibExtended',
                            style: SwissText.subtitle.copyWith(
                              fontWeight: FontWeight.w800,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            version.isEmpty
                                ? 'AGPL-3.0'
                                : '$version · AGPL-3.0',
                            style: SwissText.micro.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 24,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'AGPL-3.0',
                        style: SwissText.badge.copyWith(
                          color: scheme.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _SettingsGroup(
          title: l10n.infoSection,
          children: [
            _SettingsTile(
              title: l10n.changelogTitle,
              icon: Icons.history,
              onTap: () => _launchUrl(
                context,
                'https://github.com/lzoreal/OpenlibExtended/releases',
              ),
            ),
            _SettingsTile(
              title: l10n.openSourceLicenses,
              icon: Icons.gavel_outlined,
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'OpenlibExtended',
              ),
            ),
            _SettingsTile(
              title: l10n.projectHome,
              icon: Icons.language,
              onTap: () => _launchUrl(
                context,
                'https://github.com/lzoreal/OpenlibExtended',
              ),
            ),
            _SettingsTile(
              title: l10n.aboutOpenlib,
              icon: Icons.info_outline,
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const AboutPage()));
              },
            ),
          ],
        ),
        _SettingsGroup(
          title: l10n.thanksSection,
          children: [
            _SettingsTile(
              title: l10n.slumCatalogue,
              subtitle: l10n.slumCatalogueSubtitle,
              icon: Icons.dns_outlined,
              onTap: () => _launchUrl(context, 'https://open-slum.org'),
            ),
            _SettingsTile(
              title: l10n.challengeSolverTitle,
              subtitle: l10n.challengeSolverSubtitle,
              icon: Icons.shield_outlined,
              showChevron: false,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
          child: Text(
            l10n.aboutDisclaimer,
            textAlign: TextAlign.center,
            style: SwissText.micro.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final l10n = AppLocalizations.of(context);
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        showSnackBar(context: context, message: l10n.couldNotLaunch(url));
      }
    }
  }

  Future<void> _exportLogs(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      await AppLogger().exportLogs(
        saveDialogTitle: l10n.exportLogs,
        shareSubject: l10n.appLogsShareSubject,
        shareText:
            l10n.appLogsShareText(AppLogger.logRetentionDuration.inMinutes),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedExportLogs('$e'))),
        );
      }
    }
  }

  Future<void> _redoOnboarding(
      BuildContext context, MyLibraryDb dataBase) async {
    await dataBase.savePreference('onboardingCompleted', 0);
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const OnboardingPage()),
        (route) => false,
      );
    }
  }

  void _showDonationKeyDialog(
      BuildContext context, WidgetRef ref, MyLibraryDb dataBase) {
    final dialogL10n = AppLocalizations.of(context);
    final currentKey = ref.read(donationKeyProvider);
    final controller = TextEditingController(text: currentKey);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context).donationKeyDialog),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: dialogL10n.enterYourKey,
            helperText: dialogL10n.donationKeyHelper,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(dialogL10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final newKey = controller.text.trim();
              ref.read(donationKeyProvider.notifier).state = newKey;
              dataBase.savePreference('donationKey', newKey);
              Navigator.pop(dialogContext);
            },
            child: Text(dialogL10n.save),
          ),
        ],
      ),
    );
  }
}

// Update settings widget with prerelease toggle and check button
class _UpdateSettingsWidget extends StatefulWidget {
  const _UpdateSettingsWidget();

  @override
  State<_UpdateSettingsWidget> createState() => _UpdateSettingsWidgetState();
}

class _UpdateSettingsWidgetState extends State<_UpdateSettingsWidget> {
  final UpdateCheckerService _updateChecker = UpdateCheckerService();
  bool _includePrereleases = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final value = await _updateChecker.getIncludePrereleases();
    if (mounted) {
      setState(() {
        _includePrereleases = value;
      });
    }
  }

  Future<void> _checkForUpdates() async {
    final updateL10n = AppLocalizations.of(context);
    setState(() {
      _isChecking = true;
    });

    try {
      final result = await _updateChecker.checkForUpdates(
        includePrereleases: _includePrereleases,
      );

      if (!mounted) return;

      if (result.updateAvailable && result.latestRelease != null) {
        await _updateChecker.showUpdateDialog(context, result.latestRelease!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(updateL10n.onLatestVersion(result.currentVersion)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(updateL10n.failedCheckUpdates(e.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _SettingsGroup(
      title: l10n.updatesSection,
      children: [
        _SettingsSwitchTile(
          title: l10n.includeBetaUpdates,
          subtitle: l10n.getPreReleaseVersions,
          icon: Icons.science_outlined,
          value: _includePrereleases,
          onChanged: (bool value) async {
            setState(() {
              _includePrereleases = value;
            });
            await _updateChecker.setIncludePrereleases(value);
          },
        ),
        _SettingsTile(
          title: l10n.checkForUpdates,
          icon: Icons.refresh,
          busy: _isChecking,
          onTap: _isChecking ? null : _checkForUpdates,
        ),
      ],
    );
  }
}

/// Toggles which catalogs the search fans out to. Disabling the last
/// source is refused - there is nothing to search without one.
///
/// The cards also carry the automatic chain's order: dragging one onto
/// another drops it into that slot. The stored order is shared with the
/// search capsules, the suggestions panel and the manager's fallback.
class _SearchProvidersWidget extends ConsumerWidget {
  const _SearchProvidersWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = ref.watch(searchProviderToggles);
    // The grid has to stay on screen across the refresh that follows a
    // drop, so an in-flight save keeps showing the order it started from.
    final order = ref.watch(searchSourceOrderProvider).valueOrNull ??
        fallbackSearchSourceOrder;
    final touch = theme.platform == TargetPlatform.android ||
        theme.platform == TargetPlatform.iOS;

    return enabled.when(
      data: (enabledIds) {
        final manager = SearchManager();
        final catalog = {
          SearchProviderId.annasArchive: (
            name: "Anna's Archive",
            subtitle: l10n.providerSourceOriginal,
            mark: 'AA',
          ),
          SearchProviderId.libgen: (
            name: 'LibGen',
            subtitle: l10n.providerLibgenCatalog,
            mark: 'LG',
          ),
          SearchProviderId.zlibrary: (
            name: 'Z-Library',
            subtitle: l10n.providerZlibMirrors,
            mark: 'ZL',
          ),
          SearchProviderId.welib: (
            name: 'WeLib',
            subtitle: l10n.providerWelibCatalog,
            mark: 'WL',
          ),
        };
        final ids = order.where(catalog.containsKey).toList(growable: false);

        Future<void> moveTo(SearchProviderId dragged, int targetIndex) async {
          final next = [...ids];
          final from = next.indexOf(dragged);
          if (from < 0 || from == targetIndex) return;
          next.removeAt(from);
          // The dragged card takes the target's slot; removing it first
          // shifts everything after it, so the target index still lands
          // right in both directions.
          next.insert(targetIndex, dragged);
          await manager.setSourceOrder(next);
          // ignore: unused_result
          ref.refresh(searchSourceOrderProvider);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
              child: Text(
                l10n.searchSourcesIntro,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
            ),
            for (var index = 0; index < ids.length; index++) ...[
              Builder(
                builder: (context) {
                  final id = ids[index];
                  final provider = catalog[id]!;
                  final selected = enabledIds.contains(id);

                  Future<void> toggle() async {
                    if (selected && enabledIds.length == 1) {
                      showSnackBar(
                          context: context, message: l10n.atLeastOneSource);
                      return;
                    }
                    await manager.setProviderEnabled(id, !selected);
                    // ignore: unused_result
                    ref.refresh(searchProviderToggles);
                  }

                  return _DraggableProviderCard(
                    key: ValueKey(id.name),
                    id: id,
                    touch: touch,
                    onDropped: (dragged) => moveTo(dragged, index),
                    child: _ProviderCard(
                      mark: provider.mark,
                      name: provider.name,
                      subtitle: provider.subtitle,
                      selected: selected,
                      longPressTooltip: !touch,
                      onTap: toggle,
                      onOpenMirrors: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InstancesPage(),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              if (index < ids.length - 1) const SizedBox(height: 9),
            ],
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}

/// One source card that can be dropped onto another slot.
///
/// Touch screens need a long press first, otherwise the settings page's
/// scroll view takes the drag. Desktop uses the immediate drag, which the
/// scroll view ignores for mouse pointers.
class _DraggableProviderCard extends StatelessWidget {
  const _DraggableProviderCard({
    super.key,
    required this.id,
    required this.touch,
    required this.onDropped,
    required this.child,
  });

  final SearchProviderId id;
  final bool touch;
  final ValueChanged<SearchProviderId> onDropped;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DragTarget<SearchProviderId>(
      onWillAcceptWithDetails: (details) => details.data != id,
      onAcceptWithDetails: (details) => onDropped(details.data),
      builder: (context, candidates, rejected) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final feedback = SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: child,
              ),
            );
            final dragging = touch
                ? LongPressDraggable<SearchProviderId>(
                    data: id,
                    feedback: feedback,
                    childWhenDragging: Opacity(opacity: 0.35, child: child),
                    child: child,
                  )
                : Draggable<SearchProviderId>(
                    data: id,
                    feedback: feedback,
                    childWhenDragging: Opacity(opacity: 0.35, child: child),
                    child: child,
                  );

            return Stack(
              children: [
                dragging,
                if (candidates.isNotEmpty)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: scheme.primary, width: 2),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.mark,
    required this.name,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    required this.onOpenMirrors,
    this.longPressTooltip = true,
  });

  final String mark;
  final String name;
  final String subtitle;
  final bool selected;
  // Touch drags start with a long press, so the tooltip cannot also wait
  // for one; its text stays in the semantics tree either way.
  final bool longPressTooltip;
  final VoidCallback onTap;
  final VoidCallback onOpenMirrors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final (logoBackground, logoForeground) = switch (mark) {
      'AA' => (scheme.primaryContainer, scheme.onPrimaryContainer),
      'ZL' => (scheme.tertiaryContainer, scheme.tertiary),
      _ => (scheme.surfaceContainer, scheme.onSurfaceVariant),
    };

    return Semantics(
      button: true,
      toggled: selected,
      label: name,
      child: Tooltip(
        message: subtitle,
        triggerMode: longPressTooltip
            ? TooltipTriggerMode.longPress
            : TooltipTriggerMode.manual,
        child: Card(
          margin: EdgeInsets.zero,
          color: scheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: selected
                  ? scheme.primary.withValues(alpha: 0.35)
                  : scheme.outlineVariant,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: logoBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          mark,
                          style: SwissText.micro.copyWith(
                            color: logoForeground,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: SwissText.label,
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
                        value: selected,
                        onChanged: (_) => onTap(),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                    child: Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: selected ? scheme.secondary : scheme.outline,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          selected ? l10n.sourceOn : l10n.sourceOff,
                          style: SwissText.badge.copyWith(
                            color: selected ? scheme.secondary : scheme.outline,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: onOpenMirrors,
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            l10n.mirrorsShort,
                            style: SwissText.micro.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
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

/// Export/import the whole app state: settings, saved books, reading
/// positions, instances. One JSON file, shareable or pickable.
class _BackupSettingsWidget extends ConsumerWidget {
  const _BackupSettingsWidget({required this.database});

  final MyLibraryDb database;

  Future<void> _export(BuildContext context) async {
    final service = BackupService(database: database);
    final exportL10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final json = await service.createBackupJson();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final fileName = 'openlib_backup_$timestamp.json';

      if (PlatformUtils.isDesktop) {
        final target = await FilePicker.saveFile(
          dialogTitle: exportL10n.saveBackupTitle,
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['json'],
          bytes: Uint8List.fromList(utf8.encode(json)),
        );
        if (target == null) return;
        if (context.mounted) {
          showSnackBar(
              context: context,
              message: AppLocalizations.of(context).backupSaved);
        }
      } else {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsString(json);
        await SharePlus.instance.share(ShareParams(
          files: [XFile(file.path)],
          text: exportL10n.backupShareText,
        ));
      }
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text(exportL10n.failedExportBackup('$e'))));
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final service = BackupService(database: database);
    final importL10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final files = await FilePicker.pickFiles(
        dialogTitle: importL10n.pickBackupFile,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      final path = files.single.path;
      if (path == null) return;

      final restored = await service.restoreBackupFile(path);
      if (!restored) {
        if (context.mounted) {
          showSnackBar(context: context, message: importL10n.notABackup);
        }
        return;
      }
      // Imported preferences/instances must reach the live UI.
      // ignore: unused_result
      ref.refresh(myLibraryProvider);
      // ignore: unused_result
      ref.refresh(searchProviderToggles);
      if (context.mounted) {
        showSnackBar(
            context: context,
            message: AppLocalizations.of(context).backupRestored);
      }
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text(importL10n.failedImportBackup('$e'))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return _SettingsGroup(
      title: l10n.backupSection,
      children: [
        _SettingsTile(
          title: l10n.exportBackupTitle,
          subtitle: l10n.exportBackupSubtitle,
          icon: Icons.file_upload_outlined,
          onTap: () => _export(context),
        ),
        _SettingsTile(
          title: l10n.importBackupTitle,
          subtitle: l10n.importBackupSubtitle,
          icon: Icons.file_download_outlined,
          onTap: () => _import(context, ref),
        ),
      ],
    );
  }
}

// ====================================================================
// LANGUAGE SELECTOR
// Dropdown that pins the app to one of the supported locales, or
// follows the system default. Choice persists in the preferences
// table under the 'locale' key.
// ====================================================================
const _nativeLanguageNames = {
  'en': 'English',
  'de': 'Deutsch',
  'fr': 'Français',
  'es': 'Español',
  'zh': '中文',
};

/// Collapsed language row that expands into a two/three-column option grid
/// only when tapped, keeping the appearance tab short by default.
class _LanguageSelectorWidget extends ConsumerStatefulWidget {
  const _LanguageSelectorWidget();

  @override
  ConsumerState<_LanguageSelectorWidget> createState() =>
      _LanguageSelectorWidgetState();
}

class _LanguageSelectorWidgetState
    extends ConsumerState<_LanguageSelectorWidget> {
  bool _expanded = false;

  void _select(Locale? value) {
    ref.read(localeOverrideProvider.notifier).state = value;
    ref
        .read(downloadManagerProvider)
        .setLocale(value ?? WidgetsBinding.instance.platformDispatcher.locale);
    MyLibraryDb.instance
        .savePreference('locale', value?.languageCode ?? '')
        .catchError((_) => 0);
    setState(() => _expanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = ref.watch(localeOverrideProvider);
    final l10n = AppLocalizations.of(context);
    final activeCode = Localizations.localeOf(context).languageCode;
    final systemNative = _nativeLanguageNames[activeCode] ?? activeCode;
    final nativeName =
        _nativeLanguageNames[locale?.languageCode ?? activeCode] ?? activeCode;
    final options = <Widget>[
      _LanguageRow(
        code: 'AUTO',
        title: l10n.systemLanguage,
        subtitle: locale == null ? l10n.currentLanguage : systemNative,
        selected: locale == null,
        onTap: () => _select(null),
      ),
      for (final supported in AppLocalizations.supportedLocales)
        _LanguageRow(
          code: supported.languageCode == 'zh'
              ? '中'
              : supported.languageCode.toUpperCase(),
          title: _nativeLanguageNames[supported.languageCode] ??
              supported.languageCode,
          subtitle: locale?.languageCode == supported.languageCode
              ? l10n.currentLanguage
              : supported.languageCode.toUpperCase(),
          selected: locale?.languageCode == supported.languageCode,
          onTap: () => _select(supported),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            key: const ValueKey('language-selector-toggle'),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      Icons.translate_rounded,
                      size: 19,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.languageSetting,
                          style: SwissText.label,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.languageCardHint,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SwissText.micro.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    nativeName,
                    style: SwissText.caption.copyWith(
                      color: scheme.outline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    child: Icon(
                      Icons.expand_more_rounded,
                      size: 20,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: _expanded
              ? Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: scheme.outlineVariant.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      for (var index = 0; index < options.length; index++) ...[
                        if (index > 0)
                          Divider(
                            height: 1,
                            color:
                                scheme.outlineVariant.withValues(alpha: 0.55),
                          ),
                        options[index],
                      ],
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: selected
          ? scheme.primaryContainer.withValues(alpha: 0.35)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? scheme.primaryContainer
                      : scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  code,
                  style: SwissText.badge.copyWith(
                    color: selected
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SwissText.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: selected ? scheme.primary : scheme.onSurface,
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
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? scheme.primary : scheme.outline,
                    width: selected ? 2 : 1.8,
                  ),
                ),
                child: selected
                    ? Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pick a theme by looking at it: three miniature app previews instead of
/// a text dropdown.
class _ThemeSelectorWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final l10n = AppLocalizations.of(context);

    void select(ThemeMode value) {
      ref.read(themeModeProvider.notifier).setTheme(value);
    }

    return Row(
      children: [
        Expanded(
          child: _ThemeOption(
            mode: ThemeMode.light,
            label: l10n.themeLightShort,
            selected: mode == ThemeMode.light,
            onTap: () => select(ThemeMode.light),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ThemeOption(
            mode: ThemeMode.dark,
            label: l10n.themeDarkShort,
            selected: mode == ThemeMode.dark,
            onTap: () => select(ThemeMode.dark),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ThemeOption(
            mode: ThemeMode.system,
            label: l10n.followSystem,
            selected: mode == ThemeMode.system,
            onTap: () => select(ThemeMode.system),
          ),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.mode,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final ThemeMode mode;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SwissRadius.field),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                selected ? scheme.primaryContainer : scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(SwissRadius.field),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(SwissRadius.sm),
                child: SizedBox(
                  height: 44,
                  width: double.infinity,
                  child: mode == ThemeMode.system
                      ? Row(
                          children: [
                            Expanded(
                              child: _ThemeSwatch(
                                  scheme: openlibColorScheme(Brightness.light)),
                            ),
                            Expanded(
                              child: _ThemeSwatch(
                                  scheme: openlibColorScheme(Brightness.dark)),
                            ),
                          ],
                        )
                      : _ThemeSwatch(
                          scheme: openlibColorScheme(
                            mode == ThemeMode.dark
                                ? Brightness.dark
                                : Brightness.light,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: SwissText.micro.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected ? scheme.primary : scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _dot(scheme.outlineVariant),
              const SizedBox(width: 3),
              _dot(scheme.primary),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 4),
          FractionallySizedBox(
            widthFactor: 0.55,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: scheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class _FontSizeSelector extends ConsumerWidget {
  const _FontSizeSelector({required this.dataBase});

  final MyLibraryDb dataBase;

  static const _min = 0.8;
  static const _max = 2.0;

  static double _normalize(double value) =>
      (value.clamp(_min, _max) * 10).roundToDouble() / 10;

  Future<void> _persist(double value) async {
    await dataBase.savePreference('fontSizeScale', value.toString());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final scale = ref.watch(fontSizeScaleProvider);

    void select(double value) {
      final next = _normalize(value);
      ref.read(fontSizeScaleProvider.notifier).state = next;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.text_fields,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.fontSizeTitle,
                  style: SwissText.label.copyWith(color: scheme.onSurface),
                ),
              ),
              Text(
                '${(scale * 100).round()}%',
                style: SwissText.caption.copyWith(color: scheme.outline),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Aa',
                style: SwissText.micro.copyWith(color: scheme.outline),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 9),
                  ),
                  child: Slider(
                    value: scale,
                    min: _min,
                    max: _max,
                    divisions: 12,
                    label: '${scale.toStringAsFixed(1)}×',
                    onChanged: select,
                    onChangeEnd: _persist,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Aa',
                style: SwissText.subtitle.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
