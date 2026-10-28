// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Project imports:
import 'package:openlib/data/models/my_book.dart';
import 'package:openlib/data/repositories/library_repository.dart';

import 'helpers/fake_path_provider.dart';

void main() {
  final paths = FakePathProvider('library_repository');

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    PathProviderPlatform.instance = paths;
  });

  MyBook book(String id) => MyBook(
        id: id,
        title: 'Title $id',
        author: 'Author',
        thumbnail: '',
        link: '',
        publisher: '',
        info: '',
        format: 'epub',
        description: '',
      );

  test('insert, contains, bookById and deleteBook round-trip', () async {
    final repository = LibraryRepository();
    await repository.deleteBook('lib-repo-1');

    expect(await repository.contains('lib-repo-1'), isFalse);

    await repository.insert(book('lib-repo-1'));

    expect(await repository.contains('lib-repo-1'), isTrue);
    expect((await repository.bookById('lib-repo-1'))?.title, 'Title lib-repo-1');
    expect(
      (await repository.allBooks()).map((b) => b.id),
      contains('lib-repo-1'),
    );

    await repository.deleteBook('lib-repo-1');
    expect(await repository.contains('lib-repo-1'), isFalse);
  });
}
