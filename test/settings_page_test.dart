// Builds the real SettingsPage with a real (ffi-backed) database and an
// injected SettingsViewModel. Regression coverage on the page structure:
// every section header and tile renders, the source cards follow the saved
// chain, and the theme/language rows commit through to AppSettings.
// The DB persistence of theme is covered by the widget test below, because
// real sqlite I/O freezes inside the widget-test fake async zone.

// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Project imports:
import 'package:openlib/app/app_settings.dart';
import 'package:openlib/app/di.dart';
import 'package:openlib/data/models/search_filters.dart';
import 'package:openlib/data/models/search_result.dart';
import 'package:openlib/data/repositories/library_repository.dart';
import 'package:openlib/data/repositories/preferences_repository.dart';
import 'package:openlib/data/repositories/search_repository.dart';
import 'package:openlib/data/services/database.dart';
import 'package:openlib/data/services/search_manager.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/ui/features/settings/view_models/settings_view_model.dart';
import 'package:openlib/ui/features/settings/views/settings_page.dart';

import 'helpers/fake_path_provider.dart';

final _paths = FakePathProvider('settings');

/// In-memory source toggles/order; the real repository queues a network
/// manager and reads preferences from sqlite, neither of which the widget
/// test fake async zone can settle.
class _FakeSearchRepository extends SearchRepository {
  _FakeSearchRepository() : super(manager: SearchManager(providers: const []));

  Set<SearchProviderId> enabled = SearchProviderId.values.toSet();
  List<SearchProviderId> order = defaultSearchSourceOrder;

  @override
  Future<Set<SearchProviderId>> enabledProviders() async => enabled;

  @override
  Future<List<SearchProviderId>> sourceOrder() async => order;

  @override
  Future<void> setProviderEnabled(SearchProviderId id, bool value) async {
    enabled = value ? {...enabled, id} : ({...enabled}..remove(id));
  }

  @override
  Future<void> setSourceOrder(List<SearchProviderId> next) async {
    order = List<SearchProviderId>.of(next);
  }
}

class _FakeLibraryRepository extends LibraryRepository {
  int notifications = 0;

  @override
  void notifyChanged() {
    notifications++;
    super.notifyChanged();
  }
}

