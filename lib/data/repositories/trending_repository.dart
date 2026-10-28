// Project imports:
import 'package:openlib/data/models/trending_book_data.dart';
import 'package:openlib/data/services/open_library.dart';

/// Merges the trending shelves the app has always shown on the home tab.
///
/// Each source already swallows its own network errors and returns an empty
/// list, so one slow or dead shelf cannot keep the others off screen.
class TrendingRepository {
  TrendingRepository({List<TrendingBooksImpl>? sources})
      : _sources = sources ?? [GoodReads(), PenguinRandomHouse(), BookDigits()];

  final List<TrendingBooksImpl> _sources;

  Future<List<TrendingBookData>> trendingBooks() async {
    final pages = await Future.wait(
      _sources.map((source) => source.trendingBooks()),
    );
    return pages.expand((books) => books).toList();
  }
}
