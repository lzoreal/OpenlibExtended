// Dart imports:
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/foundation.dart' show kDebugMode, visibleForTesting;
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:openlib/ui/features/shell/views/home_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart';

// Project imports:
import 'package:openlib/app/app_settings.dart';
import 'package:openlib/app/di.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/data/services/database.dart' show MyLibraryDb;
import 'package:openlib/data/services/platform_utils.dart';
import 'package:openlib/data/repositories/download_repository.dart';
import 'package:openlib/data/repositories/preferences_repository.dart';
import 'package:openlib/data/services/challenge_html_cache.dart';
import 'package:openlib/data/services/webview_challenge_solver.dart';
import 'package:openlib/data/services/update_checker.dart';
import 'package:openlib/data/services/upgrade_detector.dart';
import 'package:openlib/ui/features/shell/widgets/bottom_nav_bar.dart';
import 'package:openlib/ui/features/shell/widgets/content_width.dart';
import 'package:openlib/ui/features/shell/widgets/swiss_grid_overlay.dart';
import 'package:openlib/ui/core/components/tab_keep_alive.dart';
import 'package:openlib/ui/features/library/views/download_center_page.dart';
import 'package:openlib/ui/core/motion.dart';
import 'package:openlib/ui/features/search/views/search_page.dart';
import 'package:openlib/ui/features/settings/views/settings_page.dart';
import 'package:openlib/ui/core/themes.dart';
import 'package:openlib/ui/features/onboarding/views/onboarding_page.dart';
import 'package:openlib/ui/features/webview/views/challenge_solver_page.dart';
import 'package:openlib/ui/features/whats_new/views/whats_new_page.dart';

import 'package:openlib/data/services/files.dart'
    show moveFilesToAndroidInternalStorage;
import 'package:openlib/data/services/download_manager.dart';
import 'package:openlib/data/services/download_notification.dart';
import 'package:openlib/data/services/instance_manager.dart';
import 'package:openlib/state/state.dart'
    show
        ThemeModeNotifier,
        selectedIndexProvider,
        activeDownloadsProvider,
        themeModeProvider,
        fontSizeScaleProvider,
        localeOverrideProvider,
        showManualDownloadButtonProvider,
        backgroundVerificationProvider,
        userAgentProvider,
        cookieProvider,
        donationKeyProvider,
        selectedTypeState,
        selectedSortState,
        selectedFileTypeState,
        selectedLanguageState,
        selectedYearState;

