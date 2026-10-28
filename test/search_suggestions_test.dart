// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/data/models/search_result.dart';
import 'package:openlib/data/repositories/mirror_repository.dart';
import 'package:openlib/data/services/google_suggest_api.dart';
import 'package:openlib/data/services/instance_manager.dart';
import 'package:openlib/data/services/preference_store.dart';
import 'package:openlib/data/services/recent_searches.dart';
import 'package:openlib/state/repository_providers.dart'
    show mirrorRepositoryProvider;
import 'package:openlib/state/state.dart';
import 'package:openlib/ui/results_page.dart';
import 'package:openlib/ui/search_page.dart';

class _FakeSuggestions extends GoogleSuggestApi {
  _FakeSuggestions(this.values);

  final List<String> values;

  @override
  Future<List<String>> fetchSuggestions(String query) async => values;
}

class _MemoryRecentStore implements RecentSearchStore {
  _MemoryRecentStore([List<String> initial = const []])
      : stored = List<String>.of(initial);

  List<String> stored;

  @override
  Future<List<String>> load() async => List<String>.of(stored);

  @override
  Future<void> save(List<String> searches) async {
    stored = List<String>.of(searches);
  }
}

void main() {
  late _MemoryRecentStore recentStore;

  setUp(() {
    recentStore = _MemoryRecentStore(['Dune', 'Emma']);
  });

  Future<void> pumpSearch(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // The page resolves its mirrors through DI; tests do not run initDi.
          mirrorRepositoryProvider.overrideWithValue(MirrorRepository(
            manager: InstanceManager.forTest(store: MemoryPreferenceStore()),
          )),
          recentSearchesProvider.overrideWith(
            (ref) => RecentSearchesNotifier(store: recentStore),
          ),
          googleSuggestApiProvider.overrideWithValue(
            _FakeSuggestions(['三体 全集', '三体 动画']),
          ),
          searchProviderToggles.overrideWith((ref) async => {
                SearchProviderId.libgen,
                SearchProviderId.zlibrary,
                SearchProviderId.welib,
                SearchProviderId.annasArchive,
              }),
          searchProvider.overrideWith(
            (ref, key) async => const SearchManagerResult(
              books: [],
              failedProviders: [],
            ),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: SearchPage()),
        ),
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
