// The WeLib waiter reports the page's countdown; the parsing is the only
// part that can be tested without a real webview.

// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/data/services/download_page_waiter.dart';

void main() {
  test('reads the seconds out of the countdown element', () {
    expect(countdownSecondsFrom('12'), 12);
    expect(countdownSecondsFrom('12s'), 12);
    expect(countdownSecondsFrom(' 3 '), 3);
  });

  test('ignores missing or implausible values', () {
    expect(countdownSecondsFrom(null), isNull);
    expect(countdownSecondsFrom(''), isNull);
    expect(countdownSecondsFrom('soon'), isNull);
    expect(countdownSecondsFrom('999'), isNull);
  });
}
