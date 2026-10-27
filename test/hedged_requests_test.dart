import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/services/hedged_requests.dart';

void main() {
  test('returns the first winner and never launches the rest', () async {
    var secondStarted = false;
    final result = await hedgeFirst<int>(
      [
        () async => 1,
        () async {
          secondStarted = true;
          return 2;
        },
      ],
      stagger: const Duration(milliseconds: 40),
    );

    expect(result, 1);
    await Future<void>.delayed(const Duration(milliseconds: 120));
    expect(secondStarted, isFalse);
  });

  test('a failing first attempt hands over to the staggered second', () async {
    final startedAt = DateTime.now();
    final result = await hedgeFirst<int>(
      [
        () async => null,
        () async => 2,
      ],
      stagger: const Duration(milliseconds: 40),
    );

    expect(result, 2);
    expect(
      DateTime.now().difference(startedAt),
      greaterThanOrEqualTo(const Duration(milliseconds: 35)),
    );
  });

  test('returns null when every attempt comes back empty', () async {
    final result = await hedgeFirst<int>(
      [() async => null, () async => throw Exception('down')],
      stagger: const Duration(milliseconds: 20),
    );

    expect(result, isNull);
  });

  test('tries only the hedged window without touching the tail', () async {
    final started = <int>[];
    final result = await hedgeFirst<int>(
      [
        for (var i = 0; i < 4; i++)
          () async {
            started.add(i);
            return null;
          },
      ],
      stagger: const Duration(milliseconds: 20),
    );

    expect(result, isNull);
    expect(started, [0, 1]);
  });
}
