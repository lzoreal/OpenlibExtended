// The results pager owns the per-view book lists, the page cursor and the
// de-duplication rules, so it can be verified without pumping a page.

// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/data/services/annas_archieve.dart';
import 'package:openlib/data/services/search_manager.dart';
import 'package:openlib/state/results_pager.dart';

List<BookData> _books(String tag, int page, int count) {
  return List.generate(
    count,
    (i) => BookData(
      title: '$tag $page-$i',
      link: 'https://example.com/$tag-$page-$i',
      md5: '$tag-$page-$i',
      source: tag,
    ),
  );
}

SearchManagerResult _page(int page, {int libgenCount = 2}) {
  final libgen = _books('libgen', page, libgenCount);
  final zlibrary = _books('zlibrary', page, 3);
  return SearchManagerResult(
    books: [...libgen, ...zlibrary],
    failedProviders: const [],
    resultSource: 'Library Genesis',
    resultSourceId: SearchProviderId.libgen,
    sources: const [
      SearchSourceRun(
        id: SearchProviderId.libgen,
        displayName: 'Library Genesis',
        resultCount: 2,
        status: SearchSourceStatus.hit,
      ),
      SearchSourceRun(
        id: SearchProviderId.zlibrary,
        displayName: 'Z-Library',
        resultCount: 3,
        status: SearchSourceStatus.hit,
      ),
    ],
    booksBySource: {
      SearchProviderId.libgen: libgen,
      SearchProviderId.zlibrary: zlibrary,
    },
  );
}

List<String> _ids(List<BookData> books) => books.map((b) => b.md5).toList();

void main() {
  test('applyInitial seeds the merged and single-source views', () {
    final pager = ResultsPager();

    pager.applyInitial(_page(1));

    expect(pager.booksFor(null), hasLength(5));
    expect(_ids(pager.booksFor(SearchProviderId.libgen)),
        _ids(_books('libgen', 1, 2)));
    expect(pager.pageOf(null), 1);
    expect(pager.pageOf(SearchProviderId.zlibrary), 1);
  });

  test('applyInitial opens on the route source when it ran', () {
    final pager = ResultsPager(routeSource: SearchProviderId.zlibrary);

    pager.applyInitial(_page(1));

    expect(pager.selectedSource, SearchProviderId.zlibrary);
  });

  test('applyInitial falls back to the merged view for a missing route source',
      () {
    final pager = ResultsPager(routeSource: SearchProviderId.welib);

    pager.applyInitial(_page(1));

    expect(pager.selectedSource, isNull);
  });

  test('merge appends only books that are new', () {
    final pager = ResultsPager();
    pager.applyInitial(_page(1));

    final late = _books('libgen', 1, 3);
    pager.merge(SearchManagerResult(
      books: [...late, ..._books('zlibrary', 1, 3)],
      failedProviders: const [],
      sources: _page(1).sources,
      booksBySource: {
        SearchProviderId.libgen: late,
        SearchProviderId.zlibrary: _books('zlibrary', 1, 3),
      },
    ));

    expect(pager.booksFor(null), hasLength(6));
    expect(
        pager.booksFor(null).map((b) => b.md5).toSet(), hasLength(6));
  });

  test('merge does not rewind a view that already paginated', () {
    final pager = ResultsPager();
    pager.applyInitial(_page(1));
    pager.appendPage(page: 2, view: null, result: _page(2));

    pager.merge(_page(1));

    expect(pager.booksFor(null), hasLength(10));
    expect(pager.pageOf(null), 2);
  });

  test('appending to the merged view advances the per-source cursors', () {
    final pager = ResultsPager();
    pager.applyInitial(_page(1));

    pager.appendPage(page: 2, view: null, result: _page(2));

    expect(pager.pageOf(SearchProviderId.libgen), 2);
    expect(pager.booksFor(SearchProviderId.libgen), hasLength(4));
    expect(_ids(pager.booksFor(SearchProviderId.libgen)),
        containsAll(_ids(_books('libgen', 2, 2))));
  });

  test('an empty page ends only the requested view', () {
    final pager = ResultsPager();
    pager.applyInitial(_page(1));

    pager.appendPage(
      page: 2,
      view: SearchProviderId.libgen,
      result: _page(2, libgenCount: 0),
    );

    pager.selectSource(SearchProviderId.libgen);
    expect(pager.currentViewEnded, isTrue);

    pager.selectSource(null);
    expect(pager.currentViewEnded, isFalse);
  });

  test('reset clears the pager and restores the route source', () {
    final pager = ResultsPager(routeSource: SearchProviderId.zlibrary);
    pager.applyInitial(_page(1));
    pager.selectSource(null);

    pager.reset();

    expect(pager.firstResult, isNull);
    expect(pager.booksFor(null), isEmpty);
    expect(pager.selectedSource, SearchProviderId.zlibrary);
    expect(pager.fetchingNextPage, isFalse);
  });
}
