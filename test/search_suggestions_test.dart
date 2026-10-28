// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/app/di.dart' show resetDi;
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/ui/features/results/views/results_page.dart';
import 'package:openlib/ui/features/search/view_models/search_view_model.dart';
import 'package:openlib/ui/features/search/views/search_page.dart';

import 'helpers/search_test_support.dart';
import 'helpers/test_di.dart';

void main() {
  late TestRecentStore recentStore;
  late SearchViewModel viewModel;

  setUp(() async {
    recentStore = TestRecentStore(['Dune', 'Emma']);
    await setupTestDi();
  });

  tearDown(() async {
    await resetDi();
  });

  Future<void> pumpSearch(WidgetTester tester) async {
    // Build the view model inside the test body: futures created in setUp
    // run in the outer zone, so `prepareSearch` would never resume here.
    viewModel = testSearchViewModel(
      recentStore: recentStore,
      suggestionsApi: TestSuggestions(['三体 全集', '三体 动画']),
    );
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SearchPage(viewModel: viewModel)),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('the suggestions tab shows recents and the advanced entry',
      (tester) async {
    await pumpSearch(tester);

    expect(find.text('最近搜索'), findsOneWidget);
    expect(find.text('Dune'), findsOneWidget);
    expect(find.text('Emma'), findsOneWidget);
    expect(find.text('高级搜索'), findsOneWidget);

    final l10n =
        AppLocalizations.of(tester.element(find.byType(SearchPage).first));
    expect(find.byTooltip(l10n.removeRecentSearch('Dune')), findsOneWidget);

    await tester.tap(find.byTooltip(l10n.removeRecentSearch('Dune')));
    await tester.pump();
    expect(find.text('Dune'), findsNothing);
    expect(find.text('Emma'), findsOneWidget);
  });

  testWidgets('typing shows inline suggestions and tapping one searches',
      (tester) async {
    await pumpSearch(tester);

    await tester.tap(find.byType(SearchBar));
    await tester.pump();
    await tester.enterText(find.byType(SearchBar), '三体');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('三体 全集'), findsOneWidget);
    expect(find.text('三体 动画'), findsOneWidget);

    await tester.tap(find.text('三体 全集'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(ResultPage), findsOneWidget);
    expect(find.text('三体 全集'), findsWidgets);
    expect(recentStore.stored.first, '三体 全集');
  });

  testWidgets('the advanced tab exposes filters and applies the query',
      (tester) async {
    await pumpSearch(tester);

    await tester.tap(find.text('高级搜索'));
    await tester.pumpAndSettle();

    expect(find.text('作者'), findsOneWidget);
    expect(find.text('出版社'), findsOneWidget);
    expect(find.text('文件类型'), findsOneWidget);
    expect(find.text('排序方式'), findsOneWidget);
    expect(find.text('应用并搜索'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('advanced-search-card')),
        matching: find.text('搜索来源'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byType(SearchBar));
    await tester.enterText(find.byType(SearchBar), '三体');
    await tester.ensureVisible(find.text('应用并搜索'));
    await tester.pump();
    await tester.tap(find.text('应用并搜索'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(ResultPage), findsOneWidget);
    expect(recentStore.stored.first, '三体');
  });
}
