import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/ui/features/shell/views/home_page.dart';
import 'package:openlib/ui/features/search/views/search_page.dart';
import 'package:openlib/ui/core/themes.dart';

import 'package:openlib/app/di.dart' show resetDi;

import 'helpers/search_test_support.dart';
import 'helpers/test_di.dart';

void main() {
  setUp(() async {
    await setupTestDi();
  });

  tearDown(() async {
    await resetDi();
  });

  testWidgets('search field is 52 high and tabs use the pill track',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final viewModel = testSearchViewModel();

    await tester.pumpWidget(MaterialApp(
      theme: lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SearchPage(viewModel: viewModel)),
    ));
    await tester.pump();

    expect(tester.getSize(find.byType(SearchBar)).height, 52);
    expect(
      tester.getSize(find.byKey(const ValueKey('pill-tabs-track'))).height,
      44,
    );
    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.labelStyle?.fontWeight, FontWeight.w800);

    await tester.fling(
      find.byType(TabBarView),
      const Offset(-320, 0),
      1200,
    );
    await tester.pumpAndSettle();

    expect(find.text('Author'), findsOneWidget);
  });

  testWidgets('search tabs fit 200% text and still swipe', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final viewModel = testSearchViewModel();

    await tester.pumpWidget(MaterialApp(
        theme: lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: Scaffold(body: SearchPage(viewModel: viewModel)),
        ),
      ),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.fling(
      find.byType(TabBarView),
      const Offset(-320, 0),
      1200,
    );
    await tester.pumpAndSettle();

    expect(find.text('Author'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('discovery and search fields start at the same offset',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final viewModel = testSearchViewModel();

    Future<void> pumpPage(Widget page) async {
      await tester.pumpWidget(MaterialApp(
        theme: lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: page),
      ));
      await tester.pump();
    }

    await pumpPage(const HomePage());
    final homeField = find.byKey(const ValueKey('home-search-field'));
    final homeTop = tester.getTopLeft(homeField).dy;

    await pumpPage(SearchPage(viewModel: viewModel));
    final searchTop = tester.getTopLeft(find.byType(SearchBar)).dy;

    expect(homeTop, searchTop);
  });
}
