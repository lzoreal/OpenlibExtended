// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Project imports:
import 'package:openlib/data/services/database.dart';

import 'helpers/fake_path_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    PathProviderPlatform.instance = FakePathProvider('book_state');
  });

  setUp(() async {
    final database = await MyLibraryDb.instance.database;
    await database.delete('bookposition');
  });

  test('saving a position keeps the completed flag', () async {
    final db = MyLibraryDb.instance;
    const fileName = 'state-test.epub';

    await db.saveBookState(fileName, 'epubcfi(/6/4)');
    await db.setCompleted(fileName, true);
    await db.saveBookState(fileName, 'epubcfi(/6/8)');

    expect(await db.getBookState(fileName), 'epubcfi(/6/8)');
    expect(await db.isCompleted(fileName), isTrue);
  });

  test('marking completed keeps the saved position', () async {
    final db = MyLibraryDb.instance;
    const fileName = 'state-test-2.epub';

    await db.saveBookState(fileName, 'epubcfi(/6/10)');
    await db.setCompleted(fileName, true);

    expect(await db.getBookState(fileName), 'epubcfi(/6/10)');

    await db.setCompleted(fileName, false);
    expect(await db.getBookState(fileName), 'epubcfi(/6/10)');
    expect(await db.isCompleted(fileName), isFalse);
  });
}
