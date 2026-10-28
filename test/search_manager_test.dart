// Real tests for multi-provider search: the libgen table parser against
// the HTML shape libgen.is serves, the fan-out merge with fake providers
// (one succeeding, one failing, one returning dupes), and provider
// toggles persisted through the real sqlite preferences table.

// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

// Project imports:
import 'package:openlib/services/annas_archieve.dart';
import 'package:openlib/services/database.dart';
import 'package:openlib/services/logger.dart';
import 'package:openlib/services/search_manager.dart';

import 'helpers/fake_path_provider.dart';

/// A provider the test fully controls.
class _FakeProvider implements SearchProvider {
  _FakeProvider(
    this.idName,
    this.results, {
    this.error,
    this.delay,
    this.unreachable = false,
  });

  final String idName;
  final List<BookData> results;
  final Object? error;
  final Duration? delay;
  final bool unreachable;

  int calls = 0;

  @override
  Future<bool> locallyUnreachable() async => unreachable;

  @override
  SearchProviderId get id =>
      SearchProviderId.values.firstWhere((v) => v.name == idName);

  @override
  String get displayName => idName;

  @override
  Future<List<BookData>> search(SearchQuery query) async {
    calls++;
    if (delay != null) await Future<void>.delayed(delay!);
    if (error != null) throw error!;
    return results;
  }
}

