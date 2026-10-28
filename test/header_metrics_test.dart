import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/ui/core/components/page_header.dart';
import 'package:openlib/ui/core/components/pill_tabs.dart';
import 'package:openlib/ui/core/components/section_header.dart';
import 'package:openlib/ui/core/themes.dart';

void main() {
  testWidgets('page header uses 16/16/16/12 and a 26/32 title', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: PageHeader(eyebrow: 'EYEBROW', title: 'Title'),
      ),
    ));

    final title = tester.widget<Text>(find.text('Title'));
    expect(title.style!.fontSize, 26);
    expect(title.style!.height, closeTo(32 / 26, 0.0001));

    final eyebrow = tester.widget<Text>(find.text('EYEBROW'));
    expect(eyebrow.style!.fontSize, 10);
    expect(eyebrow.style!.letterSpacing, closeTo(1.5, 0.001));

    final pad = tester.widget<Padding>(
      find
          .ancestor(
            of: find.text('Title'),
            matching: find.byType(Padding),
          )
          .first,
    );
    expect(pad.padding, const EdgeInsets.fromLTRB(16, 16, 16, 12));
  });

  testWidgets('section header uses a 13/20 title and 11/16 hint',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 320,
            child: SectionHeader(title: 'Section', hint: '12'),
          ),
        ),
      ),
    ));

    final title = tester.widget<Text>(find.text('Section'));
    expect(title.style!.fontSize, 13);
    expect(title.style!.height, closeTo(20 / 13, 0.0001));
    expect(title.style!.fontWeight, FontWeight.w800);

    final hint = tester.widget<Text>(find.text('12'));
    expect(hint.style!.fontSize, 11);
    expect(hint.style!.height, closeTo(16 / 11, 0.0001));
    expect(tester.getTopRight(find.text('12')).dx, closeTo(320, 0.1));

    final pad = tester.widget<Padding>(
      find
          .ancestor(
            of: find.text('Section'),
            matching: find.byType(Padding),
          )
          .first,
    );
    expect(pad.padding, const EdgeInsets.fromLTRB(0, 16, 0, 8));
  });

  testWidgets('section header hint fits at 200% text scale', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: const Scaffold(
          body: SizedBox(
            width: 390,
            child: SectionHeader(
              title: 'Completed',
              hint:
                  'Tap a title for details · tap open for the external reader',
            ),
          ),
        ),
      ),
    ));

    expect(tester.takeException(), isNull);
  });

  testWidgets('section header action sits on the right edge', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 320,
            child: SectionHeader(
              title: 'Recent searches',
              action: Text('Clear all'),
            ),
          ),
        ),
      ),
    ));

    expect(tester.getTopRight(find.text('Clear all')).dx, closeTo(320, 0.1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('pill tab track is 44 high', (tester) async {
    final controller = TabController(length: 2, vsync: const TestVSync());
    addTearDown(controller.dispose);

    await tester.pumpWidget(MaterialApp(
      theme: lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: PillTabs(
          controller: controller,
          tabs: const [Tab(text: 'One'), Tab(text: 'Two')],
        ),
      ),
    ));

    expect(
      tester.getSize(find.byKey(const ValueKey('pill-tabs-track'))).height,
      44,
    );
    final label = tester.widget<TabBar>(find.byType(TabBar)).labelStyle;
    expect(label!.fontSize, 12);
    expect(label.height, closeTo(20 / 12, 0.0001));
    expect(label.fontWeight, FontWeight.w800);
  });

  testWidgets('pill tab track grows and scrolls at 200% text scale',
      (tester) async {
    final controller = TabController(length: 4, vsync: const TestVSync());
    addTearDown(controller.dispose);

    await tester.pumpWidget(MaterialApp(
      theme: lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: Scaffold(
          body: PillTabs(
            controller: controller,
            tabs: const [
              Tab(text: 'One'),
              Tab(text: 'Two'),
              Tab(text: 'Three'),
              Tab(text: 'Four'),
            ],
          ),
        ),
      ),
    ));

    expect(
      tester.getSize(find.byKey(const ValueKey('pill-tabs-track'))).height,
      48,
    );
    expect(tester.widget<TabBar>(find.byType(TabBar)).isScrollable, isTrue);
  });
}
