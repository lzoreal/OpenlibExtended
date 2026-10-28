// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/data/models/book_data.dart';
import 'package:openlib/data/models/search_result.dart';
import 'package:openlib/data/services/challenge_html_cache.dart';
import 'package:openlib/data/services/search_manager.dart';
import 'package:openlib/data/services/webview_challenge_solver.dart';
import 'package:openlib/ui/features/results/widgets/search_result_card.dart';
import 'package:openlib/ui/features/results/widgets/source_journey_card.dart';
import 'package:openlib/ui/features/results/views/results_page.dart';

import 'helpers/results_test_support.dart';

List<BookData> _sourceBooks(
    String tag, String displayName, int page, int count) {
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
  Future<ScriptedSearchRepository> pumpResults(
    WidgetTester tester, {
    Future<SearchManagerResult> Function(SearchQuery query)? search,
    Stream<SearchManagerResult> Function(SearchQuery query)? watch,
    String query = 'docker',
    SearchProviderId? source,
  }) async {
    final repository = ScriptedSearchRepository()
      ..pageHandler = search
      ..watchHandler = watch;
    final viewModel = testResultsViewModel(
      query: query,
      source: source,
      search: repository,
    );
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ResultPage(
        searchQuery: query,
        source: source,
        viewModel: viewModel,
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    return repository;
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
    final l10n =
        AppLocalizations.of(tester.element(find.byType(ResultPage).first));
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

    final l10n =
        AppLocalizations.of(tester.element(find.byType(ResultPage).first));
    await tester.tap(sourceTile(l10n.sourceWelib));
    await tester.pump();

    expect(find.text('WeLib 1-0'), findsWidgets);
    expect(find.text('LibGen 1-0'), findsNothing);

    await tester.tap(sourceTile(l10n.searchSourceAuto));
    await tester.pump();
    expect(find.text('LibGen 1-0'), findsWidgets);
  });

  testWidgets('skipped source offers try-anyway and forces a retry',
      (tester) async {
    SearchManagerResult skippedPage(int page) {
      final base = multiSourcePage(page);
      return SearchManagerResult(
        books: base.books.where((book) => book.source != 'Z-Library').toList(),
        failedProviders: const [],
        resultSource: base.resultSource,
        resultSourceId: base.resultSourceId,
        sources: [
          for (final run in base.sources)
            if (run.id == SearchProviderId.zlibrary)
              const SearchSourceRun(
                id: SearchProviderId.zlibrary,
                displayName: 'Z-Library',
                resultCount: 0,
                status: SearchSourceStatus.locallyUnreachable,
              )
            else
              run,
        ],
        booksBySource: {
          for (final entry in base.booksBySource.entries)
            if (entry.key != SearchProviderId.zlibrary) entry.key: entry.value,
        },
      );
    }

    final repository = await pumpResults(
      tester,
      search: (key) async => skippedPage(key.page),
    );
    final l10n =
        AppLocalizations.of(tester.element(find.byType(ResultPage).first));

    expect(find.textContaining('Z-Library skipped'), findsOneWidget);
    expect(find.text(l10n.retryAnyway), findsOneWidget);

    await tester.tap(find.text(l10n.retryAnyway));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      repository.watchCalls.any((call) => call.forceLocalTimeouts),
      isTrue,
    );
  });

  testWidgets('later source snapshots merge without clearing earlier books',
      (tester) async {
    SearchManagerResult partial({required bool withZlib}) {
      final libgen = _sourceBooks('LibGen', 'Library Genesis', 1, 2);
      final zlib = withZlib
          ? _sourceBooks('Z-Library', 'Z-Library', 1, 3)
          : <BookData>[];
      return SearchManagerResult(
        books: [...libgen, ...zlib],
        failedProviders: const [],
        resultSource: 'Library Genesis',
        resultSourceId: SearchProviderId.libgen,
        sources: [
          const SearchSourceRun(
            id: SearchProviderId.libgen,
            displayName: 'Library Genesis',
            resultCount: 2,
            status: SearchSourceStatus.hit,
          ),
          SearchSourceRun(
            id: SearchProviderId.zlibrary,
            displayName: 'Z-Library',
            resultCount: zlib.length,
            status:
                withZlib ? SearchSourceStatus.hit : SearchSourceStatus.pending,
          ),
        ],
        booksBySource: {
          SearchProviderId.libgen: libgen,
          if (withZlib) SearchProviderId.zlibrary: zlib,
        },
      );
    }

    final controller = StreamController<SearchManagerResult>();
    addTearDown(controller.close);
    await pumpResults(tester, watch: (_) => controller.stream);

    controller.add(partial(withZlib: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('LibGen 1-0'), findsWidgets);
    expect(find.text('Z-Library 1-0'), findsNothing);

    controller.add(partial(withZlib: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('LibGen 1-0'), findsWidgets,
        reason: 'the first snapshot must survive the merge');
    expect(find.text('Z-Library 1-0'), findsWidgets,
        reason: 'the late source is appended in place');
  });

  testWidgets('the merged view paginates without pinning a source',
      (tester) async {
    final repository = await pumpResults(
      tester,
      search: (key) async => key.page >= 3
          ? const SearchManagerResult(books: [], failedProviders: [])
          : multiSourcePage(key.page),
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -4000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    final pageTwo =
        repository.searchCalls.where((call) => call.query.page == 2).toList();
    expect(pageTwo, isNotEmpty);
    expect(pageTwo.first.query.source, isNull);
    // The list is lazy now; the first appended row is the one in view.
    expect(find.text('LibGen 2-0'), findsWidgets);
  });

  testWidgets('a switched source paginates within that source', (tester) async {
    final repository = await pumpResults(
      tester,
      search: (key) async => key.page >= 3
          ? const SearchManagerResult(books: [], failedProviders: [])
          : multiSourcePage(key.page),
    );

    final l10n =
        AppLocalizations.of(tester.element(find.byType(ResultPage).first));
    await tester.tap(sourceTile(l10n.sourceZlibShort));
    await tester.pump();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -4000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    final pageTwo =
        repository.searchCalls.where((call) => call.query.page == 2).toList();
    expect(pageTwo, isNotEmpty);
    expect(pageTwo.first.query.source, SearchProviderId.zlibrary);
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

    final l10n =
        AppLocalizations.of(tester.element(find.byType(ResultPage).first));
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
    final repository = await pumpResults(
      tester,
      source: SearchProviderId.welib,
      search: (key) async => multiSourcePage(key.page),
    );

    expect(repository.watchCalls.first.query.source, isNull,
        reason: 'the first page always queries every source');
    expect(find.text('WeLib 1-0'), findsWidgets);
    expect(find.text('LibGen 1-0'), findsNothing);
  });

  testWidgets('format and language filters are single multi-select capsules',
      (tester) async {
    SearchManagerResult infoPage(int page) {
      final books = [
        BookData(
          title: 'Epub Book',
          author: 'Author',
          link: 'https://example.com/md5/epub',
          md5: 'epub',
          info: 'English · EPUB · 2 MB',
          source: 'Library Genesis',
        ),
        BookData(
          title: 'Pdf Book',
          author: 'Author',
          link: 'https://example.com/md5/pdf',
          md5: 'pdf',
          info: 'English · PDF · 3 MB',
          source: 'Library Genesis',
        ),
      ];
      return SearchManagerResult(
        books: books,
        failedProviders: const [],
        sources: [
          SearchSourceRun(
            id: SearchProviderId.libgen,
            displayName: 'Library Genesis',
            resultCount: books.length,
            status: SearchSourceStatus.hit,
          ),
        ],
        booksBySource: {SearchProviderId.libgen: books},
      );
    }

    await pumpResults(tester, search: (key) async => infoPage(key.page));

    final l10n =
        AppLocalizations.of(tester.element(find.byType(ResultPage).first));
    expect(find.byKey(const ValueKey('format-filter-capsule')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('language-filter-capsule')),
      findsOneWidget,
    );
    // One capsule per dimension: no chip per format any more.
    expect(find.widgetWithText(FilterChip, 'EPUB'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('format-filter-capsule')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxListTile, 'EPUB'));
    await tester.pump();
    await tester.tap(find.text(l10n.done));
    await tester.pumpAndSettle();

    expect(find.text('Epub Book'), findsWidgets);
    expect(find.text('Pdf Book'), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('format-filter-capsule')),
        matching: find.text('EPUB'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('the language capsule filters by the picked language',
      (tester) async {
    SearchManagerResult infoPage(int page) {
      final books = [
        BookData(
          title: 'Epub Book',
          author: 'Author',
          link: 'https://example.com/md5/epub',
          md5: 'epub',
          info: 'English · EPUB · 2 MB',
          source: 'Library Genesis',
        ),
        BookData(
          title: 'Pdf Book',
          author: 'Author',
          link: 'https://example.com/md5/pdf',
          md5: 'pdf',
          info: 'Chinese · PDF · 3 MB',
          source: 'Library Genesis',
        ),
      ];
      return SearchManagerResult(
        books: books,
        failedProviders: const [],
        sources: [
          SearchSourceRun(
            id: SearchProviderId.libgen,
            displayName: 'Library Genesis',
            resultCount: books.length,
            status: SearchSourceStatus.hit,
          ),
        ],
        booksBySource: {SearchProviderId.libgen: books},
      );
    }

    await pumpResults(tester, search: (key) async => infoPage(key.page));

    final l10n =
        AppLocalizations.of(tester.element(find.byType(ResultPage).first));
    final capsule = find.byKey(const ValueKey('language-filter-capsule'));
    expect(capsule, findsOneWidget);

    await tester.tap(capsule);
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(CheckboxListTile, l10n.languageNameZh),
    );
    await tester.pump();
    await tester.tap(find.text(l10n.done));
    await tester.pumpAndSettle();

    expect(find.text('Pdf Book'), findsWidgets);
    expect(find.text('Epub Book'), findsNothing);
    expect(
      find.descendant(of: capsule, matching: find.text(l10n.languageNameZh)),
      findsOneWidget,
    );
  });

  testWidgets('a failed auto-solve offers manual verification with retry copy',
      (tester) async {
    const url = 'https://annas-archive.pk/search?q=docker';
    WebviewChallengeSolver.failedChallenges.value = [url];
    addTearDown(WebviewChallengeSolver.clearAutoSolveFailures);

    await pumpResults(
      tester,
      search: (key) async => multiSourcePage(key.page),
    );
    final l10n =
        AppLocalizations.of(tester.element(find.byType(ResultPage).first));

    expect(find.text(l10n.challengeNeedsVerificationRetry), findsOneWidget);
    expect(find.text(l10n.challengeVerifyNow), findsOneWidget);
  });

  testWidgets('a pending challenge offers the verification page',
      (tester) async {
    SearchManagerResult pendingPage(int page) {
      final books = [
        BookData(
          title: 'Libgen Book',
          author: 'Author',
          link: 'https://example.com/md5/libgen',
          md5: 'libgen',
          info: 'English · EPUB · 2 MB',
          source: 'Library Genesis',
        ),
      ];
      return SearchManagerResult(
        books: books,
        failedProviders: const [],
        sources: [
          SearchSourceRun(
            id: SearchProviderId.libgen,
            displayName: 'Library Genesis',
            resultCount: books.length,
            status: SearchSourceStatus.hit,
          ),
          SearchSourceRun(
            id: SearchProviderId.welib,
            displayName: 'WeLib',
            resultCount: 0,
            status: SearchSourceStatus.pending,
          ),
        ],
        booksBySource: {SearchProviderId.libgen: books},
      );
    }

    ChallengeHtmlCache.clear();
    var asked = '';
    WebviewChallengeSolver.visibleSolverFallback = (url) async {
      asked = url;
      return '<html>solved visibly</html>';
    };
    addTearDown(() {
      WebviewChallengeSolver.visibleSolverFallback = null;
      WebviewChallengeSolver.clearPendingChallenges();
    });

    await pumpResults(tester, search: (key) async => pendingPage(key.page));
    final l10n =
        AppLocalizations.of(tester.element(find.byType(ResultPage).first));

    // Nothing blocked yet: just the plain "still searching" hint.
    expect(find.text(l10n.challengeVerifyNow), findsNothing);

    const challengeUrl = 'https://welib.org/search?q=docker';
    WebviewChallengeSolver.pendingChallenges.value = [challengeUrl];
    await tester.pump();

    expect(find.text(l10n.challengeNeedsVerification), findsOneWidget);
    await tester.tap(find.text(l10n.challengeVerifyNow));
    await tester.pump();
    await tester.pump();

    expect(asked, challengeUrl);
  });
}
