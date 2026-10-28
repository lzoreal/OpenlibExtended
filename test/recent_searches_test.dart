// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/data/services/recent_searches.dart';

class _MemoryStore implements RecentSearchStore {
  _MemoryStore([List<String> initial = const []])
      : stored = List<String>.of(initial);

  List<String> stored;
  List<String> saved = const [];
  int saves = 0;

  @override
  Future<List<String>> load() async => List<String>.of(stored);

  @override
  Future<void> save(List<String> searches) async {
    stored = List<String>.of(searches);
    saved = List<String>.of(searches);
    saves++;
  }
}

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

  test('the notifier loads and persists mutations', () async {
    final store = _MemoryStore(['Dune', 'Emma']);
    final notifier = RecentSearchesNotifier(store: store);

    await notifier.ready;
    expect(notifier.state, ['Dune', 'Emma']);

    notifier.record('Hyperion');
    await Future<void>.delayed(Duration.zero);
    expect(notifier.state, ['Hyperion', 'Dune', 'Emma']);
    expect(store.saved, ['Hyperion', 'Dune', 'Emma']);

    notifier.remove('Dune');
    await Future<void>.delayed(Duration.zero);
    expect(notifier.state, ['Hyperion', 'Emma']);
    expect(store.saved, ['Hyperion', 'Emma']);

    notifier.clear();
    await Future<void>.delayed(Duration.zero);
    expect(notifier.state, isEmpty);
    expect(store.stored, isEmpty);
  });

  test('a store failure does not throw or lose the current list', () async {
    final store = _MemoryStore(['Dune']);
    final notifier = RecentSearchesNotifier(store: store);
    await notifier.ready;

    notifier.record('Emma');
    await Future<void>.delayed(Duration.zero);
    expect(notifier.state, ['Emma', 'Dune']);
  });
}
