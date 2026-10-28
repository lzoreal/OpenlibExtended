// Project imports:
import 'package:openlib/data/services/instance_manager.dart';
import 'package:openlib/data/services/mirror_latency.dart';

/// The app's entry point to the mirror catalogue and its local latency
/// readings.
///
/// Selection rules (auto/manual order, DOWN/disabled filtering, the 24 h
/// reading TTL) stay in [InstanceManager]; this only gives the state and
/// UI layers one injected dependency instead of the singleton.
class MirrorRepository {
  MirrorRepository({InstanceManager? manager, MirrorLatencyTester? tester})
      : _manager = manager ?? InstanceManager(),
        _tester = tester ?? const MirrorLatencyTester();

  final InstanceManager _manager;
  final MirrorLatencyTester _tester;

  Future<List<InstanceView>> instances(MirrorService service,
          {bool force = false}) =>
      _manager.instances(service, force: force);

  Future<List<String>> enabledUrls(MirrorService service,
          {bool force = false, bool headlessOnly = false}) =>
      _manager.enabledUrls(service, force: force, headlessOnly: headlessOnly);

  Future<bool> isAutoMode() => _manager.isAutoMode();

  Future<void> setAutoMode(bool auto) => _manager.setAutoMode(auto);

  Future<bool> isSpeedFirst() => _manager.isSpeedFirst();

  Future<void> setSpeedFirst(bool value) => _manager.setSpeedFirst(value);

  Future<void> setEnabled(MirrorService service, String host, bool enabled) =>
      _manager.setEnabled(service, host, enabled);

  Future<void> move(MirrorService service, String host, int delta) =>
      _manager.move(service, host, delta);

  Future<MirrorRefreshResult> refresh() => _manager.refresh();

  Future<void> refreshOnStartup() => _manager.refreshOnStartup();

  Future<Map<String, MirrorLatencyReading>> localLatencies() =>
      _manager.localLatencies();

  Future<void> saveLocalLatencies(Map<String, int?> results,
          {DateTime? testedAt}) =>
      _manager.saveLocalLatencies(results, testedAt: testedAt);

  Future<Map<String, int?>> measureLatency(Iterable<String> urls) =>
      _tester.measure(urls);
}
