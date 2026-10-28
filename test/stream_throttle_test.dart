import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/data/services/stream_throttle.dart';

void main() {
  test('coalesces a burst and keeps the latest value', () async {
    final source = StreamController<int>();
    final seen = <int>[];
    final first = Completer<void>();
    final trailing = Completer<void>();
    final subscription = throttleLatest(
      source.stream,
      const Duration(milliseconds: 150),
    ).listen((value) {
      seen.add(value);
      if (seen.length == 1) first.complete();
      if (seen.length == 2) trailing.complete();
    });
    addTearDown(() {
      subscription.cancel();
      source.close();
    });

    source.add(1);
    await first.future.timeout(const Duration(seconds: 2));
    expect(seen, [1]);

    // Both values fall inside the open window: only the last survives.
    source.add(2);
    source.add(3);
    await trailing.future.timeout(const Duration(seconds: 2));
    expect(seen, [1, 3]);
  });

  test('flushes the last value before the stream ends', () async {
    final source = StreamController<int>();
    final seen = <int>[];
    final first = Completer<void>();
    final done = Completer<void>();
    final subscription = throttleLatest(
      source.stream,
      const Duration(milliseconds: 150),
    ).listen(
      (value) {
        seen.add(value);
        if (seen.length == 1) first.complete();
      },
      onDone: done.complete,
    );
    addTearDown(() {
      subscription.cancel();
      source.close();
    });

    source.add(1);
    await first.future.timeout(const Duration(seconds: 2));
    source.add(2);
    await source.close();
    await done.future.timeout(const Duration(seconds: 2));

    expect(seen, [1, 2]);
  });
}