void main(List<String> args) async {
  // Required for desktop_webview_window on Linux - must be called before ensureInitialized
  if (Platform.isLinux || Platform.isWindows) {
    if (runWebViewTitleBarWidget(args)) {
      return;
    }
  }
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  MyLibraryDb dataBase = MyLibraryDb.instance;

  await DownloadManager().initialize();

  ThemeMode startThemeMode = await ThemeModeNotifier.getInitialTheme();

  final preferences = PreferencesRepository(database: dataBase);
  final settings = await AppSettings.load(
    initialThemeMode: startThemeMode,
    preferences: preferences,
  );
  await initDi(
    settings: settings,
    database: dataBase,
    preferences: preferences,
  );

  // Stored as 0 = off; anything else (or missing) = headless on.
  WebviewChallengeSolver.headlessEnabled = settings.backgroundVerification;

  // Download notifications are posted by a service without a BuildContext;
  // give it the same locale the UI will resolve to.
  getIt<DownloadRepository>().setLocale(
      settings.locale ?? WidgetsBinding.instance.platformDispatcher.locale);

  // Check onboarding status
  bool onboardingCompleted = await dataBase
          .getPreference('onboardingCompleted')
          .catchError((e) => 0) ==
      1;

  // Upgrade check: shows the what's-new screen once after a real
  // version bump (never on first install - onboarding covers that).
  // A failed check must not block startup.
  UpgradeCheck? upgrade;
  try {
    upgrade = await UpgradeDetector().checkAndRecord();
  } catch (_) {
    upgrade = null;
  }

  if (Platform.isAndroid) {
    // Android-specific setup for system UI overlay colors
    ThemeModeNotifier.updateSystemUi(startThemeMode);
    await moveFilesToAndroidInternalStorage();
  }

  // When the invisible (headless) DDoS solve fails on mobile, show the
  // solver as a visible page instead - the user watches the check clear
  // and the app closes the page as soon as the HTML is captured.
  WebviewChallengeSolver.visibleSolverFallback = (url) async {
    final context = _navigatorKey.currentContext;
    if (context == null) return null;
    final solved = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChallengeSolverPage(url: url)),
    );
    return solved == true ? ChallengeHtmlCache.get(url) : null;
  };

  runApp(
    ProviderScope(
      overrides: [
        themeModeProvider
            .overrideWith((ref) => ThemeModeNotifier(startThemeMode)),
        fontSizeScaleProvider.overrideWith((ref) => settings.fontSizeScale),
        localeOverrideProvider.overrideWith((ref) => settings.locale),
        showManualDownloadButtonProvider
            .overrideWith((ref) => settings.showManualDownloadButton),
        backgroundVerificationProvider
            .overrideWith((ref) => settings.backgroundVerification),
        donationKeyProvider.overrideWith((ref) => settings.donationKey),
        userAgentProvider.overrideWith((ref) => settings.userAgent),
        cookieProvider.overrideWith((ref) => settings.cookie),
        selectedTypeState.overrideWith((ref) => settings.filters.type),
        selectedSortState.overrideWith((ref) => settings.filters.sort),
        selectedFileTypeState.overrideWith((ref) => settings.filters.fileType),
        selectedLanguageState.overrideWith((ref) => settings.filters.language),
        selectedYearState.overrideWith((ref) => settings.filters.year),
      ],
      child: MyApp(
        onboardingCompleted: onboardingCompleted,
        upgrade: upgrade,
      ),
    ),
  );
}

/// Scrolling tuned for the snappy complaint on newer Androids: touch
/// input gets momentum-based physics with a clamped stop at the edges
/// (no iOS-style bounce-back), so lists decelerate naturally instead of
/// halting on a dime when the finger lifts.
class _SmoothScrollBehavior extends MaterialScrollBehavior {
  const _SmoothScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      decelerationRate: ScrollDecelerationRate.fast,
      parent: AlwaysScrollableScrollPhysics(),
    );
  }
}

