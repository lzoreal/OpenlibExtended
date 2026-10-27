// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/ui/components/mirror_latency_hint.dart';

Widget _app(Widget child, {double textScale = 1.0}) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: child,
        ),
      ),
    );

void main() {
  testWidgets('shows the hint and action only when requested', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_app(MirrorLatencyHint(
      show: true,
      onTest: () => taps++,
    )));

    expect(
      find.textContaining('Local mirrors have not been tested'),
      findsOneWidget,
    );
    await tester.tap(find.text('Test'));
    expect(taps, 1);

    await tester.pumpWidget(_app(MirrorLatencyHint(
      show: false,
      onTest: () => taps++,
    )));
    expect(find.textContaining('Local mirrors'), findsNothing);
  });

  testWidgets('shows progress instead of the action while testing',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(_app(MirrorLatencyHint(
      show: true,
      testing: true,
      onTest: () => taps++,
    )));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Test'), findsNothing);
    expect(taps, 0);
  });

  testWidgets('does not overflow at 200% text', (tester) async {
    await tester.pumpWidget(_app(
      MirrorLatencyHint(show: true, onTest: () {}),
      textScale: 2.0,
    ));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
