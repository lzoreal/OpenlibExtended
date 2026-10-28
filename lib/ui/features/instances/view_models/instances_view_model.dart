// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:openlib/app/di.dart';
import 'package:openlib/data/repositories/mirror_repository.dart';
import 'package:openlib/data/services/instance_manager.dart';
import 'package:openlib/data/services/mirror_latency_controller.dart';

/// Owns Settings > Mirrors state: the auto/manual ordering choice, one
/// mirror list per service, and the shared local-latency readings.
class InstancesViewModel extends ChangeNotifier {
  InstancesViewModel({
    required MirrorRepository mirrors,
    required MirrorLatencyNotifier latency,
  })  : _mirrors = mirrors,
        _latency = latency {
    _latencyState = _latency.state;
    _latency.addListener(_onLatencyChanged);
  }

  factory InstancesViewModel.fromDi() => InstancesViewModel(
        mirrors: getIt<MirrorRepository>(),
        latency: getIt<MirrorLatencyNotifier>(),
      );

  static const List<MirrorService> serviceOrder = [
    MirrorService.libgen,
    MirrorService.zlibrary,
    MirrorService.welib,
    MirrorService.annasArchive,
  ];

  final MirrorRepository _mirrors;
  final MirrorLatencyNotifier _latency;

  final Map<MirrorService, List<InstanceView>> _instances = {};
  final Set<MirrorService> _loading = {};
  final Map<MirrorService, Object> _errors = {};
  // The shared notifier owns the readings; this copy is what the page
  // rebuilds from when the notifier reports progress.
  MirrorLatencyState _latencyState = const MirrorLatencyState();
  bool _autoMode = true;
  bool _refreshing = false;
  bool _loadStarted = false;
  bool _disposed = false;

  bool get autoMode => _autoMode;

  bool get refreshing => _refreshing;

  MirrorLatencyState get latency => _latencyState;

  Map<MirrorService, List<InstanceView>> get instances => _instances;

  /// A service shows its spinner only until its first answer (success or
  /// error); reloads keep the current list on screen.
  bool isLoading(MirrorService service) =>
      !_instances.containsKey(service) && !_errors.containsKey(service);

  Object? errorFor(MirrorService service) => _errors[service];

  Future<void> load() async {
    if (_loadStarted) return;
    _loadStarted = true;
    unawaited(_loadLatencyReadings());
    await Future.wait([
      _hydrateAutoMode(),
      for (final service in serviceOrder) loadService(service),
    ]);
  }

  Future<void> _loadLatencyReadings() async {
    try {
      await _latency.load();
    } catch (_) {
      // Readings are optional; mirrors then just read as "not tested".
    }
  }

  // The manager persists the mode; the switch must show the value the
  // manager will actually apply, or a restart in manual mode displays
  // "Automatic mirror order" while using the user's pinned order.
  Future<void> _hydrateAutoMode() async {
    try {
      final auto = await _mirrors.isAutoMode();
      if (_disposed) return;
      _autoMode = auto;
      _notify();
    } catch (_) {
      // Keep the automatic default.
    }
  }

  Future<void> loadService(MirrorService service, {bool force = false}) async {
    _loading.add(service);
    _errors.remove(service);
    _notify();
    try {
      final views = await _mirrors.instances(service, force: force);
      if (_disposed) return;
      _instances[service] = List.unmodifiable(views);
    } catch (error) {
      if (_disposed) return;
      _instances.remove(service);
      _errors[service] = error;
    } finally {
      _loading.remove(service);
      _notify();
    }
  }

  Future<void> setAutoMode(bool value) async {
    await _mirrors.setAutoMode(value);
    if (_disposed) return;
    _autoMode = value;
    _notify();
    for (final service in serviceOrder) {
      unawaited(loadService(service));
    }
  }

  /// Refreshes the catalogue and then every service list, so the page can
  /// report what changed. Returns null when a refresh is already running.
  Future<MirrorRefreshResult?> refreshAll() async {
    if (_refreshing) return null;
    _refreshing = true;
    _notify();
    try {
      // A failed fetch must keep the lists as they are; the page shows the
      // error instead of an empty catalogue.
      final result = await _mirrors.refresh();
      await Future.wait([
        for (final service in serviceOrder) loadService(service),
      ]);
      return result;
    } finally {
      _refreshing = false;
      _notify();
    }
  }

  Future<MirrorRefreshResult?> refresh() => refreshAll();

  Future<void> setEnabled(
      MirrorService service, String host, bool enabled) async {
    await _mirrors.setEnabled(service, host, enabled);
    if (_disposed) return;
    await loadService(service);
  }

  Future<void> move(MirrorService service, String host, int delta) async {
    await _mirrors.move(service, host, delta);
    if (_disposed) return;
    await loadService(service);
  }

  /// Probes every service's known mirrors, reloads the lists and returns the
  /// result the page turns into a snackbar. Null means "already testing".
  Future<MirrorLatencyResult?> testLatency() async {
    if (_latencyState.testing || _disposed) return null;

    final views = <InstanceView>[];
    for (final service in serviceOrder) {
      try {
        views.addAll(await _viewsFor(service));
      } catch (_) {
        // A service with no catalogue answer simply has nothing to probe.
      }
    }
    if (_disposed) return null;

    final result = await _latency.test(views);
    if (_disposed) return result;
    await Future.wait([
      for (final service in serviceOrder) loadService(service),
    ]);
    return result;
  }

  Future<List<InstanceView>> _viewsFor(MirrorService service) async {
    final loaded = _instances[service];
    if (loaded != null) return loaded;
    final error = _errors[service];
    if (error != null) throw error;
    await loadService(service);
    final views = _instances[service];
    if (views == null) {
      throw _errors[service] ?? StateError('Mirror list unavailable');
    }
    return views;
  }

  void _onLatencyChanged() {
    _latencyState = _latency.state;
    _notify();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _latency.removeListener(_onLatencyChanged);
    super.dispose();
  }
}
