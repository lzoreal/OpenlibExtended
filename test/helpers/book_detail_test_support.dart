// Shared book-detail fakes. The page takes its view model through the
// constructor, so widget tests need no Riverpod at all.

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:openlib/app/app_settings.dart';
import 'package:openlib/data/models/book_data.dart';
import 'package:openlib/data/models/my_book.dart';
import 'package:openlib/data/models/search_filters.dart';
import 'package:openlib/data/repositories/book_info_repository.dart';
import 'package:openlib/data/repositories/download_repository.dart';
import 'package:openlib/data/repositories/library_repository.dart';
import 'package:openlib/data/repositories/mirror_repository.dart';
import 'package:openlib/data/services/download_manager.dart';
import 'package:openlib/data/services/instance_manager.dart';
import 'package:openlib/ui/features/book_detail/view_models/book_detail_view_model.dart';

class FakeLibraryRepository extends LibraryRepository {
  FakeLibraryRepository({Map<String, MyBook>? books}) : books = {...?books};

  final Map<String, MyBook> books;
  final List<MyBook> deleted = [];
  int containsCalls = 0;

  @override
  Future<List<MyBook>> allBooks() async => books.values.toList();

  @override
  Future<MyBook?> bookById(String id) async => books[id];

  @override
  Future<bool> contains(String id) async {
    containsCalls++;
    return books.containsKey(id);
  }

  @override
  Future<void> insert(MyBook book) async {
    books[book.id] = book;
  }

  @override
  Future<void> deleteBook(String id) async {
    books.remove(id);
  }

  @override
  Future<void> deleteWithFile(MyBook book) async {
    deleted.add(book);
    books.remove(book.id);
  }
}

class FakeDownloadRepository extends DownloadRepository {
  final List<DownloadTask> added = [];
  final List<({DownloadTask task, String mirrorUrl})> addedWithMirrorUrl = [];

  @override
  Future<void> add(DownloadTask task) async {
    added.add(task);
  }

  @override
  Future<void> addWithMirrorUrl(DownloadTask task, String mirrorUrl) async {
    addedWithMirrorUrl.add((task: task, mirrorUrl: mirrorUrl));
  }
}

class FakeBookInfoRepository extends BookInfoRepository {
  FakeBookInfoRepository({this.handler});

  final Future<BookInfoData> Function(String url)? handler;
  final List<String> requested = [];
  final List<String> donationKeys = [];

  @override
  Future<BookInfoData> fetch(String url, {String donationKey = ''}) {
    requested.add(url);
    donationKeys.add(donationKey);
    final handler = this.handler;
    if (handler == null) {
      return Future<BookInfoData>.error(
        StateError('FakeBookInfoRepository has no handler'),
      );
    }
    return handler(url);
  }
}

class FakeMirrorRepository extends MirrorRepository {
  FakeMirrorRepository({this.urls = const [], this.error});

  final List<String> urls;
  final Object? error;

  @override
  Future<List<String>> enabledUrls(
    MirrorService service, {
    bool force = false,
    bool headlessOnly = false,
  }) async {
    final error = this.error;
    if (error != null) throw error;
    return urls;
  }
}

AppSettings testBookDetailSettings({
  bool showManualDownloadButton = false,
  String donationKey = '',
}) {
  return AppSettings(
    themeMode: ThemeMode.system,
    fontSizeScale: 1.0,
    locale: null,
    showManualDownloadButton: showManualDownloadButton,
    backgroundVerification: true,
    donationKey: donationKey,
    userAgent: '',
    cookie: '',
    filters: const SearchFilters(),
  );
}

BookDetailViewModel testBookDetailViewModel({
  String url = 'https://example.com/md5/abc',
  String? source = 'LibGen',
  BookData? preview,
  LibraryRepository? library,
  DownloadRepository? downloads,
  AppSettings? settings,
  BookInfoRepository? bookInfo,
  MirrorRepository? mirrors,
}) {
  return BookDetailViewModel(
    url: url,
    source: source,
    preview: preview,
    library: library ?? FakeLibraryRepository(),
    downloads: downloads ?? FakeDownloadRepository(),
    settings: settings ?? testBookDetailSettings(),
    bookInfo: bookInfo ?? FakeBookInfoRepository(),
    mirrors: mirrors ?? FakeMirrorRepository(),
  );
}
