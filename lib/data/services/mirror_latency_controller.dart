// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:openlib/data/repositories/mirror_repository.dart';
import 'package:openlib/data/services/instance_manager.dart';
import 'package:openlib/data/services/mirror_latency.dart';

@immutable
class MirrorLatencyState {
  const MirrorLatencyState({
    this.testing = false,
    this.testingHosts = const <String>{},
    this.readings = const <String, MirrorLatencyReading>{},
    this.loaded = false,
  });

  final bool testing;
  final Set<String> testingHosts;
  final Map<String, MirrorLatencyReading> readings;

  /// Whether persisted readings have been read at least once, so an empty
  /// [readings] map means "never tested" rather than "still loading".
  final bool loaded;

  MirrorLatencyState copyWith({
    bool? testing,
    Set<String>? testingHosts,
    Map<String, MirrorLatencyReading>? readings,
    bool? loaded,
  }) {
    return MirrorLatencyState(
      testing: testing ?? this.testing,
      testingHosts: testingHosts ?? this.testingHosts,
      readings: readings ?? this.readings,
      loaded: loaded ?? this.loaded,
    );
  }
}

/// True when no local latency reading is fresh enough to affect ordering.
bool hasFreshMirrorLatency(
    Map<String, MirrorLatencyReading> readings, DateTime now) {
  return readings.values.any((reading) => reading.isFreshAt(now));
}

/// The search page nudges the user after readings have loaded and every
/// stored reading is missing or older than 24 hours. It stays visible while
/// a test runs so the hint can show progress in place.
bool shouldShowMirrorLatencyHint(MirrorLatencyState state, DateTime now) {
  return state.loaded && !hasFreshMirrorLatency(state.readings, now);
}

@immutable
class MirrorLatencyResult {
  const MirrorLatencyResult({
    required this.total,
    required this.reachable,
    required this.fastestMs,
  });

  final int total;
  final int reachable;
  final int? fastestMs;
}

/// Runs one manual latency test over the enabled, non-down mirrors and
/// persists the readings. The page owns the trigger; this class owns the
/// filtering, in-flight state and storage merge.
class MirrorLatencyNotifier extends ChangeNotifier {
  MirrorLatencyNotifier(
    this._repository, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final MirrorRepository _repository;
  final DateTime Function() _clock;

  MirrorLatencyState _state = const MirrorLatencyState();
  bool _disposed = false;

  MirrorLatencyState get state => _state;

  void _setState(MirrorLatencyState next) {
    if (_disposed) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> load() async {
    final readings = await _repository.localLatencies();
    _setState(_state.copyWith(readings: readings, loaded: true));
  }

  Future<MirrorLatencyResult> test(Iterable<InstanceView> views) async {
    final targets = <SlumSite>[];
    final seen = <String>{};
    for (final view in views) {
      if (!view.enabled || view.site.isDown) continue;
      if (seen.add(view.site.host)) targets.add(view.site);
    }
    if (targets.isEmpty) {
      return const MirrorLatencyResult(
        total: 0,
        reachable: 0,
        fastestMs: null,
      );
    }

    final hosts = targets.map((site) => site.host).toSet();
    _setState(_state.copyWith(testing: true, testingHosts: hosts));
    try {
      final results =
          await _repository.measureLatency(targets.map((site) => site.url));
      await _repository.saveLocalLatencies(results, testedAt: _clock());
      final readings = await _repository.localLatencies();
      _setState(MirrorLatencyState(readings: readings, loaded: true));

      var reachable = 0;
      int? fastest;
      for (final value in results.values) {
        if (value == null) continue;
        reachable++;
        if (fastest == null || value < fastest) fastest = value;
      }
      return MirrorLatencyResult(
        total: hosts.length,
        reachable: reachable,
        fastestMs: fastest,
      );
    } catch (_) {
      _setState(_state.copyWith(
        testing: false,
        testingHosts: const <String>{},
      ));
      rethrow;
    }
  }
}