void main() {
  late AppSettings settings;
  late _FakeSearchRepository searchRepository;
  late _FakeLibraryRepository libraryRepository;
  late SettingsViewModel viewModel;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    PathProviderPlatform.instance = _paths;
    Directory(_paths.base).createSync(recursive: true);
    // The About tab asks for the package version; without the handler the
    // future fails as soon as a real async window opens.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/package_info'),
      (call) async => call.method == 'getAll'
          ? <String, dynamic>{
              'appName': 'OpenlibExtended',
              'packageName': 'org.openlib',
              'version': '1.7.2',
              'buildNumber': '1',
            }
          : null,
    );
  });

  setUp(() async {
    settings = AppSettings(
      themeMode: ThemeMode.system,
      fontSizeScale: 1,
      locale: null,
      showManualDownloadButton: true,
      backgroundVerification: true,
      donationKey: '',
      userAgent: '',
      cookie: '',
      filters: const SearchFilters(),
    );
    searchRepository = _FakeSearchRepository();
    libraryRepository = _FakeLibraryRepository();
    viewModel = SettingsViewModel(
      settings: settings,
      search: searchRepository,
      library: libraryRepository,
    );
    // The locale row refreshes the download notifications through the DI
    // container even though the page itself is driven by the injected
    // view model.
    await initDi(
      settings: settings,
      database: MyLibraryDb.instance,
      preferences: PreferencesRepository(database: MyLibraryDb.instance),
    );
  });

  tearDown(() async {
    viewModel.dispose();
    await resetDi();
  });

  Future<void> pumpPage(WidgetTester tester, {Locale? locale}) async {
    // Tall enough for the appearance tab's option cards to lay out in one
    // pass; the scrollable mobile variant is exercised on-device.
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    // The storage-location row reads preferences from sqlite, whose futures
    // never complete in the widget-test fake async zone, so the first frame
    // and the real async window it needs live inside runAsync.
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: Scaffold(body: SettingsPage(viewModel: viewModel)),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    // Bounded pumping: the page starts async work (instance providers,
    // PackageInfo) that can keep animations running, so pumpAndSettle is
    // not reliable here.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 2));
  }

  Future<void> openTab(WidgetTester tester, int index) async {
    // Tapping a pill inside a scrollable TabBar is flaky in the test
    // viewport, so jump the pager and keep the tab controller in sync.
    tester.widget<TabBar>(find.byType(TabBar)).controller!.index = index;
    final pageView = tester.widget<PageView>(find.descendant(
      of: find.byType(TabBarView),
      matching: find.byType(PageView),
    ));
    pageView.controller!.jumpToPage(index);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('renders every tab and its settings', (tester) async {
    await pumpPage(tester);

    expect(find.text('Search Providers'), findsOneWidget);
    expect(find.text('WeLib'), findsOneWidget,
        reason:
            'the search-source cards must render, not the blank loading box');
    expect(find.text('SOURCE BEHAVIOR'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('SOURCE BEHAVIOR'),
        matching: find.byType(Card),
      ),
      findsOneWidget,
    );
    expect(find.text('Mirrors & Providers'), findsOneWidget);
    expect(find.text("Anna's Archive Donation Key"), findsOneWidget);

    await openTab(tester, 1);
    await tester.pump(const Duration(milliseconds: 100));
    for (final label in [
      'Language',
      'THEME',
      'Font Size',
    ]) {
      expect(find.text(label), findsOneWidget, reason: 'Appearance: $label');
    }
    expect(
      find.ancestor(of: find.text('THEME'), matching: find.byType(Card)),
      findsOneWidget,
    );

    await openTab(tester, 2);
    for (final label in [
      'Storage Location',
      'Manual Download Button',
      'Include Beta Updates',
      'Check for Updates',
      'Export Backup',
      'Import Backup',
      'Export Logs',
      'Redo Onboarding',
    ]) {
      expect(find.text(label), findsOneWidget, reason: 'Advanced: $label');
    }

    await openTab(tester, 3);
    for (final label in [
      'Changelog',
      'Open-source licenses',
      'Project home',
      'About OpenlibExtended',
      'SLUM mirror catalog',
    ]) {
      expect(find.text(label), findsOneWidget, reason: 'About: $label');
    }
    expect(
      tester.widgetList<Image>(find.byType(Image)).where((image) {
        final provider = image.image;
        return provider is AssetImage &&
            provider.assetName == 'assets/icons/appIcon.png';
      }),
      isNotEmpty,
      reason: 'the About tab must show the app icon',
    );
    expect(find.text('Reader'), findsNothing);
  });

  testWidgets('Chinese locale renders the settings and backup labels',
      (tester) async {
    await pumpPage(tester, locale: const Locale('zh'));

    expect(find.text('搜索来源'), findsOneWidget);
    expect(find.text('来源行为'), findsOneWidget);
    expect(find.text('镜像与来源'), findsOneWidget);

    await openTab(tester, 1);
    for (final label in ['语言', '主题', '字体大小']) {
      expect(find.text(label), findsOneWidget, reason: '外观: $label');
    }

    await openTab(tester, 2);
    for (final label in [
      '存储位置',
      '手动下载按钮',
      '导出备份',
      '导入备份',
      '导出日志',
      '重新运行引导',
    ]) {
      expect(find.text(label), findsOneWidget, reason: '高级: $label');
    }

    await openTab(tester, 3);
    for (final label in ['更新日志', '开源许可', '项目主页', '关于 OpenlibExtended']) {
      expect(find.text(label), findsOneWidget, reason: '关于: $label');
    }
    expect(find.text('Export Backup'), findsNothing);
    expect(find.text('Import Backup'), findsNothing);
  });

  testWidgets('provider cards follow the saved chain order', (tester) async {
    const saved = [
      SearchProviderId.welib,
      SearchProviderId.annasArchive,
      SearchProviderId.libgen,
      SearchProviderId.zlibrary,
    ];
    searchRepository.order = saved;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: SettingsPage(viewModel: viewModel)),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 100));

    final cards = tester
        .widgetList<Text>(find.descendant(
          of: find.byType(SettingsPage),
          matching: find.byType(Text),
        ))
        .map((text) => text.data)
        .whereType<String>()
        .toList();

    expect(
      cards,
      containsAllInOrder([
        'WL',
        'WeLib',
        'AA',
        "Anna's Archive",
        'LG',
        'LibGen',
        'ZL',
        'Z-Library',
      ]),
      reason: 'the source cards must render in the stored chain order',
    );
    expect(
      find.byWidgetPredicate((widget) => widget is Draggable<SearchProviderId>),
      findsNWidgets(4),
      reason: 'every source card must be draggable onto another slot',
    );
  });

  testWidgets('theme tiles update AppSettings', (tester) async {
    await pumpPage(tester);

    await openTab(tester, 1);

    await tester.ensureVisible(find.text('Light'));
    await tester.pump();
    await tester.tap(find.text('Light'));
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.text('Dark'));
    await tester.pump(const Duration(milliseconds: 600));
    // The tile persists through sqlite; let the write finish in a real
    // async window so its lock-warning timer does not outlive the test.
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump();

    expect(settings.themeMode, ThemeMode.dark,
        reason: 'selecting Dark must update AppSettings');
    final saved = await tester
        .runAsync(() => MyLibraryDb.instance.getPreference('themeMode'));
    expect(saved, 'dark',
        reason: 'the selected mode must still reach the preferences table');
  });

  testWidgets('language tiles update the locale on AppSettings',
      (tester) async {
    await pumpPage(tester);

    await openTab(tester, 1);

    // The language card starts collapsed; tapping the row reveals options.
    await tester.tap(find.byKey(const ValueKey('language-selector-toggle')));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Deutsch'));
    await tester.pump(const Duration(milliseconds: 300));
    // The tile persists the code through sqlite; let the write finish in a
    // real async window so its lock-warning timer does not outlive the test.
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump();

    expect(settings.locale?.languageCode, 'de',
        reason: 'selecting a language tile must switch the locale override');

    await tester.tap(find.byKey(const ValueKey('language-selector-toggle')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('System default'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump();
    expect(settings.locale, isNull,
        reason: 'the system tile clears the override');
  });

  test('the view model forwards theme changes into AppSettings', () {
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    viewModel.setThemeMode(ThemeMode.dark);

    expect(settings.themeMode, ThemeMode.dark,
        reason: 'setThemeMode must write the shared AppSettings');
    expect(notifications, 1,
        reason: 'the page rebuilds through the AppSettings forward');
  });

  test('refreshLibrary notifies library listeners', () {
    viewModel.refreshLibrary();

    expect(libraryRepository.notifications, 1,
        reason: 'the download center must hear about direct database writes');
  });
}
