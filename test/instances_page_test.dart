// InstancesPage must show the mode the manager will actually apply. The
// regression this pins: the switch defaulted to "automatic" and was only
// ever written by its own handler, so a restart in manual mode displayed
// "Automatic mirror order" (with the reorder arrows hidden) while the
// manager kept using the user's pinned order.

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/data/services/mirror_latency_controller.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/ui/features/instances/view_models/instances_view_model.dart';
import 'package:openlib/ui/features/instances/views/instances_page.dart';

import 'helpers/instances_test_support.dart';

Switch _modeSwitch(WidgetTester tester) =>
    tester.widget<Switch>(find.byType(Switch));

Future<void> _pumpPage(
  WidgetTester tester,
  InstancesMirrorRepository repository,
) async {
  // Tall enough that the mode card below the four (empty) service sections
  // is laid out and tappable without scrolling.
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final latency = MirrorLatencyNotifier(repository);
  final viewModel = InstancesViewModel(mirrors: repository, latency: latency);
  addTearDown(latency.dispose);
  addTearDown(viewModel.dispose);
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: InstancesPage(viewModel: viewModel),
  ));
}

void main() {
  group('mode switch hydration', () {
    testWidgets('shows the persisted manual mode after a restart',
        (tester) async {
      // Manual mode was stored by an earlier run.
      final repository = InstancesMirrorRepository(autoMode: false);

      await _pumpPage(tester, repository);
      await tester.pump(); // build + initState kick-off
      await tester.pump(); // persisted mode applied

      expect(_modeSwitch(tester).value, isFalse,
          reason: 'manual mode must show as manual, not as automatic');
    });

    testWidgets('stays on automatic when that is the stored mode',
        (tester) async {
      await _pumpPage(tester, InstancesMirrorRepository());
      await tester.pump();
      await tester.pump();

      expect(_modeSwitch(tester).value, isTrue);
    });

    testWidgets('flipping the switch persists the mode', (tester) async {
      final repository = InstancesMirrorRepository();
      await _pumpPage(tester, repository);
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(repository.autoMode, isFalse);
      expect(_modeSwitch(tester).value, isFalse);
    });
  });
}
