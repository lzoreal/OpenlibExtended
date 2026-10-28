// Real round-trip tests for the backup service: seeded data goes into
// a JSON backup, a fresh database restores from it, and the restored
// rows match. Garbage and future-version files are rejected.

// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Project imports:
import 'package:openlib/data/models/my_book.dart';
import 'package:openlib/data/services/backup_service.dart';
import 'package:openlib/data/services/database.dart';

import 'helpers/fake_path_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    PathProviderPlatform.instance = FakePathProvider('backup');
  });

  Future<void> seedData() async {
    final db = MyLibraryDb.instance;
    final database = await db.database;
    await database.delete('mybooks');
    await database.delete('preferences');
    await database.delete('bookposition');

    await db.insert(MyBook(
      id: 'md5-abc',
      title: 'Backup Roundtrip Book',
      author: 'Author A',
      thumbnail: 'https://example.com/thumb.jpg',
      link: 'https://example.com/book',
      publisher: 'Publisher P',
      info: 'EPUB, 2MB',
      format: 'epub',
      description: 'A book for backup testing',
      fileName: 'Backup Roundtrip Book-abc.epub',
    ));
    await db.savePreference('bookStorageDirectory', '/books');
    await db.savePreference('readerFontSize', '18');
    await db.saveBookState('Backup Roundtrip Book-abc.epub', 'epubcfi(/6/4)');
  }

  test('backup contains every user table and restores into a clean db',
      () async {
    await seedData();

    final service = BackupService(database: MyLibraryDb.instance);
    final json = await service.createBackupJson();

    // Wipe everything a fresh install would not have.
    final database = await MyLibraryDb.instance.database;
    await database.delete('mybooks');
    await database.delete('preferences');
    await database.delete('bookposition');

    expect(await MyLibraryDb.instance.getAll(), isEmpty);

    final restored = await service.restoreBackupJson(json);
    expect(restored, isTrue);

    final books = await MyLibraryDb.instance.getAll();
    expect(books.length, 1);
    final book = books.firstWhere((b) => b.id == 'md5-abc');
    expect(book.title, 'Backup Roundtrip Book');
    expect(book.author, 'Author A');
    expect(book.format, 'epub');
    expect(book.fileName, 'Backup Roundtrip Book-abc.epub');

    expect(await MyLibraryDb.instance.getPreference('readerFontSize'), 18);
    expect(await MyLibraryDb.instance.getPreference('bookStorageDirectory'),
        '/books');
    expect(
        await MyLibraryDb.instance
            .getBookState('Backup Roundtrip Book-abc.epub'),
        'epubcfi(/6/4)');
  });

  test('backup json is versioned and self-describing', () async {
    await seedData();
    final json = await BackupService().createBackupJson();

    final service = BackupService();
    final validated = service.validateBackup(json);
    expect(validated, isNotNull);
    expect(validated!['format'], 'openlib-backup');
    expect(validated['version'], BackupService.formatVersion);
    expect(validated['books'], isA<List<dynamic>>());
  });

  test('rejects garbage, wrong marker and future versions', () async {
    final service = BackupService();

    expect(service.validateBackup('not json at all'), isNull);
    expect(service.validateBackup('{"format": "other-app"}'), isNull);
    expect(
        service.validateBackup('{"format": "openlib-backup", "version": 99}'),
        isNull);

    expect(await service.restoreBackupJson('random text'), isFalse);
  });

  test('file helpers round-trip through disk', () async {
    await seedData();
    final service = BackupService();
    // A clean runner does not have /tmp/openlib_backup_test, and another suite
    // creating /tmp is not a guarantee; own the directory here.
    final dir = await Directory.systemTemp.createTemp('openlib_backup_test');
    addTearDown(() => dir.delete(recursive: true));
    final path =
        '${dir.path}/backup_${DateTime.now().millisecondsSinceEpoch}.json';

    final file = await service.writeBackupFile(path);
    expect(file.existsSync(), isTrue);

    // Wipe and restore from the file.
    final database = await MyLibraryDb.instance.database;
    await database.delete('mybooks');
    expect(await service.restoreBackupFile(path), isTrue);
    expect((await MyLibraryDb.instance.getAll()).length, 1);
  });
}
