// Dart imports:
import 'dart:io';

// Project imports:
import 'package:openlib/services/book_format.dart';
import 'package:openlib/services/database.dart';

/// Scans a directory for book files and registers the ones the library does
/// not know yet. Returns how many rows were added so the caller can refresh
/// its providers.
Future<int> importBooksFromDirectory(
    String directoryPath, MyLibraryDb database) async {
  try {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) return 0;

    final files = directory.listSync(recursive: false);
    int importedCount = 0;

    for (var entity in files) {
      if (entity is File) {
        final fileName = entity.path.split(Platform.pathSeparator).last;
        final extension = fileName.split('.').last.toLowerCase();

        if (isSupportedBookFormat(extension)) {
          // The filename before the extension is the md5 the app stores.
          final parts = fileName.split('.');
          if (parts.length >= 2) {
            final md5 = parts.sublist(0, parts.length - 1).join('.');

            final exists = await database.checkIdExists(md5);
            if (!exists) {
              final book = MyBook(
                id: md5,
                title: md5,
                author: "Unknown",
                thumbnail: "",
                link: "",
                publisher: "",
                info: "",
                description: "",
                format: extension,
              );
              await database.insert(book);
              importedCount++;
            }
          }
        }
      }
    }

    return importedCount;
  } catch (e) {
    // Never interrupt the user flow for a scan failure.
    return 0;
  }
}
