// Project imports:
import 'package:openlib/data/models/my_book.dart';
import 'package:openlib/data/services/database.dart';

class LibraryRepository {
  LibraryRepository({MyLibraryDb? database})
      : _database = database ?? MyLibraryDb.instance;

  final MyLibraryDb _database;

  Future<List<MyBook>> allBooks() => _database.getAll();

  Future<MyBook?> bookById(String id) => _database.getId(id);

  Future<bool> contains(String id) => _database.checkIdExists(id);

  Future<void> insert(MyBook book) => _database.insert(book);

  Future<void> deleteBook(String id) => _database.delete(id);
}
