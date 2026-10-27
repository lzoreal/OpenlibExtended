// Builds the real SettingsPage with a real (ffi-backed) database and provider
// scope. Regression coverage on the page structure: every section header and
// tile renders, and the theme dropdown commits through to the provider.
// The DB persistence of setTheme itself is covered by a plain (real-zone)
// test below, because real sqlite I/O freezes inside the widget-test fake
// async zone.

// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Project imports:
import 'package:openlib/services/database.dart';
import 'package:openlib/services/search_manager.dart';
import 'package:openlib/state/state.dart';
import 'package:openlib/ui/settings_page.dart';
import 'package:openlib/l10n/app_localizations.dart';

class _FakePathProvider extends PathProviderPlatform {
  static const base = '/tmp/openlib_settings_test';

  @override
  Future<String?> getApplicationSupportPath() async => base;

  @override
  Future<String?> getApplicationDocumentsPath() async => base;

  @override
  Future<String?> getTemporaryPath() async => base;

  @override
  Future<String?> getLibraryPath() async => base;
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    PathProviderPlatform.instance = _FakePathProvider();
    Directory(_FakePathProvider.base).createSync(recursive: true);
  });

  Future<void> pumpPage(WidgetTester tester, {Locale? locale}) async {
    // Tall enough for the appearance tab's option cards to lay out in one
    // pass; the scrollable mobile variant is exercised on-device.
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: const Scaffold(body: SettingsPage()),
        ),
      ),
    );
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchSourceOrderProvider.overrideWith((ref) => saved),
          searchProviderToggles
              .overrideWith((ref) => SearchProviderId.values.toSet()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const Scaffold(body: SettingsPage()),
        ),
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

  testWidgets('theme tiles update the provider state', (tester) async {
    await pumpPage(tester);

    await openTab(tester, 1);

    await tester.ensureVisible(find.text('Light'));
    await tester.pump();
    await tester.tap(find.text('Light'));
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.text('Dark'));
    await tester.pump(const Duration(milliseconds: 600));

    final element = tester.element(find.byType(SettingsPage));
    final container = ProviderScope.containerOf(element);
    expect(container.read(themeModeProvider), ThemeMode.dark,
        reason: 'selecting Dark must update the provider state');
  });

  testWidgets('language tiles update the locale provider', (tester) async {
    await pumpPage(tester);

    await openTab(tester, 1);

    // The language card starts collapsed; tapping the row reveals options.
    await tester.tap(find.byKey(const ValueKey('language-selector-toggle')));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Deutsch'));
    await tester.pump(const Duration(milliseconds: 300));

    final element = tester.element(find.byType(SettingsPage));
    final container = ProviderScope.containerOf(element);
    expect(container.read(localeOverrideProvider)?.languageCode, 'de',
        reason: 'selecting a language tile must switch the locale override');

    await tester.tap(find.byKey(const ValueKey('language-selector-toggle')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('System default'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(container.read(localeOverrideProvider), isNull,
        reason: 'the system tile clears the override');
  });

  test('setTheme persists the selected mode', () async {
    final notifier = ThemeModeNotifier(ThemeMode.light);
    await notifier.setTheme(ThemeMode.dark);

    final saved = await MyLibraryDb.instance.getPreference('themeMode');
    expect(saved, 'dark',
        reason: 'setTheme must persist the mode to the preferences table');
  });
}
