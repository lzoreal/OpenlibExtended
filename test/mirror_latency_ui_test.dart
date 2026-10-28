// The mirror page's latency control: one manual run, a separate local
// latency line per card, and no probes for disabled or DOWN mirrors.

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/data/services/instance_manager.dart';
import 'package:openlib/data/services/preference_store.dart';
import 'package:openlib/data/services/slum_catalogue.dart';
import 'package:openlib/state/state.dart';
import 'package:openlib/ui/instances_page.dart';

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
  int? latency = 320,
  Protection protection = Protection.none,
}) =>
    InstanceView(
      site: SlumSite(
        service: MirrorService.zlibrary,
        url: 'https://$host',
        host: host,
        status: status,
        protection: protection,
        latencyMs: latency,
      ),
      enabled: enabled,
    );

String _localText(WidgetTester tester, String host) {
  final text = tester.widget<Text>(find.descendant(
    of: find.byKey(ValueKey('mirror-local-latency-$host')),
    matching: find.byType(Text),
  ));
  return text.data!;
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required InstanceManager manager,
  required List<InstanceView> views,
  required MirrorLatencyMeasure measure,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(ProviderScope(
    overrides: [
      instanceManagerProvider.overrideWithValue(manager),
      serviceInstancesProvider.overrideWith(
        (ref, service) async =>
            service == MirrorService.zlibrary ? views : const <InstanceView>[],
      ),
      mirrorLatencyProvider.overrideWith(
        (ref) => MirrorLatencyNotifier(manager, measure),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const InstancesPage(),
    ),
  ));
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('probes only enabled, non-down mirrors and shows the result',
      (tester) async {
    final store = MemoryPreferenceStore();
    final manager = _manager(store);
    final completer = Completer<Map<String, int?>>();
    final requested = <String>[];

    await _pumpPage(
      tester,
      manager: manager,
      views: [
        _view('z-lib.gd'),
        _view('z-lib.gl', enabled: false),
        _view('down.example', status: SlumStatus.down),
      ],
      measure: (urls) {
        requested.addAll(urls);
        return completer.future;
      },
    );

    expect(_localText(tester, 'z-lib.gd'), 'Local latency not tested');
    expect(
      find.byKey(const ValueKey('mirror-latency-test')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('mirror-latency-test')));
    await tester.pump();
    await tester.pump();

    expect(requested, ['https://z-lib.gd']);
    expect(_localText(tester, 'z-lib.gd'), 'Testing local latency…');

    completer.complete({'z-lib.gd': 85});
    await tester.pumpAndSettle();

    expect(_localText(tester, 'z-lib.gd'), 'Local 85 ms · just now');
    expect(
      (await manager.localLatencies())['z-lib.gd']?.milliseconds,
      85,
    );
    expect(
      find.text('Local test: 1/1 reachable, fastest 85 ms'),
      findsOneWidget,
    );
  });

  testWidgets('marks protected mirrors as needing verification',
      (tester) async {
    final store = MemoryPreferenceStore();
    final manager = _manager(store);
    await manager.saveLocalLatencies({'z-lib.gd': 85});

    await _pumpPage(
      tester,
      manager: manager,
      views: [
        _view('z-lib.gd', protection: Protection.cloudflare),
      ],
      measure: (urls) async => <String, int?>{},
    );

    expect(_localText(tester, 'z-lib.gd'),
        'Local 85 ms · needs verification · just now');
  });

  testWidgets('shows a timeout as a tested local result', (tester) async {
    final store = MemoryPreferenceStore();
    final manager = _manager(store);

    await _pumpPage(
      tester,
      manager: manager,
      views: [_view('z-lib.gd')],
      measure: (urls) async => {'z-lib.gd': null},
    );

    await tester.tap(find.byKey(const ValueKey('mirror-latency-test')));
    await tester.pumpAndSettle();

    expect(_localText(tester, 'z-lib.gd'), 'Local timeout');
    expect(
      find.text('Local test finished · no mirror responded'),
      findsOneWidget,
    );
  });

  testWidgets('marks a reading older than 24 hours as expired', (tester) async {
    final store = MemoryPreferenceStore();
    final manager = _manager(store);
    await manager.saveLocalLatencies(
      {'z-lib.gd': 120},
      testedAt: DateTime.now().subtract(const Duration(hours: 25)),
    );

    await _pumpPage(
      tester,
      manager: manager,
      views: [_view('z-lib.gd')],
      measure: (urls) async => {'z-lib.gd': 85},
    );

    expect(_localText(tester, 'z-lib.gd'), 'Local 120 ms · expired');
  });

  testWidgets('explains that there is nothing enabled to test', (tester) async {
    final store = MemoryPreferenceStore();
    final manager = _manager(store);
    var called = false;

    await _pumpPage(
      tester,
      manager: manager,
      views: [
        _view('z-lib.gl', enabled: false),
        _view('down.example', status: SlumStatus.down),
      ],
      measure: (urls) async {
        called = true;
        return <String, int?>{};
      },
    );

    await tester.tap(find.byKey(const ValueKey('mirror-latency-test')));
    await tester.pumpAndSettle();

    expect(called, isFalse);
    expect(find.text('No enabled mirrors to test'), findsOneWidget);
  });

  testWidgets('reports a failed probe without leaving the page spinning',
      (tester) async {
    final store = MemoryPreferenceStore();
    final manager = _manager(store);

    await _pumpPage(
      tester,
      manager: manager,
      views: [_view('z-lib.gd')],
      measure: (urls) async => throw StateError('boom'),
    );

    await tester.tap(find.byKey(const ValueKey('mirror-latency-test')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Local test failed:'), findsOneWidget);
    expect(_localText(tester, 'z-lib.gd'), 'Local latency not tested');
  });
}
