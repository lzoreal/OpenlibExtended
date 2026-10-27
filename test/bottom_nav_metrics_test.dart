import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/ui/components/bottom_nav_bar.dart';
import 'package:openlib/ui/themes.dart';

void main() {
  testWidgets('bottom navigation is 72 tall with a 56x32 indicator',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        bottomNavigationBar: BottomNavBar(
          selectedIndex: 0,
          onSelected: (_) {},
          downloadCount: 0,
        ),
      ),
    ));

    final bar = find.byType(BottomNavBar);
    expect(tester.getSize(bar).height, 72);
    final pill = find.byKey(const ValueKey('nav-indicator')).first;
    expect(tester.getSize(pill), const Size(56, 32));
    final label = tester
        .widget<AnimatedDefaultTextStyle>(
          find.byKey(const ValueKey('nav-label')).first,
        )
        .style;
    expect(label.fontSize, 10);
    expect(label.height, closeTo(16 / 10, 0.0001));
    expect(label.fontWeight, FontWeight.w700);
  });
}
