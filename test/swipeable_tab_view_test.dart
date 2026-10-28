// A careful (short, slow) swipe must still switch tabs: the stock
// TabBarView springs back unless the drag covers half a page or ends in a
// fling, which made the first swipe look ignored.

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/ui/core/components/swipeable_tab_view.dart';

class _Host extends StatefulWidget {
  const _Host();

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> with SingleTickerProviderStateMixin {
  late final TabController controller = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            height: 400,
            child: SwipeableTabView(
              controller: controller,
              children: const [
                ColoredBox(color: Colors.red),
                ColoredBox(color: Colors.blue),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('a short slow swipe still switches', (tester) async {
    await tester.pumpWidget(const _Host());
    await tester.pumpAndSettle();

    // 80 of 400 px: 20% of the page, below the stock half-page snap.
    await tester.drag(find.byType(SwipeableTabView), const Offset(-80, 0));
    await tester.pumpAndSettle();

    final controller = tester
        .state<_HostState>(find.byType(_Host))
        .controller;
    expect(controller.index, 1);
  });

  testWidgets('a tiny drag stays on the page', (tester) async {
    await tester.pumpWidget(const _Host());
    await tester.pumpAndSettle();

    await tester.drag(find.byType(SwipeableTabView), const Offset(-20, 0));
    await tester.pumpAndSettle();

    final controller = tester
        .state<_HostState>(find.byType(_Host))
        .controller;
    expect(controller.index, 0);
  });
}
