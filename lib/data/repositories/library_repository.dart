// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:openlib/data/models/my_book.dart';
import 'package:openlib/data/repositories/preferences_repository.dart';
import 'package:openlib/data/services/database.dart';
import 'package:openlib/data/services/files.dart' show deleteFile;

class LibraryRepository extends ChangeNotifier {
  LibraryRepository({
    MyLibraryDb? database,
    PreferencesRepository? preferences,
  })  : _database = database ?? MyLibraryDb.instance,
        _preferences = preferences ??
            PreferencesRepository(database: database ?? MyLibraryDb.instance);

  final MyLibraryDb _database;
  final PreferencesRepository _preferences;

  Future<List<MyBook>> allBooks() => _database.getAll();

  Future<MyBook?> bookById(String id) => _database.getId(id);

  Future<bool> contains(String id) => _database.checkIdExists(id);

  Future<void> insert(MyBook book) async {
    await _database.insert(book);
    notifyListeners();
  }

  Future<void> deleteBook(String id) async {
    await _database.delete(id);
    notifyListeners();
  }

  /// Drops the record and the downloaded file together. The file goes first
  /// and may be missing: the record must still disappear when the folder or
  /// the file is gone.
  ///
  /// `deleteFileWithDbData` in `data/services/files.dart` still takes a
  /// Riverpod `Ref` for the legacy `deleteFileFromMyLib` bridge, so this
  /// repeats its order without depending on Riverpod.
  Future<void> deleteWithFile(MyBook book) async {
    final directory = await _preferences.bookStorageDirectory();
    if (directory != null) {
      try {
        await deleteFile('$directory/${book.getFileName()}');
      } catch (_) {
        // File manager/file deletion is best-effort; the record still goes.
      }
    }
    await deleteRecord(book);
  }

  /// Removes the book row and its reading-state row, keeping the file.
  Future<void> deleteRecord(MyBook book) async {
    await _database.delete(book.id);
    await _database.deleteBookState(book.getFileName());
    notifyListeners();
  }
}
