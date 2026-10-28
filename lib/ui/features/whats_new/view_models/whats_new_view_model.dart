// Project imports:
import 'package:openlib/app/di.dart';
import 'package:openlib/data/repositories/mirror_repository.dart';
import 'package:openlib/data/repositories/search_repository.dart';
import 'package:openlib/data/services/instance_manager.dart'
    show MirrorRefreshResult;

/// The one action the What's New sources tab performs: re-sync the stored
/// mirror list and turn every search provider back on after an upgrade.
class WhatsNewViewModel {
  WhatsNewViewModel({
    required MirrorRepository mirrors,
    required SearchRepository search,
  })  : _mirrors = mirrors,
        _search = search;

  factory WhatsNewViewModel.fromDi() => WhatsNewViewModel(
        mirrors: getIt<MirrorRepository>(),
        search: getIt<SearchRepository>(),
      );

  final MirrorRepository _mirrors;
  final SearchRepository _search;

  Future<MirrorRefreshResult> updateInstances() async {
    final result = await _mirrors.refresh();
    // Upgraders get every search provider back on: a stale saved toggle
    // list must not silently hide a new release's sources.
    await _search.enableAllProviders();
    return result;
  }
}