/// Global navigator so the challenge-solver fallback (a service, not a
/// widget) can push the visible solver page from anywhere.
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends ConsumerWidget {
  final bool onboardingCompleted;

  /// Non-null with [UpgradeCheck.isUpgrade] when this launch follows a
  /// version bump; drives the what's-new screen.
  final UpgradeCheck? upgrade;
  const MyApp({super.key, this.onboardingCompleted = false, this.upgrade});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      scrollBehavior: const _SmoothScrollBehavior(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: ref.watch(localeOverrideProvider),
      builder: (context, child) {
        final scale = ref.watch(fontSizeScaleProvider);
        final content = MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        );
        if (!kDebugMode || !const bool.fromEnvironment('SWISS_GRID')) {
          return content;
        }
        return Stack(
          children: [
            content,
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: SwissGridOverlay(
                    dark: Theme.of(context).brightness == Brightness.dark,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      debugShowCheckedModeBanner: false,
      title: 'OpenlibExtended',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ref.watch(themeModeProvider),
      home: !onboardingCompleted
          ? const OnboardingPage()
          : (upgrade?.isUpgrade ?? false)
              ? WhatsNewPage(
                  fromVersion: upgrade!.fromVersion,
                  toVersion: upgrade!.toVersion,
                )
              : const MainScreen(),
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainScreenState();
}

/// Moves the root PageView to [next] with the same slide the settings
/// tabs use, including taps that skip pages. The pages stay alive and each
/// is its own repaint layer, so crossing them is paint-only after the
/// first visit.
@visibleForTesting
void switchToTab(PageController controller, int next) {
  if (!controller.hasClients) return;
  final current = controller.page?.round() ?? next;
  if (current == next) return;
  controller.animateToPage(
    next,
    duration: kPageSwitchDuration,
    curve: kPageSwitchCurve,
  );
}

class _MainScreenState extends ConsumerState<MainScreen>
    with WidgetsBindingObserver {
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    SearchPage(),
    DownloadCenterPage(),
    SettingsPage(),
  ];

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: ref.read(selectedIndexProvider));
    ref.listenManual<int>(selectedIndexProvider, (previous, next) {
      switchToTab(_pageController, next);
    });
    WidgetsBinding.instance.addObserver(this);
    // Request notification permission after first frame (only on mobile)
    if (PlatformUtils.isMobile) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAndRequestNotificationPermission();
      });
    }
    // Check for updates after the app has loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdatesOnStartup();
    });
    // Pull the mirror list from open-slum.org so the first search does
    // not wait on it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshMirrorsOnStartup();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Android suspends the process soon after the user leaves the app,
    // which cuts sockets mid-download ("Connection closed while
    // receiving data"). Coming back to the foreground, every paused or
    // failed download continues from its partial file instead of dying.
    if (state == AppLifecycleState.resumed) {
      DownloadManager().resumeInterruptedDownloads();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _refreshMirrorsOnStartup() async {
    // Small delay to let the UI settle first.
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    await InstanceManager().refreshOnStartup();
  }

  Future<void> _checkForUpdatesOnStartup() async {
    // Small delay to let the UI settle
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    try {
      await UpdateCheckerService().checkAndShowUpdateDialog(context);
    } catch (e) {
      // Silently fail on startup - user can manually check in settings
      debugPrint("Update check failed: $e");
    }
  }

  Future<void> _checkAndRequestNotificationPermission() async {
    // Skip on desktop platforms
    if (PlatformUtils.isDesktop) return;

    // Check if we should show the permission dialog
    final prefs = MyLibraryDb.instance;
    final hasAskedBefore = await prefs
        .getPreference('hasAskedNotificationPermission')
        .catchError((_) => 0);

    if (hasAskedBefore == 0) {
      // Check current permission status
      final notificationService = DownloadNotificationService();
      final currentStatus =
          await notificationService.checkNotificationPermission();

      if (!currentStatus && mounted) {
        // Show the contextual dialog first
        _showNotificationPermissionDialog();
      } else {
        // Already granted, just mark as asked
        await prefs.savePreference('hasAskedNotificationPermission', 1);
      }
    }
  }

  void _showNotificationPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context).enableNotifications,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          content: Text(
            AppLocalizations.of(context).notificationsExplanation,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .tertiary
                      .withValues(alpha: 0.78),
                ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Don't mark as asked so we can ask again later
              },
              child: Text(
                AppLocalizations.of(context).maybeLater,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .tertiary
                      .withValues(alpha: 0.67),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Request permission when user clicks Enable
                await DownloadNotificationService()
                    .requestNotificationPermission();
                // Mark that we've asked
                await MyLibraryDb.instance
                    .savePreference('hasAskedNotificationPermission', 1);
              },
              child: Text(
                AppLocalizations.of(context).enable,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _selectTab(int index) {
    ref.read(selectedIndexProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    // Only the badge count matters here; watching the whole task map made
    // the scaffold and dock rebuild for every network chunk.
    final downloadCount = ref.watch(activeDownloadsProvider.select(
      (downloads) =>
          (downloads.valueOrNull ?? const <String, DownloadTask>{})
              .values
              .where((task) =>
                  task.status != DownloadStatus.completed &&
                  task.status != DownloadStatus.cancelled)
              .length,
    ));

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ContentWidth(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              if (ref.read(selectedIndexProvider) != index) {
                ref.read(selectedIndexProvider.notifier).state = index;
              }
            },
            children: [
              for (var index = 0; index < _widgetOptions.length; index++)
                TabKeepAlive(
                  active: index == selectedIndex,
                  child: _widgetOptions[index],
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: selectedIndex,
        onSelected: _selectTab,
        downloadCount: downloadCount,
      ),
    );
  }
}
