// The latency controller decides what gets probed and persists the run.
// It is tested without widgets so the enabled/down filtering, in-flight
// state and persistence merge are pinned independently of the page.

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/data/services/instance_manager.dart';
import 'package:openlib/data/services/mirror_latency.dart';
import 'package:openlib/data/services/preference_store.dart';
import 'package:openlib/data/services/slum_catalogue.dart';
import 'package:openlib/state/state.dart';

InstanceManager _manager(MemoryPreferenceStore store) =>
    InstanceManager.forTest(
      catalogue: SlumCatalogue(
        store: store,
        baseUrl: 'http://127.0.0.1:9',
      ),
      store: store,
    );

InstanceView _view(
  String host, {
  bool enabled = true,
  SlumStatus status = SlumStatus.up,
}) =>
    InstanceView(
      site: SlumSite(
        service: MirrorService.zlibrary,
        url: 'https://$host',
        host: host,
        status: status,
        protection: Protection.none,
      ),
      enabled: enabled,
    );

void main() {
  test('load exposes persisted readings', () async {
    final store = MemoryPreferenceStore();
    final manager = _manager(store);
    await manager.saveLocalLatencies({'a.com': 85});

    final notifier = MirrorLatencyNotifier(
      manager,
      (urls) async => <String, int?>{},
    );
    await notifier.load();

    expect(notifier.state.readings['a.com']?.milliseconds, 85);
    expect(notifier.state.loaded, isTrue);
  });

  test('hint shows only after loading and without fresh readings', () async {
    final now = DateTime(2026, 10, 28, 12);
    final fresh = MirrorLatencyReading(
        milliseconds: 85, testedAt: now.subtract(const Duration(hours: 1)));
    final expired = MirrorLatencyReading(
        milliseconds: 85, testedAt: now.subtract(const Duration(hours: 25)));

    expect(
      shouldShowMirrorLatencyHint(const MirrorLatencyState(), now),
      isFalse,
      reason: 'the notifier has not loaded yet',
    );
    expect(
      shouldShowMirrorLatencyHint(
          const MirrorLatencyState(loaded: true), now),
      isTrue,
    );
    expect(
      shouldShowMirrorLatencyHint(
        MirrorLatencyState(loaded: true, readings: {'a.com': fresh}),
        now,
      ),
      isFalse,
    );
    expect(
      shouldShowMirrorLatencyHint(
        MirrorLatencyState(loaded: true, readings: {'a.com': expired}),
        now,
      ),
      isTrue,
    );
    expect(
      shouldShowMirrorLatencyHint(
        const MirrorLatencyState(loaded: true, testing: true),
        now,
      ),
      isTrue,
      reason: 'the hint stays in place to show test progress',
    );
  });

  test('measures only enabled, non-down hosts', () async {
    final store = MemoryPreferenceStore();
    final manager = _manager(store);
    List<String>? requested;
    final notifier = MirrorLatencyNotifier(manager, (urls) async {
      requested = urls.toList();
      return {'a.com': 85};
    });

    final result = await notifier.test([
      _view('a.com'),
      _view('b.com', enabled: false),
      _view('c.com', status: SlumStatus.down),
    ]);

    expect(requested, ['https://a.com']);
    expect(result.total, 1);
    expect(result.reachable, 1);
    expect(result.fastestMs, 85);
    expect(notifier.state.testing, isFalse);
    expect(notifier.state.loaded, isTrue);
    expect((await manager.localLatencies())['a.com']?.milliseconds, 85);
  });

  test('exposes in-flight hosts while the probe is running', () async {
    final store = MemoryPreferenceStore();
    final manager = _manager(store);
    final completer = Completer<Map<String, int?>>();
    final notifier = MirrorLatencyNotifier(
      manager,
      (urls) => completer.future,
    );

    final running = notifier.test([_view('a.com'), _view('b.com')]);
    await Future<void>.delayed(Duration.zero);

    expect(notifier.state.testing, isTrue);
    expect(notifier.state.testingHosts, {'a.com', 'b.com'});

    completer.complete({'a.com': 85});
    await running;

    expect(notifier.state.testing, isFalse);
    expect(notifier.state.testingHosts, isEmpty);
  });

  test('does not probe when every mirror is disabled or down', () async {
    final store = MemoryPreferenceStore();
    final manager = _manager(store);
    var called = false;
    final notifier = MirrorLatencyNotifier(manager, (urls) async {
      called = true;
      return <String, int?>{};
    });

    final result = await notifier.test([
      _view('a.com', enabled: false),
      _view('b.com', status: SlumStatus.down),
    ]);

    expect(called, isFalse);
    expect(result.total, 0);
    expect(result.reachable, 0);
    expect(result.fastestMs, isNull);
  });

  test('persists a timeout as a tested host', () async {
    final store = MemoryPreferenceStore();
    final manager = _manager(store);
    final notifier = MirrorLatencyNotifier(
      manager,
      (urls) async => {'a.com': null},
    );

    final result = await notifier.test([_view('a.com')]);

    expect(result.reachable, 0);
    expect(result.fastestMs, isNull);
    expect((await manager.localLatencies())['a.com']?.milliseconds, isNull);
  });

  test('keeps earlier readings for hosts outside this run', () async {
    final store = MemoryPreferenceStore();
    final manager = _manager(store);
    await manager.saveLocalLatencies({'b.com': 50});
    final notifier = MirrorLatencyNotifier(
      manager,
      (urls) async => {'a.com': 85},
    );

    await notifier.test([_view('a.com')]);
    final readings = await manager.localLatencies();

    expect(readings['a.com']?.milliseconds, 85);
    expect(readings['b.com']?.milliseconds, 50);
  });
}
