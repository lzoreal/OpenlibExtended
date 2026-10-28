// Project imports:
import 'package:openlib/data/repositories/mirror_repository.dart';
import 'package:openlib/data/services/instance_manager.dart';
import 'package:openlib/data/services/mirror_latency.dart';

/// A [MirrorRepository] with no network: mirror lists, the auto/manual
/// choice and the persisted latency readings all live in memory.
class InstancesMirrorRepository extends MirrorRepository {
  InstancesMirrorRepository({
    this.autoMode = true,
    Map<MirrorService, List<InstanceView>>? views,
  }) : views = views ?? <MirrorService, List<InstanceView>>{};

  bool autoMode;
  final Map<MirrorService, List<InstanceView>> views;
  final Map<String, MirrorLatencyReading> readings = {};

  final List<MirrorService> instanceRequests = [];
  int refreshCalls = 0;
  int measureCalls = 0;
  Object? refreshError;
  MirrorRefreshResult refreshResult =
      const MirrorRefreshResult(changes: [], hasMirrorList: true);
  Future<Map<String, int?>> Function(Iterable<String>)? measureHandler;

  @override
  Future<bool> isAutoMode() async => autoMode;

  @override
  Future<void> setAutoMode(bool auto) async {
    autoMode = auto;
  }

  @override
  Future<List<InstanceView>> instances(MirrorService service,
      {bool force = false}) async {
    instanceRequests.add(service);
    return views[service] ?? const <InstanceView>[];
  }

  @override
  Future<void> setEnabled(
      MirrorService service, String host, bool enabled) async {
    final current = views[service];
    if (current == null) return;
    views[service] = [
      for (final view in current)
        view.host == host
            ? InstanceView(site: view.site, enabled: enabled)
            : view,
    ];
  }

  @override
  Future<void> move(MirrorService service, String host, int delta) async {
    final current = views[service];
    if (current == null) return;
    final list = List<InstanceView>.of(current);
    final index = list.indexWhere((view) => view.host == host);
    if (index == -1) return;
    final target = (index + delta).clamp(0, list.length - 1);
    if (target == index) return;
    final moved = list.removeAt(index);
    list.insert(target, moved);
    views[service] = list;
  }

  @override
  Future<MirrorRefreshResult> refresh() async {
    refreshCalls++;
    final error = refreshError;
    if (error != null) throw error;
    return refreshResult;
  }

  @override
  Future<Map<String, MirrorLatencyReading>> localLatencies() async =>
      Map<String, MirrorLatencyReading>.of(readings);

  @override
  Future<void> saveLocalLatencies(Map<String, int?> results,
      {DateTime? testedAt}) async {
    final stamp = testedAt ?? DateTime.now();
    for (final entry in results.entries) {
      readings[entry.key] = MirrorLatencyReading(
        milliseconds: entry.value,
        testedAt: stamp,
      );
    }
  }

  @override
  Future<Map<String, int?>> measureLatency(Iterable<String> urls) {
    measureCalls++;
    return measureHandler?.call(urls) ?? Future.value(<String, int?>{});
  }
}
