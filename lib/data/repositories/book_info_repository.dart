// Project imports:
import 'package:openlib/data/models/book_data.dart';
import 'package:openlib/data/services/annas_archieve.dart';
import 'package:openlib/data/services/book_detail_routing.dart';
import 'package:openlib/data/services/book_info_cache.dart';
import 'package:openlib/data/services/libgen_service.dart';
import 'package:openlib/data/services/search_manager.dart';

/// Fetches and caches one book-detail page, routed by URL through
/// [routeBookDetail] to the provider that can actually serve it.
///
/// Routing matters: handing a provider's URL to Anna's Archive used to swap
/// its host for an AA mirror that does not carry the book (404 city), while
/// libgen's `ads.php?md5=` and Z-Library's `/book/` pages each need their own
/// parser. The route comes from the open-slum.org catalogue, so it keeps
/// working when SLUM lists a mirror this build never shipped.
class BookInfoRepository {
  BookInfoRepository({
    Future<BookDetailRoute> Function(String url)? route,
    LibgenService? libgen,
    ZlibraryProvider? zlibrary,
    WelibProvider? welib,
    AnnasArchieve? annasArchive,
    Future<BookInfoData?> Function(String url)? readCache,
    Future<void> Function(String url, BookInfoData data)? writeCache,
  })  : _route = route ?? routeBookDetail,
        _libgen = libgen ?? LibgenService(),
        _zlibrary = zlibrary ?? ZlibraryProvider(),
        _welib = welib ?? WelibProvider(),
        _annasArchive = annasArchive ?? AnnasArchieve(),
        _readCache = readCache ?? BookInfoCache.read,
        _writeCache = writeCache ?? BookInfoCache.write;

  final Future<BookDetailRoute> Function(String url) _route;
  final LibgenService _libgen;
  final ZlibraryProvider _zlibrary;
  final WelibProvider _welib;
  final AnnasArchieve _annasArchive;
  final Future<BookInfoData?> Function(String url) _readCache;
  final Future<void> Function(String url, BookInfoData data) _writeCache;

  /// The detail page for [url], served from [BookInfoCache] when a fresh
  /// entry exists. A cache miss re-fetches and stores the result; cache
  /// writes never fail the page.
  Future<BookInfoData> fetch(
    String url, {
    String donationKey = '',
    bool Function()? shouldContinue,
  }) async {
    final cached = await _readCache(url);
    if (cached != null) return cached;
    final data = await _fetch(
      url,
      donationKey: donationKey,
      shouldContinue: shouldContinue,
    );
    await _writeCache(url, data);
    return data;
  }

  Future<BookInfoData> _fetch(
    String url, {
    required String donationKey,
    bool Function()? shouldContinue,
  }) async {
    final route = await _route(url);
    switch (route) {
      case BookDetailRoute.libgen:
        final data = await _libgen.bookInfo(url);
        if (data == null) {
          throw Exception('Could not read this libgen book page');
        }
        return data;
      case BookDetailRoute.zlibrary:
        final data = await _zlibrary.bookInfo(url);
        if (data == null) {
          throw Exception('Could not read this Z-Library book page');
        }
        return data;
      case BookDetailRoute.welib:
        final data = await _welib.bookInfo(
          url,
          shouldContinue: shouldContinue,
        );
        if (data == null) {
          throw Exception('Could not read this WeLib book page');
        }
        return data;
      case BookDetailRoute.annasArchive:
        return _annasArchive.bookInfo(
          url: url,
          donationKey: donationKey,
          shouldContinue: shouldContinue,
        );
    }
  }
}
