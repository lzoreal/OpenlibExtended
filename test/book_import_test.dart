// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Project imports:
import 'package:openlib/services/database.dart';
import 'package:openlib/ui/settings_page.dart' show scanAndImportBooks;

import 'helpers/fake_path_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      PathProviderPlatform.instance = FakePathProvider('import');
    }
  });

  testWidgets('imports every supported format and skips other files',
      (tester) async {
    final directory = Directory.systemTemp.createTempSync('openlib_import');
    addTearDown(() => directory.deleteSync(recursive: true));

    const imported = [
      'epub',
      'pdf',
      'mobi',
      'azw3',
      'azw',
      'fb2',
      'djvu',
      'txt',
      'cbr',
      'cbz',
    ];
    for (final format in imported) {
      File('${directory.path}/openlib-format-test-$format.$format')
          .writeAsBytesSync(List.filled(16, 1));
    }
    File('${directory.path}/openlib-format-test-docx.docx')
        .writeAsBytesSync(List.filled(16, 1));
    File('${directory.path}/openlib-format-test-cover.jpg')
        .writeAsBytesSync(List.filled(16, 1));

    final db = MyLibraryDb.instance;
    final importedIds = [
      for (final format in imported) 'openlib-format-test-$format',
    ];
    final cleanup = [...importedIds, 'openlib-format-test-docx'];

    late WidgetRef ref;
    await tester.pumpWidget(ProviderScope(
      child: Consumer(builder: (context, widgetRef, child) {
        ref = widgetRef;
        return const SizedBox();
      }),
    ));

    // sqflite FFI does real I/O, which only completes inside runAsync in a
    // widget test.
    await tester.runAsync(() async {
      for (final id in cleanup) {
        await db.delete(id);
      }
      await scanAndImportBooks(directory.path, db, ref);
      for (final id in importedIds) {
        expect(await db.checkIdExists(id), isTrue,
            reason: '$id must be imported');
      }
      expect(await db.checkIdExists('openlib-format-test-docx'), isFalse,
          reason: 'unsupported formats are not imported');
      expect(await db.checkIdExists('openlib-format-test-cover'), isFalse,
          reason: 'non-book files are not imported');
      for (final id in cleanup) {
        await db.delete(id);
      }
    });
  });
}
