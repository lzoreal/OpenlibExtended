// Project imports:
import 'package:openlib/services/annas_archieve.dart';
import 'package:openlib/services/search_manager.dart';

/// Book lists for the merged and per-source result views, plus their page
/// cursors. The results page reads this and calls it; none of the merge or
/// de-duplication rules live in the widget any more.
class ResultsPager {
  ResultsPager({SearchProviderId? routeSource}) : _routeSource = routeSource;

  final SearchProviderId? _routeSource;
  final Map<String, List<BookData>> _viewBooks = {};
  final Map<String, Set<String>> _viewSeen = {};
  final Map<String, int> _viewPages = {};
  final Set<String> _viewEnded = {};

  SearchManagerResult? firstResult;
  SearchProviderId? selectedSource;
  bool fetchingNextPage = false;

  String _viewKey(SearchProviderId? source) => source?.name ?? 'all';

  List<BookData> booksFor(SearchProviderId? source) =>
      _viewBooks[_viewKey(source)] ?? const <BookData>[];

  int pageOf(SearchProviderId? source) => _viewPages[_viewKey(source)] ?? 1;

  bool get currentViewEnded => _viewEnded.contains(_viewKey(selectedSource));

  void applyInitial(SearchManagerResult result) {
    firstResult = result;
    _viewBooks.clear();
    _viewSeen.clear();
    _viewPages.clear();
    _viewEnded.clear();
    final previous = selectedSource;
    selectedSource = previous != null &&
            result.sources.any((run) => run.id == previous)
        ? previous
        : _routeSourcePresent(result);

    void put(SearchProviderId? source, List<BookData> books) {
      final key = _viewKey(source);
      final copy = List<BookData>.of(books);
      _viewBooks[key] = copy;
      _viewSeen[key] = copy.map((book) => book.md5).toSet();
      _viewPages[key] = 1;
      if (copy.isEmpty) _viewEnded.add(key);
    }

    put(null, result.books);
    for (final run in result.sources) {
      final sourceBooks = result.booksBySource[run.id] ??
          (run.id == result.resultSourceId
              ? result.books
              : const <BookData>[]);
      put(run.id, sourceBooks);
    }
    fetchingNextPage = false;
  }

  SearchProviderId? _routeSourcePresent(SearchManagerResult result) {
    final route = _routeSource;
    return route != null && result.sources.any((run) => run.id == route)
        ? route
        : null;
  }

  /// Later snapshots add books from sources that finished after the first
  /// paint. Merge instead of clearing, so pagination and the user's scroll
  /// position survive the stream.
  void merge(SearchManagerResult result) {
    firstResult = result;

    void mergeView(
      SearchProviderId? source,
      List<BookData> books, {
      bool replacePageOne = false,
    }) {
      final key = _viewKey(source);
      final existing = _viewBooks[key];
      final seen = _viewSeen[key];
      if (existing == null || seen == null) {
        _viewBooks[key] = List<BookData>.of(books);
        _viewSeen[key] = books.map((book) => book.md5).toSet();
        _viewPages[key] = 1;
        if (books.isEmpty) _viewEnded.add(key);
        return;
      }

      final page = _viewPages[key] ?? 1;
      if (replacePageOne && page <= 1) {
        _viewBooks[key] = List<BookData>.of(books);
        _viewSeen[key] = books.map((book) => book.md5).toSet();
        if (books.isEmpty) {
          _viewEnded.add(key);
        } else {
          _viewEnded.remove(key);
        }
        return;
      }

      for (final book in books) {
        if (seen.add(book.md5)) existing.add(book);
      }
      if (existing.isNotEmpty) _viewEnded.remove(key);
    }

    mergeView(null, result.books);
    for (final run in result.sources) {
      final sourceBooks = result.booksBySource[run.id] ??
          (run.id == result.resultSourceId
              ? result.books
              : const <BookData>[]);
      mergeView(run.id, sourceBooks, replacePageOne: true);
    }
    fetchingNextPage = false;
  }

  void appendPage({
    required int page,
    required SearchProviderId? view,
    required SearchManagerResult result,
  }) {
    final key = _viewKey(view);
    final pageBooks = view == null
        ? result.books
        : (result.booksBySource[view] ?? result.books);
    final list = _viewBooks[key] ??= <BookData>[];
    final seen = _viewSeen[key] ??= <String>{};
    for (final book in pageBooks) {
      if (seen.add(book.md5)) list.add(book);
    }
    _viewPages[key] = page;
    if (pageBooks.isEmpty) _viewEnded.add(key);

    // An "all sources" page contains every source's page too; keep the
    // single-source caches in step so switching does not throw away pages
    // already downloaded.
    if (view == null) {
      for (final entry in result.booksBySource.entries) {
        final sourceKey = entry.key.name;
        final sourceList = _viewBooks[sourceKey] ??= <BookData>[];
        final sourceSeen = _viewSeen[sourceKey] ??= <String>{};
        for (final book in entry.value) {
          if (sourceSeen.add(book.md5)) sourceList.add(book);
        }
        _viewPages[sourceKey] = page;
        if (entry.value.isEmpty) _viewEnded.add(sourceKey);
      }
    }
    fetchingNextPage = false;
  }

  void selectSource(SearchProviderId? source) {
    if (selectedSource == source) return;
    selectedSource = source;
    fetchingNextPage = false;
  }

  void reset() {
    _viewBooks.clear();
    _viewSeen.clear();
    _viewPages.clear();
    _viewEnded.clear();
    firstResult = null;
    fetchingNextPage = false;
    selectedSource = _routeSource;
  }
}
