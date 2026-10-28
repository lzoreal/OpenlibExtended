// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/ui/core/filter_options.dart';

void main() {
  group('year filter values', () {
    test('starts at the current year and keeps the fixed range buckets', () {
      final values = yearValuesFor(2026);

      expect(values.first, 'All');
      expect(values[1], '2026');
      expect(values, contains('2015'));
      expect(values, contains('2010-2014'));
      expect(values.last, 'Before 1980');
    });

    test('does not duplicate years or buckets', () {
      final values = yearValuesFor(2030);

      expect(values.toSet().length, values.length);
      expect(values, contains('2030'));
      expect(values, contains('2015'));
      expect(values, isNot(contains('2014')));
    });

    test('keeps the 2025 list shape for older current years', () {
      final values = yearValuesFor(2025);

      expect(values.take(3), ['All', '2025', '2024']);
      expect(values, contains('2015'));
      expect(values, isNot(contains('2026')));
    });

    test('clamps when the system year is before the fixed range', () {
      final values = yearValuesFor(2012);

      expect(values.take(2), ['All', '2015']);
      expect(values, contains('2010-2014'));
    });
  });
}
