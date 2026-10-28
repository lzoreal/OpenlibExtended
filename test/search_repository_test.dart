// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Project imports:
import 'package:openlib/data/models/book_data.dart';
import 'package:openlib/data/models/search_result.dart';
import 'package:openlib/data/repositories/search_repository.dart';
import 'package:openlib/data/services/search_manager.dart';

import 'helpers/fake_path_provider.dart';

class _FakeProvider implements SearchProvider {
  _FakeProvider(this.id, this.books, {this.failure});

  @override
  final SearchProviderId id;
  @override
  String get displayName => id.name;

  final List<BookData> books;
  final Object? failure;

  @override
  Future<bool> locallyUnreachable() async => false;

  @override
  Future<List<BookData>> search(SearchQuery query) async {
    if (failure != null) throw failure!;
    return books;
  }
}

BookData _book(String md5) => BookData(
      title: md5,
      link: 'https://example.com/$md5',
      md5: md5,
    );

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    PathProviderPlatform.instance = FakePathProvider('search_repository');
  });

  test('search merges sources and reports the failing one', () async {
    final repository = SearchRepository(
      manager: SearchManager(providers: [
        _FakeProvider(SearchProviderId.libgen, [_book('a')]),
        _FakeProvider(SearchProviderId.zlibrary, [_book('b')]),
        _FakeProvider(SearchProviderId.welib, const [],
            failure: Exception('boom')),
      ]),
    );

    final result = await repository.search(const SearchQuery(text: 'docker'));

    expect(result.books.map((b) => b.md5), containsAll(['a', 'b']));
    expect(result.failedProviders, contains('welib'));
  });

  test('watch emits the merged page', () async {
    final repository = SearchRepository(
      manager: SearchManager(providers: [
        _FakeProvider(SearchProviderId.libgen, [_book('a')]),
      ]),
    );

    final result =
        await repository.watch(const SearchQuery(text: 'docker')).first;

    expect(result.books.map((b) => b.md5), ['a']);
  });
}
