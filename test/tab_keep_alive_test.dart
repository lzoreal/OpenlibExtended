import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/ui/core/components/tab_keep_alive.dart';

class _Probe extends StatefulWidget {
  const _Probe({required this.index, required this.inits});

  final int index;
  final List<int> inits;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  bool _active = true;

  @override
  void initState() {
    super.initState();
    widget.inits.add(widget.index);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _active = TabVisibility.of(context);
  }

  @override
  Widget build(BuildContext context) =>
      Center(child: Text('page ${widget.index} $_active'));
}

void main() {
  testWidgets('keeps a page mounted while another tab is selected',
      (tester) async {
    final inits = <int>[];
    final selected = ValueNotifier<int>(0);
    addTearDown(selected.dispose);
    final controller = PageController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(MaterialApp(
      home: ValueListenableBuilder<int>(
        valueListenable: selected,
        builder: (context, index, _) => PageView(
          controller: controller,
          children: [
            for (var i = 0; i < 3; i++)
              TabKeepAlive(
                active: i == index,
                child: _Probe(index: i, inits: inits),
              ),
          ],
        ),
      ),
    ));

    expect(inits, [0]);
    expect(
      find.descendant(
        of: find.byType(TabKeepAlive),
        matching: find.byType(RepaintBoundary),
      ),
      findsWidgets,
    );

    controller.jumpToPage(2);
    selected.value = 2;
    await tester.pump();
    expect(inits, [0, 2]);
    // The off-screen page is still in the tree and already knows it is
    // hidden; it is just not painted.
    expect(
      find.text('page 0 false', skipOffstage: false),
      findsOneWidget,
    );

    controller.jumpToPage(0);
    selected.value = 0;
    await tester.pump();
    // Page 0 kept its state: it was never initialised a second time.
    expect(inits, [0, 2]);
    expect(find.text('page 0 true'), findsOneWidget);
  });

  testWidgets('tab visibility notifies its dependents', (tester) async {
    Widget page(bool active) => MaterialApp(
          home: TabVisibility(
            active: active,
            child: Builder(
              builder: (context) => Text('active ${TabVisibility.of(context)}'),
            ),
          ),
        );

    await tester.pumpWidget(page(true));
    expect(find.text('active true'), findsOneWidget);

    await tester.pumpWidget(page(false));
    expect(find.text('active false'), findsOneWidget);
  });
}
