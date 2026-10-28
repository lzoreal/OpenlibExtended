// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:openlib/app/app_settings.dart';
import 'package:openlib/app/di.dart';
import 'package:openlib/data/services/goodreads.dart'
    show CategoryBookData, SubCategoriesTypeList;

/// Loads one Goodreads shelf route for [CategoryListingPage].
class CategoriesViewModel extends ChangeNotifier {
  CategoriesViewModel({
    required this.url,
    required AppSettings settings,
    SubCategoriesTypeList? service,
  })  : _settings = settings,
        _service = service ?? SubCategoriesTypeList();

  factory CategoriesViewModel.fromDi({required String url}) =>
      CategoriesViewModel(url: url, settings: getIt<AppSettings>());

  final String url;
  final AppSettings _settings;
  final SubCategoriesTypeList _service;

  List<CategoryBookData> _books = const [];
  bool _loading = false;
  Object? _error;
  StackTrace? _errorStackTrace;
  bool _loadStarted = false;
  bool _disposed = false;

  List<CategoryBookData> get books => _books;

  bool get loading => _loading;

  Object? get error => _error;

  StackTrace? get errorStackTrace => _errorStackTrace;

  Future<void> load() async {
    if (_loadStarted) return;
    _loadStarted = true;
    await _fetch();
  }

  Future<void> refresh() => _fetch();

  /// A shelf pick searches by title only, so the advanced filters are
  /// cleared before the results route builds its query.
  void prepareOpen() {
    _settings.setFiltersEnabled(false);
  }

  Future<void> _fetch() async {
    _loading = true;
    _error = null;
    _errorStackTrace = null;
    _notify();
    try {
      final books = await _service.categoriesBooks(url: url);
      if (_disposed) return;
      _books = List.unmodifiable(books.toSet().toList()..shuffle());
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
