// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/data/services/update_checker.dart';

void main() {
  group('shouldCheckUpdatesAtStartup', () {
    test('missing or enabled values keep checking', () {
      expect(shouldCheckUpdatesAtStartup(null), isTrue);
      expect(shouldCheckUpdatesAtStartup(1), isTrue);
      expect(shouldCheckUpdatesAtStartup('1'), isTrue);
      expect(shouldCheckUpdatesAtStartup(true), isTrue);
    });

    test('disabled values skip the startup check', () {
      expect(shouldCheckUpdatesAtStartup(0), isFalse);
      expect(shouldCheckUpdatesAtStartup(false), isFalse);
    });
  });
}
