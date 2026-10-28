// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/data/services/recent_searches.dart';

void main() {
  test('record trims, dedupes case-insensitively and moves to the front', () {
    expect(withRecentSearch(const [], '  Dune '), ['Dune']);
    expect(withRecentSearch(const ['Dune', 'Emma'], 'dune'), ['dune', 'Emma']);
    expect(withRecentSearch(const ['Dune', 'Emma'], 'Hyperion'),
        ['Hyperion', 'Dune', 'Emma']);
  });

  test('record keeps at most six searches', () {
    var list = <String>[];
    for (final query in ['a', 'b', 'c', 'd', 'e', 'f', 'g']) {
      list = withRecentSearch(list, query);
    }
    expect(list, ['g', 'f', 'e', 'd', 'c', 'b']);
  });

  test('empty queries are ignored', () {
    expect(withRecentSearch(const ['Dune'], '   '), ['Dune']);
  });
}
