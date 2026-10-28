// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:openlib/app/app_settings.dart';
import 'package:openlib/app/di.dart';
import 'package:openlib/data/models/trending_book_data.dart';
import 'package:openlib/data/repositories/trending_repository.dart';

/// Owns the shuffled "trending this week" strip shown above the genre
/// shortcuts.
class TrendingViewModel extends ChangeNotifier {
  TrendingViewModel({
    required TrendingRepository trending,
    required AppSettings settings,
  })  : _trending = trending,
        _settings = settings;

  factory TrendingViewModel.fromDi() => TrendingViewModel(
        trending: getIt<TrendingRepository>(),
        settings: getIt<AppSettings>(),
      );

  final TrendingRepository _trending;
  final AppSettings _settings;

  List<TrendingBookData> _books = const [];
  bool _loading = false;
  Object? _error;
  StackTrace? _errorStackTrace;
  bool _loadStarted = false;
  bool _disposed = false;

  List<TrendingBookData> get books => _books;

  bool get loading => _loading;

  Object? get error => _error;

  StackTrace? get errorStackTrace => _errorStackTrace;

  Future<void> load() async {
    if (_loadStarted) return;
    _loadStarted = true;
    await _fetch();
  }

  /// Pull-to-refresh keeps the current strip on screen - the
  /// RefreshIndicator shows the progress, so flipping [loading] here would
  /// replace the list with a full-page spinner mid-gesture.
  Future<void> refresh() => _fetch(showSpinner: false);

  /// A trending tap searches by title only, so the advanced filters are
  /// cleared before the results route builds its query.
  void prepareOpen({required bool filtersEnabled}) {
    _settings.setFiltersEnabled(filtersEnabled);
  }

  Future<void> _fetch({bool showSpinner = true}) async {
    if (showSpinner) _loading = true;
    _error = null;
    _errorStackTrace = null;
    _notify();
    try {
      final books = await _trending.trendingBooks();
      if (_disposed) return;
      if (books.isEmpty) {
        throw Exception('Nothing Trending Today :(');
      }
      books.shuffle();
      _books = List.unmodifiable(books);
    } catch (error, stackTrace) {
      if (_disposed) return;
      _books = const [];
      _error = error;
      _errorStackTrace = stackTrace;
    } finally {
      if (!_disposed) {
        _loading = false;
        _notify();
      }
    }
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
