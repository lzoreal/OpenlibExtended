// Project imports:
import 'package:openlib/data/models/search_result.dart';
import 'package:openlib/data/services/search_manager.dart';

/// Search-facing entry point for the app: owns the single [SearchManager]
/// so the UI and state layer never build their own provider chain.
class SearchRepository {
  SearchRepository({SearchManager? manager})
      : _manager = manager ?? SearchManager();

  final SearchManager _manager;

  Future<SearchManagerResult> search(SearchQuery query,
          {bool forceLocalTimeouts = false}) =>
      _manager.search(query, forceLocalTimeouts: forceLocalTimeouts);

  Stream<SearchManagerResult> watch(SearchQuery query,
          {bool forceLocalTimeouts = false}) =>
      _manager.watch(query, forceLocalTimeouts: forceLocalTimeouts);

  Future<Set<SearchProviderId>> enabledProviders() =>
      _manager.enabledProviders();

  Future<void> setProviderEnabled(SearchProviderId id, bool enabled) =>
      _manager.setProviderEnabled(id, enabled);

  Future<void> enableAllProviders() => _manager.enableAllProviders();

  Future<List<SearchProviderId>> sourceOrder() => _manager.sourceOrder();

  Future<void> setSourceOrder(List<SearchProviderId> order) =>
      _manager.setSourceOrder(order);
}