void main() {
  // No TestWidgetsFlutterBinding here on purpose: it rewrites every
  // HttpClient with a 400-returning fake, which would defeat the real
  // local HTTP server the logging tests need.
  setUpAll(() {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      PathProviderPlatform.instance = FakePathProvider('searchmgr');
    }
  });

  // Wipe the preferences between runs so toggle tests start clean.
  setUp(() async {
    final db = MyLibraryDb.instance;
    try {
      await db.savePreference('searchProviders', 'annasArchive');
    } catch (_) {}
  });

  const libgenHtml = '''
  <html><body>
  <table class="c">
    <tbody>
      <tr>
        <td>123456</td>
        <td>Ursula K. Le Guin</td>
        <td><a href="/ads.php?md5=a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4" title="A Wizard of Earthsea">A Wizard of Earthsea</a></td>
        <td>Atheneum</td>
        <td>1968</td>
        <td>183</td>
        <td>English</td>
        <td>2.1MB</td>
        <td>epub</td>
        <td><a href="/get.php?md5=a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4">GET</a></td>
      </tr>
      <tr>
        <td>123457</td>
        <td>J.R.R. Tolkien</td>
        <td><a href="/ads.php?md5=b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5" title="The Hobbit">The Hobbit</a></td>
        <td>Houghton Mifflin</td>
        <td>1937</td>
        <td>310</td>
        <td>English</td>
        <td>1.4MB</td>
        <td>pdf</td>
        <td><a href="/get.php?md5=b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5">GET</a></td>
      </tr>
    </tbody>
  </table>
  </body></html>
  ''';

  group('LibgenProvider.parseResults', () {
    test('parses rows into books with metadata and absolute links', () {
      final provider = LibgenProvider();
      final books = provider.parseResults(libgenHtml, 'https://libgen.is');

      expect(books.length, 2);

      final first = books.first;
      expect(first.title, 'A Wizard of Earthsea');
      expect(first.author, 'Ursula K. Le Guin');
      expect(first.publisher, 'Atheneum');
      expect(first.md5, 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4');
      expect(first.link,
          'https://libgen.is/ads.php?md5=a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4');
      expect(first.info, contains('English'));
      expect(first.info, contains('EPUB'));
      expect(first.info, contains('1968'));
    });

    test('returns empty for a page without a results table', () {
      final provider = LibgenProvider();
      expect(
          provider.parseResults(
              '<html><body>no table</body></html>', 'https://libgen.is'),
          isEmpty);
    });

    test('parses the libgen.li/vg table layout from a captured page', () {
      final provider = LibgenProvider();
      final captured =
          File('test/fixtures/libgen_vg_results.html').readAsStringSync();
      final books = provider.parseResults(captured, 'https://libgen.vg');

      // The fixture holds 3 book rows (plus the header row, skipped).
      expect(books.length, 3);

      for (final book in books) {
        expect(book.title, isNotEmpty);
        expect(book.author, isNotEmpty);
        expect(book.link, startsWith('https://libgen.vg'));
        // Info carries language/ext/size/year in some order.
        expect(book.info, isNotNull);
      }

      // First captured row is a known magazine entry.
      expect(books.first.title, 'Pacing and Clinical Electrophysiology');
      expect(books.first.info, contains('English'));
      expect(books.first.info, contains('PDF'));
    });

    test('skips rows with no title link', () {
      final broken = libgenHtml.replaceFirst(
          '<a href="/ads.php?md5=a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4" title="A Wizard of Earthsea">A Wizard of Earthsea</a>',
          'no link here');
      final provider = LibgenProvider();
      final books = provider.parseResults(broken, 'https://libgen.is');
      expect(books.length, 1);
      expect(books.first.title, 'The Hobbit');
    });
  });

  // A page captured live from z-lib.gd (DiamWall cleared) drives the
  // detail parser: no network, no challenge.
  group('ZlibraryProvider.parseBookPage', () {
    test('parses title, author, file info and download link', () {
      final html = File('test/fixtures/zlib_book_page.html').readAsStringSync();
      final provider = ZlibraryProvider();

      final data = provider.parseBookPage(html, 'https://z-lib.gd',
          'https://z-lib.gd/book/RAZbKkmYAy/americas-test-kitchen.html');

      expect(data, isNotNull);
      expect(data!.title, startsWith('America’s Test Kitchen'));
      expect(data.author, "America's Test Kitchen");
      expect(data.format, 'EPUB');
      expect(data.info, contains('English'));
      expect(data.info, contains('2016'));
      expect(data.mirror, isNotNull);
      expect(data.mirror, startsWith('https://z-lib.gd/dl/'));
      // The stable book id doubles as the md5 key in the library db.
      expect(data.md5, 'RAZbKkmYAy');
    });

    test('returns null without a title', () {
      final data = ZlibraryProvider().parseBookPage(
          '<html><body><h1></h1></body></html>', 'https://z-lib.gd', 'x');
      expect(data, isNull);
    });
  });

  group('SearchManager fan-out', () {
    test('queries every enabled provider and reports failures', () async {
      // All enabled sources run in parallel: a failing libgen still leaves
      // zlibrary and Anna's Archive contributing their own results.
      final failing = _FakeProvider('libgen', [], error: Exception('down'));
      final zlib = _FakeProvider('zlibrary', [
        BookData(title: 'Z', link: 'https://z/md5/x1', md5: 'md5-z'),
      ]);
      final anna = _FakeProvider('annasArchive', [
        BookData(title: 'AA Book', link: 'https://a/md5/x1', md5: 'md5-1'),
      ]);
      final manager = SearchManager(
        database: MyLibraryDb.instance,
        providers: [failing, anna, zlib],
      );
      await manager.setProviderEnabled(SearchProviderId.libgen, true);
      await manager.setProviderEnabled(SearchProviderId.annasArchive, true);
      await manager.setProviderEnabled(SearchProviderId.zlibrary, true);

      final result = await manager.search(const SearchQuery(text: 'wizard'));

      expect(result.books.length, 2);
      expect(result.books.first.title, 'Z');
      expect(result.failedProviders, ['libgen']);
      expect(failing.calls, 1);
      expect(zlib.calls, 1);
      expect(anna.calls, 1, reason: 'a hit must not stop the other sources');
      expect(result.booksBySource[SearchProviderId.zlibrary]!.single.title, 'Z');
      expect(result.booksBySource[SearchProviderId.annasArchive]!.single.title,
          'AA Book');
    });

    test('applies the file type filter to every provider result', () async {
      final libgen = _FakeProvider('libgen', [
        BookData(
            title: 'EPUB Libgen',
            link: 'https://l/epub',
            md5: 'l-epub',
            info: 'English, EPUB, 2 MB'),
        BookData(
            title: 'PDF Libgen',
            link: 'https://l/pdf',
            md5: 'l-pdf',
            info: 'English, PDF, 4 MB'),
      ]);
      final zlib = _FakeProvider('zlibrary', [
        BookData(
            title: 'PDF Zlib',
            link: 'https://z/pdf',
            md5: 'z-pdf',
            info: 'English, PDF, 3 MB'),
        BookData(
            title: 'EPUB Zlib',
            link: 'https://z/epub',
            md5: 'z-epub',
            info: 'English, EPUB, 1 MB'),
      ]);
      final manager = SearchManager(
        database: MyLibraryDb.instance,
        providers: [libgen, zlib],
      );
      await manager.setProviderEnabled(SearchProviderId.libgen, true);
      await manager.setProviderEnabled(SearchProviderId.zlibrary, true);

      final filtered = await manager.search(const SearchQuery(
        text: 'q',
        fileType: 'epub',
        filtersEnabled: true,
      ));

      expect(
        filtered.books.map((book) => book.title),
        unorderedEquals(['EPUB Libgen', 'EPUB Zlib']),
      );
      expect(
        filtered.booksBySource[SearchProviderId.libgen]!.single.title,
        'EPUB Libgen',
      );
      expect(
        filtered.booksBySource[SearchProviderId.zlibrary]!.single.title,
        'EPUB Zlib',
      );

      final unfiltered = await manager.search(const SearchQuery(text: 'q'));
      expect(unfiltered.books.length, 4);

      final allFormats = await manager.search(const SearchQuery(
        text: 'q',
        fileType: 'All',
        filtersEnabled: true,
      ));
      expect(allFormats.books.length, 4);
    });

    test('filters by newer formats and folds azw into azw3', () async {
      final provider = _FakeProvider('libgen', [
        BookData(
            title: 'MOBI Book',
            link: 'https://l/mobi',
            md5: 'l-mobi',
            info: 'English, MOBI, 1 MB'),
        BookData(
            title: 'AZW Book',
            link: 'https://l/azw',
            md5: 'l-azw',
            info: 'English, AZW, 1 MB'),
        BookData(
            title: 'EPUB Book',
            link: 'https://l/epub',
            md5: 'l-epub',
            info: 'English, EPUB, 1 MB'),
      ]);
      final manager = SearchManager(
        database: MyLibraryDb.instance,
        providers: [provider],
      );
      await manager.setProviderEnabled(SearchProviderId.libgen, true);

      final mobi = await manager.search(const SearchQuery(
        text: 'q',
        fileType: 'mobi',
        filtersEnabled: true,
      ));
      expect(mobi.books.map((book) => book.title), ['MOBI Book']);

      final azw = await manager.search(const SearchQuery(
        text: 'q',
        fileType: 'azw3',
        filtersEnabled: true,
      ));
      expect(azw.books.map((book) => book.title), ['AZW Book'],
          reason: 'AZW is Kindle AZW3 family');

      final pdf = await manager.search(const SearchQuery(
        text: 'q',
        fileType: 'pdf',
        filtersEnabled: true,
      ));
      expect(pdf.books, isEmpty);
    });

    test('tags results with the provider that produced them', () async {
      final provider = _FakeProvider('libgen', [
        BookData(title: 'Tagged', link: 'https://l/1', md5: 'tag-1'),
      ]);
      final manager = SearchManager(
        database: MyLibraryDb.instance,
        providers: [provider],
      );
      await manager.setProviderEnabled(SearchProviderId.libgen, true);

      final result = await manager.search(const SearchQuery(text: 'tag'));

      // The tag must round-trip the provider's own displayName.
      expect(result.books.first.source, isNotNull);
      expect(result.books.first.source, provider.displayName);
      expect(result.resultSource, provider.displayName);
    });

    test('copyWith stamps source without touching other fields', () {
      final book = BookData(
          title: 'T', author: 'A', link: 'https://l/1', md5: 'm', info: 'i');
      final tagged = book.copyWith(source: 'LibGen');

      expect(tagged.source, 'LibGen');
      expect(tagged.title, 'T');
      expect(tagged.author, 'A');
      expect(tagged.info, 'i');
      expect(book.source, isNull); // original untouched
    });

    test('an empty source does not block the others', () async {
      // libgen answers fine but has nothing; zlibrary still contributes.
      final empty = _FakeProvider('libgen', []);
      final next = _FakeProvider('zlibrary', [
        BookData(title: 'Z Book', link: 'https://z/1', md5: 'z-md5'),
      ]);
      final manager = SearchManager(
        database: MyLibraryDb.instance,
        providers: [empty, next],
      );
      await manager.setProviderEnabled(SearchProviderId.libgen, true);
      await manager.setProviderEnabled(SearchProviderId.zlibrary, true);

      final result = await manager.search(const SearchQuery(text: 'x'));

      expect(empty.calls, 1);
      expect(next.calls, 1);
      expect(result.books.first.title, 'Z Book');
      expect(result.books.first.source, next.displayName);
      expect(result.resultSource, next.displayName);
      expect(result.failedProviders, isEmpty); // empty is not an error
    });

    test('drops duplicate md5s within one provider result page', () async {
      // Mirrors can return the same edition twice; per-source book lists
      // are de-duplicated before they reach the source switcher.
      final dupe = BookData(
          title: 'From Libgen', link: 'https://l/md5/x', md5: 'same-md5');
      final provider = _FakeProvider('libgen', [
        dupe,
        BookData(
            title: 'From Mirror 2', link: 'https://l/md5/x2', md5: 'same-md5'),
        BookData(title: 'Unique', link: 'https://l/md5/y', md5: 'other')
      ]);
      final manager = SearchManager(
        database: MyLibraryDb.instance,
        providers: [provider],
      );
      await manager.setProviderEnabled(SearchProviderId.libgen, true);

      final result = await manager.search(const SearchQuery(text: 'dupes'));

      expect(result.books.length, 2);
      expect(result.books.firstWhere((b) => b.md5 == 'same-md5').title,
          'From Libgen');
    });

    test('searches only enabled providers', () async {
      final off = _FakeProvider('zlibrary', [
        BookData(title: 'Z', link: 'https://z/1', md5: 'z-md5'),
      ]);
      final on = _FakeProvider('annasArchive', [
        BookData(title: 'A', link: 'https://a/1', md5: 'a-md5'),
      ]);
      final manager = SearchManager(
        database: MyLibraryDb.instance,
        providers: [on, off],
      );
      // Stored preference (seeded by setUp): annasArchive only.

      final result = await manager.search(const SearchQuery(text: 'q'));

      expect(result.books.length, 1);
      expect(off.calls, 0);
    });

    test('a query source restricts the chain to that provider', () async {
      final libgen = _FakeProvider('libgen', [
        BookData(title: 'L', link: 'https://l/1', md5: 'l-md5'),
      ]);
      final zlib = _FakeProvider('zlibrary', [
        BookData(title: 'Z', link: 'https://z/1', md5: 'z-md5'),
      ]);
      final manager = SearchManager(
        database: MyLibraryDb.instance,
        providers: [libgen, zlib],
      );
      await manager.setProviderEnabled(SearchProviderId.libgen, true);
      await manager.setProviderEnabled(SearchProviderId.zlibrary, true);

      final result = await manager.search(
          const SearchQuery(text: 'q', source: SearchProviderId.zlibrary));

      expect(libgen.calls, 0);
      expect(zlib.calls, 1);
      expect(result.books.single.title, 'Z');
    });

    test('watch streams the first hit before slow sources finish', () async {
      final fast = _FakeProvider('libgen', [
        BookData(title: 'Fast', link: 'https://l/1', md5: 'fast'),
      ]);
      final slow = _FakeProvider('annasArchive', [
        BookData(title: 'Slow', link: 'https://a/1', md5: 'slow'),
      ], delay: const Duration(milliseconds: 60));
      final manager = SearchManager(
        database: MyLibraryDb.instance,
        providers: [fast, slow],
      );
      await manager.setProviderEnabled(SearchProviderId.libgen, true);
      await manager.setProviderEnabled(SearchProviderId.annasArchive, true);
      await manager.setProviderEnabled(SearchProviderId.zlibrary, false);
      await manager.setProviderEnabled(SearchProviderId.welib, false);

      final snapshots =
          await manager.watch(const SearchQuery(text: 'stream')).toList();

      expect(snapshots.length, 2);
      expect(snapshots.first.books.single.title, 'Fast');
      expect(
        snapshots.first.sources
            .firstWhere((run) => run.id == SearchProviderId.annasArchive)
            .status,
        SearchSourceStatus.pending,
      );
      expect(snapshots.last.books.map((book) => book.title),
          containsAll(['Fast', 'Slow']));
      expect(
        snapshots.last.sources
            .firstWhere((run) => run.id == SearchProviderId.annasArchive)
            .status,
        SearchSourceStatus.hit,
      );
    });

    test('reports one run per queried source, in configured order', () async {
      final empty = _FakeProvider('libgen', []);
      final hit = _FakeProvider('zlibrary', [
        BookData(title: 'Z1', link: 'https://z/1', md5: 'z-1'),
        BookData(title: 'Z2', link: 'https://z/2', md5: 'z-2'),
      ]);
      final otherEmpty = _FakeProvider('welib', []);
      final thirdEmpty = _FakeProvider('annasArchive', []);
      final manager = SearchManager(
        database: MyLibraryDb.instance,
        providers: [empty, hit, otherEmpty, thirdEmpty],
      );
      await manager.setProviderEnabled(SearchProviderId.libgen, true);
      await manager.setProviderEnabled(SearchProviderId.zlibrary, true);
      await manager.setProviderEnabled(SearchProviderId.welib, true);
      await manager.setProviderEnabled(SearchProviderId.annasArchive, true);

      final result = await manager.search(const SearchQuery(text: 'x'));

      expect(
        result.sources.map((source) => source.id),
        [
          SearchProviderId.libgen,
          SearchProviderId.zlibrary,
          SearchProviderId.welib,
          SearchProviderId.annasArchive,
        ],
      );
      expect(result.sources.every((run) => run.wasAttempted), isTrue);
      expect(result.sources[0].status, SearchSourceStatus.empty);
      expect(result.sources[0].resultCount, 0);
      expect(result.sources[1].status, SearchSourceStatus.hit);
      expect(result.sources[1].resultCount, 2);
      expect(result.sources[2].status, SearchSourceStatus.empty);
      expect(result.sources[3].status, SearchSourceStatus.empty);
      expect(otherEmpty.calls, 1);
      expect(thirdEmpty.calls, 1);
      expect(result.resultSourceId, SearchProviderId.zlibrary);
      expect(result.resultSource, 'zlibrary');
    });

    test('marks a failed source as failed in the run list', () async {
      final failing = _FakeProvider('libgen', [], error: Exception('down'));
      final hit = _FakeProvider('annasArchive', [
        BookData(title: 'AA', link: 'https://a/1', md5: 'a-1'),
      ]);
      final manager = SearchManager(
        database: MyLibraryDb.instance,
        providers: [failing, hit],
      );
      await manager.setProviderEnabled(SearchProviderId.libgen, true);
      await manager.setProviderEnabled(SearchProviderId.annasArchive, true);

      final result = await manager.search(const SearchQuery(text: 'x'));

      expect(result.sources.first.status, SearchSourceStatus.failed);
      expect(result.sources.first.resultCount, 0);
      expect(result.sources.last.status, SearchSourceStatus.hit);
    });

    test('a query source reports only the selected source', () async {
      final libgen = _FakeProvider('libgen', [
        BookData(title: 'L', link: 'https://l/1', md5: 'l-md5'),
      ]);
      final zlib = _FakeProvider('zlibrary', [
        BookData(title: 'Z', link: 'https://z/1', md5: 'z-md5'),
      ]);
      final manager = SearchManager(
        database: MyLibraryDb.instance,
        providers: [libgen, zlib],
      );
      await manager.setProviderEnabled(SearchProviderId.libgen, true);
      await manager.setProviderEnabled(SearchProviderId.zlibrary, true);

      final result = await manager.search(
          const SearchQuery(text: 'q', source: SearchProviderId.zlibrary));

      expect(result.sources, hasLength(1));
      expect(result.sources.single.id, SearchProviderId.zlibrary);
      expect(result.sources.single.status, SearchSourceStatus.hit);
      expect(result.resultSourceId, SearchProviderId.zlibrary);
    });

    // A fresh install has no stored preference; the chain must cover
    // every provider, libgen first.
    test('with no stored preference, all providers are on', () async {
      final db = MyLibraryDb.instance;
      final raw = await db.database;
      await raw.delete('preferences',
          where: 'name = ?', whereArgs: ['searchProviders']);
      addTearDown(() async {
        await db.savePreference('searchProviders', 'annasArchive');
      });

      final manager = SearchManager(database: db);
      final enabled = await manager.enabledProviders();

      expect(enabled, containsAll(SearchProviderId.values));
    });

    test('last provider cannot be disabled', () async {
      final manager = SearchManager(database: MyLibraryDb.instance);
      // Default: annasArchive only.
      await manager.setProviderEnabled(SearchProviderId.annasArchive, false);
      final enabled = await manager.enabledProviders();
      expect(enabled, {SearchProviderId.annasArchive});
    });

    test('toggles persist through the preferences table', () async {
      final manager = SearchManager(database: MyLibraryDb.instance);
      await manager.setProviderEnabled(SearchProviderId.libgen, true);
      await manager.setProviderEnabled(SearchProviderId.zlibrary, true);

      final reRead = SearchManager(database: MyLibraryDb.instance);
      final enabled = await reRead.enabledProviders();
      expect(
          enabled,
          containsAll([
            SearchProviderId.annasArchive,
            SearchProviderId.libgen,
            SearchProviderId.zlibrary,
          ]));

      await reRead.setProviderEnabled(SearchProviderId.zlibrary, false);
      final afterOff = await SearchManager(database: MyLibraryDb.instance)
          .enabledProviders();
      expect(afterOff, isNot(contains(SearchProviderId.zlibrary)));
    });
  });

  // The settings page lets the user drag the chain order; the manager must
  // run that order and the journey must report it.
  group('search source order', () {
    const shipped = defaultSearchSourceOrder;

    tearDown(() async {
      await MyLibraryDb.instance.savePreference(
          'searchSourceOrder', shipped.map((id) => id.name).join(','));
    });

    test('defaults to the shipped chain before anything is saved', () async {
      final db = MyLibraryDb.instance;
      final raw = await db.database;
      await raw.delete('preferences',
          where: 'name = ?', whereArgs: ['searchSourceOrder']);

      expect(await SearchManager(database: db).sourceOrder(), shipped);
    });

    test('persists the dragged order', () async {
      const dragged = [
        SearchProviderId.annasArchive,
        SearchProviderId.welib,
        SearchProviderId.libgen,
        SearchProviderId.zlibrary,
      ];
      await SearchManager(database: MyLibraryDb.instance)
          .setSourceOrder(dragged);

      expect(
          await SearchManager(database: MyLibraryDb.instance).sourceOrder(),
          dragged);
    });

    test('keeps providers a saved order never mentions', () async {
      final db = MyLibraryDb.instance;
      // An old install that only knew about WeLib when it saved.
      await db.savePreference('searchSourceOrder', 'welib');

      expect(await SearchManager(database: db).sourceOrder(), [
        SearchProviderId.welib,
        SearchProviderId.libgen,
        SearchProviderId.zlibrary,
        SearchProviderId.annasArchive,
      ]);
    });

    test('resets to the shipped order', () async {
      final manager = SearchManager(database: MyLibraryDb.instance);
      await manager.setSourceOrder(const [
        SearchProviderId.annasArchive,
        SearchProviderId.zlibrary,
        SearchProviderId.welib,
        SearchProviderId.libgen,
      ]);

      await manager.resetSourceOrder();

      expect(await manager.sourceOrder(), shipped);
    });

    test('runs every source and keeps the saved order for the merge', () async {
      final db = MyLibraryDb.instance;
      await db.savePreference('searchProviders',
          SearchProviderId.values.map((p) => p.name).join(','));
      await SearchManager(database: db).setSourceOrder(const [
        SearchProviderId.welib,
        SearchProviderId.zlibrary,
        SearchProviderId.libgen,
        SearchProviderId.annasArchive,
      ]);

      final welib = _FakeProvider('welib', [
        BookData(title: 'W', link: 'https://w/md5/1', md5: 'w-md5'),
      ]);
      final libgen = _FakeProvider('libgen', [
        BookData(title: 'L', link: 'https://l/md5/1', md5: 'l-md5'),
      ]);

      final result = await SearchManager(database: db, providers: [libgen, welib])
          .search(const SearchQuery(text: 'order'));

      expect(result.resultSourceId, SearchProviderId.welib);
      expect(result.books.map((book) => book.title), ['W', 'L']);
      expect(libgen.calls, 1,
          reason: 'all sources run in parallel, not just the first');
      expect(result.sources.first.id, SearchProviderId.welib);
      expect(result.sources.first.status, SearchSourceStatus.hit);
    });
  });

  // Regression test for #98: searches, provider attempts and pings used
  // to leave no trace in the exported logs. The libgen provider now logs
  // its lifecycle and its Dio records every request/response, so a
  // scraping session can be debugged from the export alone.
  group('local timeout skip', () {
    test('skips an all-timeout source and lets try-anyway force it', () async {
      final skipped = _FakeProvider(
        'libgen',
        [BookData(title: 'Skipped', link: 'https://l/1', md5: 'skip')],
        unreachable: true,
      );
      final alive = _FakeProvider(
        'zlibrary',
        [BookData(title: 'Alive', link: 'https://z/1', md5: 'alive')],
      );
      final manager = SearchManager(
        database: MyLibraryDb.instance,
        providers: [skipped, alive],
      );
      await manager.setProviderEnabled(SearchProviderId.libgen, true);
      await manager.setProviderEnabled(SearchProviderId.zlibrary, true);

      final result = await manager.search(const SearchQuery(text: 'q'));
      final libgenRun = result.sources
          .firstWhere((run) => run.id == SearchProviderId.libgen);

      expect(libgenRun.status, SearchSourceStatus.locallyUnreachable);
      expect(skipped.calls, 0);
      expect(result.books.map((book) => book.title), ['Alive']);

      final forced = await manager.search(
        const SearchQuery(text: 'q'),
        forceLocalTimeouts: true,
      );
      expect(skipped.calls, 1);
      expect(
        forced.sources
            .firstWhere((run) => run.id == SearchProviderId.libgen)
            .status,
        SearchSourceStatus.hit,
      );
    });

    test('watch includes the skipped source without querying it', () async {
      final skipped = _FakeProvider(
        'libgen',
        [BookData(title: 'Skipped', link: 'https://l/1', md5: 'skip')],
        unreachable: true,
      );
      final alive = _FakeProvider(
        'zlibrary',
        [BookData(title: 'Alive', link: 'https://z/1', md5: 'alive')],
      );
      final manager = SearchManager(
        database: MyLibraryDb.instance,
        providers: [skipped, alive],
      );
      await manager.setProviderEnabled(SearchProviderId.libgen, true);
      await manager.setProviderEnabled(SearchProviderId.zlibrary, true);

      final snapshots =
          await manager.watch(const SearchQuery(text: 'q')).toList();
      final run = snapshots.last.sources
          .firstWhere((run) => run.id == SearchProviderId.libgen);

      expect(run.status, SearchSourceStatus.locallyUnreachable);
      expect(skipped.calls, 0);
      expect(snapshots.last.books.map((book) => book.title), ['Alive']);
    });
  });

  group('search logging (issue #98)', () {
    test('a libgen search leaves network and lifecycle entries in the log',
        () async {
      final html =
          File('test/fixtures/libgen_vg_results.html').readAsStringSync();
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close());
      server.listen((request) async {
        request.response.headers.contentType = ContentType.html;
        request.response.write(html);
        await request.response.close();
      });
      final mirror = 'http://127.0.0.1:${server.port}';

      AppLogger().clearLogs();
      final provider = LibgenProvider(mirrors: [mirror]);
      final books = await provider.search(const SearchQuery(text: 'flutter'));
      expect(books, isNotEmpty, reason: 'fixture must parse');

      final logs = AppLogger().getAllLogs();
      expect(logs, contains('Searching Library Genesis'),
          reason: 'search start must be logged');
      // The full query string is part of the logged URL; match the base.
      expect(logs, contains('Request: GET $mirror/index.php?req=flutter'),
          reason: 'the HTTP request must be logged');
      expect(logs,
          contains('Response: GET $mirror/index.php?req=flutter&res=100 [200]'),
          reason: 'the HTTP response must be logged');
      expect(logs, contains('Libgen search returned ${books.length} books'),
          reason: 'result count must be logged');
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('hedges the first two mirrors so a slow mirror does not gate results',
        () async {
      final slow = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      slow.listen((request) async {
        await Future<void>.delayed(const Duration(seconds: 2));
        request.response.headers.contentType = ContentType.html;
        request.response.write(libgenHtml);
        await request.response.close();
      });
      final fast = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      fast.listen((request) async {
        request.response.headers.contentType = ContentType.html;
        request.response.write(libgenHtml);
        await request.response.close();
      });

      try {
        final stopwatch = Stopwatch()..start();
        final provider = LibgenProvider(mirrors: [
          'http://127.0.0.1:${slow.port}',
          'http://127.0.0.1:${fast.port}',
        ]);

        final books = await provider.search(const SearchQuery(text: 'flutter'));
        stopwatch.stop();

        expect(books, isNotEmpty);
        expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 1500)),
            reason: 'the fast mirror must win without waiting for the slow one');
      } finally {
        await slow.close(force: true);
        await fast.close(force: true);
      }
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('a dead libgen mirror logs the failure before moving on', () async {
      // Port with nothing listening: connection refused, not a timeout.
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final deadPort = server.port;
      await server.close();

      AppLogger().clearLogs();
      final provider = LibgenProvider(mirrors: ['http://127.0.0.1:$deadPort']);
      await expectLater(
          provider.search(const SearchQuery(text: 'x')), throwsA(anything));

      final logs = AppLogger().getAllLogs();
      expect(logs, contains('Searching Library Genesis'));
      expect(logs, contains('Libgen mirror failed, trying next'));
      expect(logs, contains('All libgen mirrors failed'));
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}
