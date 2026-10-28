import 'dart:io';

import 'package:flutter/material.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/app/app_settings.dart';
import 'package:openlib/app/di.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openlib/main.dart' show MainScreen;
import 'package:openlib/data/services/book_import.dart';
import 'package:openlib/data/services/database.dart';
import 'package:openlib/data/services/files.dart';
import 'package:openlib/state/state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _storagePath = '';
  bool _enableAutoUpdate = true;
  bool _enableBetaUpdates = false;
  bool _enableNotifications = false;
  final TextEditingController _donationKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDefaultStorage();
    _loadDonationKey();
    _loadBetaUpdatesPref();
  }

  Future<void> _loadBetaUpdatesPref() async {
    final db = MyLibraryDb.instance;
    try {
      final value = await db.getPreference('includePrereleaseUpdates');
      if (mounted) {
        setState(() {
          _enableBetaUpdates = value == 1;
        });
      }
    } catch (_) {
      // default false
    }
  }

  Future<void> _loadDonationKey() async {
    final db = MyLibraryDb.instance;
    String key = '';
    try {
      final saved = await db.getPreference('donationKey');
      if (saved is String) key = saved;
    } catch (_) {
      // First install: the preference has not been written yet.
    }
    if (key.isNotEmpty && mounted) {
      setState(() {
        _donationKeyController.text = key;
      });
      ref.read(donationKeyProvider.notifier).state = key;
    }
  }

  Future<void> _loadDefaultStorage() async {
    try {
      final path = await getBookStorageDefaultDirectory;
      if (mounted) {
        setState(() {
          _storagePath = path;
        });
      }
    } catch (e) {
      // ignore
    }
  }

  void _nextPage() {
    if (_currentPage == 1 && _storagePath.isEmpty) {
      // Force storage selection
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context).selectStorageToContinue)),
      );
      return;
    }

    // Page count adjusted for platform
    final platformPages = (Platform.isAndroid || Platform.isIOS) ? 7 : 6;

    if (_currentPage < platformPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final db = MyLibraryDb.instance;
    await db.savePreference('onboardingCompleted', 1);
    await db.savePreference('bookStorageDirectory', _storagePath);
    await db.savePreference('enableAutoUpdate', _enableAutoUpdate ? 1 : 0);
    await db.savePreference(
        'includePrereleaseUpdates', _enableBetaUpdates ? 1 : 0);
    await db.savePreference('donationKey', _donationKeyController.text);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  Future<void> _selectStorage() async {
    String? pickedDirectory = await pickBookStorageDirectory();
    if (pickedDirectory != null) {
      // If we are selecting a new path, we should probably check permissions if android
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
        if (await Permission.manageExternalStorage.status.isDenied) {
          await Permission.manageExternalStorage.request();
        }
      }

      setState(() {
        _storagePath = pickedDirectory;
      });

      // Scan new directory
      if (mounted) {
        final db = MyLibraryDb.instance;
        final imported = await importBooksFromDirectory(_storagePath, db);
        if (imported > 0) {
          // ignore: unused_result
          ref.refresh(myLibraryProvider);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show notification page on mobile
    final showNotificationPage = Platform.isAndroid || Platform.isIOS;
    final displayPages = [
      _buildWelcomePage(),
      _buildStoragePage(),
      _buildUpdatePage(),
      _buildDonationPage(),
      _buildSponsorPage(),
      if (showNotificationPage) _buildNotificationPage(),
      _buildThemePage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: displayPages,
              ),
            ),
            _buildBottomBar(displayPages.length),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(int pageCount) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Dots indicator
          Row(
            children: List.generate(pageCount, (index) {
              final selected = _currentPage == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: selected ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: selected ? scheme.primary : scheme.primaryContainer,
                ),
              );
            }),
          ),
          FilledButton(
            onPressed: _nextPage,
            child: Text(_currentPage == pageCount - 1
                ? AppLocalizations.of(context).getStarted
                : AppLocalizations.of(context).next),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_library_rounded,
              size: 64,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            AppLocalizations.of(context).welcomeTitle,
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).welcomeSubtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStoragePage() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 60,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context).whereToStoreBooks,
              style: theme.textTheme.headlineSmall),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _storagePath.isEmpty
                    ? AppLocalizations.of(context).noPathSelected
                    : _storagePath,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.tonalIcon(
            onPressed: _selectStorage,
            icon: const Icon(Icons.edit_outlined),
            label: Text(AppLocalizations.of(context).selectFolder),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context).storageScanNote,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildUpdatePage() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.system_update_rounded,
            size: 60,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context).automaticUpdates,
              style: theme.textTheme.headlineSmall),
          const SizedBox(height: 24),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(AppLocalizations.of(context).enableAutoUpdates),
                  subtitle:
                      Text(AppLocalizations.of(context).autoUpdatesFdroidNote),
                  value: _enableAutoUpdate,
                  onChanged: (val) async {
                    setState(() {
                      _enableAutoUpdate = val;
                    });
                    if (val && Platform.isAndroid) {
                      // Request install permission if they enable it
                      final status =
                          await Permission.requestInstallPackages.status;
                      if (!status.isGranted) {
                        await Permission.requestInstallPackages.request();
                      }
                    }
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: Text(
                      AppLocalizations.of(context).enableBetaUpdatesOnboarding),
                  subtitle: Text(AppLocalizations.of(context).betaUpdatesNote),
                  value: _enableBetaUpdates,
                  onChanged: (val) async {
                    setState(() {
                      _enableBetaUpdates = val;
                    });
                    final db = MyLibraryDb.instance;
                    await db.savePreference(
                        'includePrereleaseUpdates', val ? 1 : 0);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationPage() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_rounded,
            size: 60,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context).supportAnnasArchive,
              style: theme.textTheme.headlineSmall),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context).donationPitch,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _donationKeyController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).annasSecretKey,
              prefixIcon: const Icon(Icons.key_outlined),
            ),
            onChanged: (value) {
              ref.read(donationKeyProvider.notifier).state = value;
              getIt<AppSettings>().setDonationKey(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSponsorPage() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.code_rounded, size: 60, color: theme.colorScheme.primary),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context).supportThisApp,
              style: theme.textTheme.headlineSmall),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context).sponsorPitch,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: () =>
                launchUrl(Uri.parse('https://github.com/sponsors/lzoreal')),
            icon: const Icon(Icons.open_in_new),
            label: Text(AppLocalizations.of(context).sponsorOnGithub),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationPage() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_rounded,
            size: 60,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context).stayUpdated,
              style: theme.textTheme.headlineSmall),
          const SizedBox(height: 24),
          Card(
            clipBehavior: Clip.antiAlias,
            child: SwitchListTile(
              title: Text(AppLocalizations.of(context).enableNotifications),
              subtitle: Text(AppLocalizations.of(context).notifyOnComplete),
              value: _enableNotifications,
              onChanged: (val) async {
                setState(() {
                  _enableNotifications = val;
                });
                if (val) {
                  await Permission.notification.request();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemePage() {
    final theme = Theme.of(context);
    final mode = ref.watch(themeModeProvider);
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.palette_rounded,
              size: 60, color: theme.colorScheme.primary),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context).chooseTheme,
              style: theme.textTheme.headlineSmall),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ThemeCard(
                  title: AppLocalizations.of(context).lightThemeShort,
                  icon: Icons.light_mode_rounded,
                  selected: mode == ThemeMode.light,
                  onTap: () {
                    ref
                        .read(themeModeProvider.notifier)
                        .setTheme(ThemeMode.light);
                  }),
              const SizedBox(width: 16),
              _ThemeCard(
                  title: AppLocalizations.of(context).darkThemeShort,
                  icon: Icons.dark_mode_rounded,
                  selected: mode == ThemeMode.dark,
                  onTap: () {
                    ref
                        .read(themeModeProvider.notifier)
                        .setTheme(ThemeMode.dark);
                  }),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SizedBox(
      width: 112,
      child: Card(
        color: selected ? scheme.primaryContainer : scheme.surfaceContainerLow,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: selected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color:
                        selected ? scheme.onPrimaryContainer : scheme.onSurface,
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
