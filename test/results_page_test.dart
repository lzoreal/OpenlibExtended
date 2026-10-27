// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/services/annas_archieve.dart';
import 'package:openlib/services/search_manager.dart';
import 'package:openlib/state/state.dart';
import 'package:openlib/ui/components/search_result_card.dart';
import 'package:openlib/ui/components/source_journey_card.dart';
import 'package:openlib/ui/results_page.dart';

List<BookData> _sourceBooks(String tag, String displayName, int page, int count) {
  return List.generate(
    count,
    (i) => BookData(
      title: '$tag $page-$i',
      author: 'Author $tag',
      link: 'https://example.com/md5/$tag-$page-$i',
      md5: 'md5-$tag-$page-$i',
      source: displayName,
    ),
  );
}

/// One parallel page: every source answers with its own list.
SearchManagerResult multiSourcePage(int page) {
  final libgen = _sourceBooks('LibGen', 'Library Genesis', page, 2);
  final zlibrary = _sourceBooks('Z-Library', 'Z-Library', page, 20);
  final welib = _sourceBooks('WeLib', 'WeLib', page, 3);
  final anna = _sourceBooks('Anna', "Anna's Archive", page, 1);
  final all = [...libgen, ...zlibrary, ...welib, ...anna];
  return SearchManagerResult(
    books: all,
    failedProviders: const [],
    resultSource: 'Library Genesis',
    resultSourceId: SearchProviderId.libgen,
    sources: [
      SearchSourceRun(
        id: SearchProviderId.libgen,
        displayName: 'Library Genesis',
        resultCount: libgen.length,
        status: SearchSourceStatus.hit,
      ),
      SearchSourceRun(
        id: SearchProviderId.zlibrary,
        displayName: 'Z-Library',
        resultCount: zlibrary.length,
        status: SearchSourceStatus.hit,
      ),
      SearchSourceRun(
        id: SearchProviderId.welib,
        displayName: 'WeLib',
        resultCount: welib.length,
        status: SearchSourceStatus.hit,
      ),
      SearchSourceRun(
        id: SearchProviderId.annasArchive,
        displayName: "Anna's Archive",
        resultCount: anna.length,
        status: SearchSourceStatus.hit,
      ),
    ],
    booksBySource: {
      SearchProviderId.libgen: libgen,
      SearchProviderId.zlibrary: zlibrary,
      SearchProviderId.welib: welib,
      SearchProviderId.annasArchive: anna,
    },
  );
}

void main() {
  Future<List<SearchPageKey>> pumpResults(
    WidgetTester tester, {
    required Future<SearchManagerResult> Function(SearchPageKey key) search,
    String query = 'docker',
    SearchProviderId? source,
  }) async {
    final keys = <SearchPageKey>[];
    await tester.pumpWidget(ProviderScope(
      overrides: [
        initialSearchProvider.overrideWith((ref, key) {
          keys.add(key);
          return Stream.fromFuture(search(key));
        }),
        searchProvider.overrideWith((ref, key) {
          keys.add(key);
          return search(key);
        }),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ResultPage(searchQuery: query, source: source),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    return keys;
  }

  Finder sourceTile(String label) => find.descendant(
        of: find.byType(SourceJourneyCard),
        matching: find.text(label),
      );

  testWidgets('renders the merged list and the source switcher',
      (tester) async {
    await pumpResults(tester, search: (key) async => multiSourcePage(key.page));

    expect(find.byType(SearchResultCard), findsWidgets);
    expect(find.byType(SourceJourneyCard), findsOneWidget);
    final l10n = AppLocalizations.of(
        tester.element(find.byType(ResultPage).first));
    expect(sourceTile(l10n.searchSourceAuto), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SourceJourneyCard),
        matching: find.text('26'),
      ),
      findsOneWidget,
    );
    expect(sourceTile(l10n.sourceWelib), findsOneWidget);
    expect(find.text('LibGen 1-0'), findsWidgets);
  });

  testWidgets('tapping a source switches the visible result list',
      (tester) async {
    await pumpResults(tester, search: (key) async => multiSourcePage(key.page));

    final l10n = AppLocalizations.of(
        tester.element(find.byType(ResultPage).first));
    await tester.tap(sourceTile(l10n.sourceWelib));
    await tester.pump();

    expect(find.text('WeLib 1-0'), findsWidgets);
    expect(find.text('LibGen 1-0'), findsNothing);

    await tester.tap(sourceTile(l10n.searchSourceAuto));
    await tester.pump();
    expect(find.text('LibGen 1-0'), findsWidgets);
  });

  testWidgets('the merged view paginates without pinning a source',
      (tester) async {
    final keys = await pumpResults(
      tester,
      search: (key) async => key.page >= 3
          ? const SearchManagerResult(books: [], failedProviders: [])
          : multiSourcePage(key.page),
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -4000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    final pageTwo = keys.where((key) => key.page == 2).toList();
    expect(pageTwo, isNotEmpty);
    expect(pageTwo.first.source, isNull);
    expect(find.text('Z-Library 2-0'), findsWidgets);
  });

  testWidgets('a switched source paginates within that source', (tester) async {
    final keys = await pumpResults(
      tester,
      search: (key) async => key.page >= 3
          ? const SearchManagerResult(books: [], failedProviders: [])
          : multiSourcePage(key.page),
    );

    final l10n = AppLocalizations.of(
        tester.element(find.byType(ResultPage).first));
    await tester.tap(sourceTile(l10n.sourceZlibShort));
    await tester.pump();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -4000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    final pageTwo = keys.where((key) => key.page == 2).toList();
    expect(pageTwo, isNotEmpty);
    expect(pageTwo.first.source, SearchProviderId.zlibrary);
  });

  testWidgets('an empty result shows the switcher and clear-filter retry',
      (tester) async {
    var calls = 0;
    await pumpResults(
      tester,
      search: (key) async {
        calls++;
        return const SearchManagerResult(
          books: [],
          failedProviders: [],
          sources: [
            SearchSourceRun(
              id: SearchProviderId.libgen,
              displayName: 'Library Genesis',
              resultCount: 0,
              status: SearchSourceStatus.empty,
            ),
            SearchSourceRun(
              id: SearchProviderId.zlibrary,
              displayName: 'Z-Library',
              resultCount: 0,
              status: SearchSourceStatus.empty,
            ),
            SearchSourceRun(
              id: SearchProviderId.welib,
              displayName: 'WeLib',
              resultCount: 0,
              status: SearchSourceStatus.failed,
            ),
            SearchSourceRun(
              id: SearchProviderId.annasArchive,
              displayName: "Anna's Archive",
              resultCount: 0,
              status: SearchSourceStatus.empty,
            ),
          ],
        );
      },
    );

    final l10n = AppLocalizations.of(
        tester.element(find.byType(ResultPage).first));
    expect(find.byType(SourceJourneyCard), findsOneWidget);
    expect(find.text(l10n.noResultsFor('docker')), findsOneWidget);
    expect(find.text(l10n.clearFiltersRetry), findsOneWidget);

    await tester.tap(find.text(l10n.clearFiltersRetry));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(calls, greaterThan(1));
  });

  testWidgets('a source route opens on that source but still fetches all',
      (tester) async {
    final keys = await pumpResults(
      tester,
      source: SearchProviderId.welib,
      search: (key) async => multiSourcePage(key.page),
    );

    expect(keys.first.source, isNull,
        reason: 'the first page always queries every source');
    expect(find.text('WeLib 1-0'), findsWidgets);
    expect(find.text('LibGen 1-0'), findsNothing);
  });
}