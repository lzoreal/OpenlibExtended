// Package imports:
import 'package:meta/meta.dart';

// Project imports:
import 'package:openlib/data/models/book_data.dart';

/// One searchable catalog the app can query.
enum SearchProviderId { annasArchive, libgen, zlibrary, welib }

/// How one enabled catalog fared in a parallel search.
enum SearchSourceStatus {
  /// The source is still being queried.
  pending,

  /// This source produced at least one result.
  hit,

  /// The source was reached but returned nothing.
  empty,

  /// The source threw. The other sources still contribute their results.
  failed,

  /// Every mirror had a fresh local timeout, so this search skipped it.
  locallyUnreachable,

  /// Kept for stored/older payloads; parallel searches query every source.
  skipped,
}

/// One row of the search's source summary, in the configured order.
@immutable
class SearchSourceRun {
  final SearchProviderId id;
  final String displayName;
  final int resultCount;
  final SearchSourceStatus status;

  const SearchSourceRun({
    required this.id,
    required this.displayName,
    required this.resultCount,
    required this.status,
  });

  bool get wasAttempted =>
      status != SearchSourceStatus.skipped &&
      status != SearchSourceStatus.locallyUnreachable;
}

/// Combined outcome of a parallel search.
@immutable
class SearchManagerResult {
  /// All results from every queried source, de-duplicated by md5 in the
  /// configured source order. This is the "All sources" view.
  final List<BookData> books;

  /// Display names of providers that threw; the UI can mention them while
  /// still showing the surviving results.
  final List<String> failedProviders;

  /// The first catalog that returned anything, in configured order. Kept
  /// as the default single-source view.
  final String resultSource;

  /// The id of [resultSource]; null when nothing was found.
  final SearchProviderId? resultSourceId;

  /// Every queried source in configured order, with its own status and
  /// result count. All enabled sources are queried in parallel.
  final List<SearchSourceRun> sources;

  /// Page results per catalog, already de-duplicated within that catalog.
  /// The results page switches between these lists without re-searching.
  final Map<SearchProviderId, List<BookData>> booksBySource;

  const SearchManagerResult({
    required this.books,
    required this.failedProviders,
    this.resultSource = '',
    this.resultSourceId,
    this.sources = const [],
    this.booksBySource = const {},
  });
}
