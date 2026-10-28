import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/main.dart' show switchToTab;

class _Probe extends StatefulWidget {
  const _Probe({required this.index, required this.inits});

  final int index;
  final List<int> inits;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  void initState() {
    super.initState();
    widget.inits.add(widget.index);
  }

  @override
  Widget build(BuildContext context) =>
      Center(child: Text('page ${widget.index}'));
}

void main() {
  Future<PageController> pumpPages(WidgetTester tester, List<int> inits) async {
    final controller = PageController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      home: PageView(
        controller: controller,
        children: [
          for (var i = 0; i < 4; i++) _Probe(index: i, inits: inits),
        ],
      ),
    ));
    return controller;
  }

  testWidgets('a tap that skips pages jumps without building the ones between',
      (tester) async {
    final inits = <int>[];
    final controller = await pumpPages(tester, inits);
    expect(inits, [0]);

    switchToTab(controller, 3);
    await tester.pump();

    // At the destination immediately, and the passed-over pages were never
    // built - that build used to stall the first tap.
    expect(controller.page, 3);
    expect(inits, [0, 3]);
  });

  testWidgets('a cold target jumps even when it is next door', (tester) async {
    final inits = <int>[];
    final controller = await pumpPages(tester, inits);

    switchToTab(controller, 1, visited: {0});
    await tester.pump();

    expect(controller.page, 1);
    expect(inits, [0, 1]);
  });

  testWidgets('a neighbouring tab tap slides too', (tester) async {
    final inits = <int>[];
    final controller = await pumpPages(tester, inits);

    switchToTab(controller, 1, visited: {0, 1});
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(controller.page, greaterThan(0));
    expect(controller.page, lessThan(1));

    await tester.pump(const Duration(milliseconds: 300));
    expect(controller.page, 1);
    expect(inits, [0, 1]);
  });
}
