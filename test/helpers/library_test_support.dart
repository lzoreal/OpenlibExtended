// Dart imports:
import 'dart:async';

// Project imports:
import 'package:openlib/data/models/my_book.dart';
import 'package:openlib/data/repositories/cover_repository.dart';
import 'package:openlib/data/repositories/download_repository.dart';
import 'package:openlib/data/repositories/library_repository.dart';
import 'package:openlib/data/repositories/mirror_repository.dart';
import 'package:openlib/data/repositories/preferences_repository.dart';
import 'package:openlib/data/services/download_manager.dart';
import 'package:openlib/data/services/slum_catalogue.dart' show MirrorService;
import 'package:openlib/ui/features/library/view_models/library_view_model.dart';

// Fakes for the download-center view model. The page takes the view model
// through its constructor, so these tests do not need Riverpod at all.

class TestLibraryRepository extends LibraryRepository {
  TestLibraryRepository({List<MyBook> books = const []})
      : books = List<MyBook>.of(books);

  List<MyBook> books;

  final List<String> deletedWithFile = [];
  final List<String> deletedRecords = [];

  @override
  Future<List<MyBook>> allBooks() async => List<MyBook>.of(books);

  @override
  Future<MyBook?> bookById(String id) async {
    for (final book in books) {
      if (book.id == id) return book;
    }
    return null;
  }

  @override
  Future<bool> contains(String id) async => await bookById(id) != null;

  @override
  Future<void> insert(MyBook book) async {
    books.removeWhere((item) => item.id == book.id);
    books.add(book);
  }

  @override
  Future<void> deleteBook(String id) async {
    books.removeWhere((book) => book.id == id);
  }

  @override
  Future<void> deleteWithFile(MyBook book) async {
    deletedWithFile.add(book.id);
    await deleteRecord(book);
  }

  @override
  Future<void> deleteRecord(MyBook book) async {
    deletedRecords.add(book.id);
    await deleteBook(book.id);
  }
}

class TestDownloadRepository extends DownloadRepository {
  TestDownloadRepository({Map<String, DownloadTask> initial = const {}})
      : _current = Map<String, DownloadTask>.of(initial);

  final StreamController<Map<String, DownloadTask>> _controller =
      StreamController<Map<String, DownloadTask>>.broadcast();
  Map<String, DownloadTask> _current;

  final List<String> calls = [];

  @override
  Stream<Map<String, DownloadTask>> get updates => _controller.stream;

  @override
  Map<String, DownloadTask> get active =>
      Map<String, DownloadTask>.of(_current);

  void emit(Map<String, DownloadTask> tasks) {
    _current = Map<String, DownloadTask>.of(tasks);
    _controller.add(_current);
  }

  Future<void> close() => _controller.close();

  @override
  Future<void> pause(String taskId) async => calls.add('pause:$taskId');

  @override
  Future<void> resume(String taskId) async => calls.add('resume:$taskId');

  @override
  void cancel(String taskId) => calls.add('cancel:$taskId');

  @override
  Future<void> retryKeepingPartial(String taskId) async =>
      calls.add('retry:$taskId');

  @override
  Future<void> restartWithMirrors(String taskId, List<String> mirrors) async =>
      calls.add('restart:$taskId');

  @override
  Future<void> pauseAll() async => calls.add('pauseAll');

  @override
  Future<void> resumeAll() async => calls.add('resumeAll');
}

class TestCoverRepository extends CoverRepository {
  TestCoverRepository({this.cover});

  String? cover;
  final List<String> requested = [];

  @override
  Future<String?> coverFor(String url) async {
    requested.add(url);
    return cover;
  }
}

class TestPreferencesRepository extends PreferencesRepository {
  TestPreferencesRepository({this.directory});

  String? directory;

  @override
  Future<String?> bookStorageDirectory() async => directory;
}

class TestMirrorRepository extends MirrorRepository {
  TestMirrorRepository({this.urls = const ['https://annas-archive.example/']});

  final List<String> urls;

  @override
  Future<List<String>> enabledUrls(
    MirrorService service, {
    bool force = false,
    bool headlessOnly = false,
  }) async =>
      urls;
}

LibraryViewModel testLibraryViewModel({
  LibraryRepository? library,
  DownloadRepository? downloads,
  PreferencesRepository? preferences,
  CoverRepository? covers,
  MirrorRepository? mirrors,
}) {
  return LibraryViewModel(
    library: library ?? TestLibraryRepository(),
    downloads: downloads ?? TestDownloadRepository(),
    preferences: preferences ?? TestPreferencesRepository(),
    covers: covers ?? TestCoverRepository(),
    mirrors: mirrors ?? TestMirrorRepository(),
  );
}
