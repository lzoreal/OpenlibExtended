// Dart imports:
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
// NOTE: These imports are crucial and must exist in your project structure.
import 'package:openlib/services/annas_archieve.dart';
import 'package:openlib/services/book_detail_routing.dart';
import 'package:openlib/services/book_info_cache.dart';
import 'package:openlib/services/database.dart';
import 'package:openlib/services/libgen_service.dart';
import 'package:openlib/services/search_manager.dart';
import 'package:openlib/services/files.dart';
import 'package:openlib/services/open_library.dart';
import 'package:openlib/services/goodreads.dart';
import 'package:openlib/services/instance_manager.dart';
import 'package:openlib/services/mirror_latency.dart';
import 'package:openlib/services/download_manager.dart';
import 'package:openlib/services/stream_throttle.dart';
// Assuming OpenLibrary, Goodreads, PenguinRandomHouse, BookDigits, and SubCategoriesTypeList are defined
// or are simple placeholder services/models that work as intended.

MyLibraryDb dataBase = MyLibraryDb.instance;

// ====================================================================
// DROPDOWN/FILTER MAPPING DATA
// ====================================================================

Map<String, String> typeValues = {
  'All': '',
  'Any Books': 'book_any',
  'Unknown Books': 'book_unknown',
  'Fiction Books': 'book_fiction',
  'Non-fiction Books': 'book_nonfiction',
  'Comic Books': 'book_comic',
  'Magazine': 'magazine',
  'Standards Document': 'standards_document',
  'Journal Article': 'journal_article'
};

Map<String, String> sortValues = {
  'Most Relevant': '',
  'Newest': 'newest',
  'Oldest': 'oldest',
  'Largest': 'largest',
  'Smallest': 'smallest',
};

// Values double as the persisted filterFileType preference, so keep the
// historical casing of the original entries; chips display them uppercase.
List<String> fileType = [
  "All",
  "PDF",
  "Epub",
  "Mobi",
  "Azw3",
  "Fb2",
  "Djvu",
  "Txt",
  "Cbr",
  "Cbz",
];

// Language filter values (display name: code)
Map<String, String> languageValues = {
  "All": "",
  "English": "en",
  "Spanish": "es",
  "French": "fr",
  "German": "de",
  "Italian": "it",
  "Portuguese": "pt",
  "Russian": "ru",
  "Chinese": "zh",
  "Japanese": "ja",
  "Korean": "ko",
  "Arabic": "ar",
  "Hindi": "hi",
  "Malayalam": "ml",
  "Dutch": "nl",
  "Polish": "pl",
  "Turkish": "tr",
  "Swedish": "sv",
  "Indonesian": "id",
  "Vietnamese": "vi",
  "Czech": "cs",
  "Greek": "el",
  "Romanian": "ro",
  "Hungarian": "hu",
  "Ukrainian": "uk",
  "Hebrew": "he",
  "Thai": "th",
  "Persian": "fa",
  "Bengali": "bn",
  "Finnish": "fi",
  "Norwegian": "no",
  "Danish": "da",
};

// Reverse map: language code to uppercase display code
Map<String, String> languageCodeToDisplay = {
  "en": "EN",
  "es": "ES",
  "fr": "FR",
  "de": "DE",
  "it": "IT",
  "pt": "PT",
  "ru": "RU",
  "zh": "ZH",
  "ja": "JA",
  "ko": "KO",
  "ar": "AR",
  "hi": "HI",
  "ml": "ML",
  "nl": "NL",
  "pl": "PL",
  "tr": "TR",
  "sv": "SV",
  "id": "ID",
  "vi": "VI",
  "cs": "CS",
  "el": "EL",
  "ro": "RO",
  "hu": "HU",
  "uk": "UK",
  "he": "HE",
  "th": "TH",
  "fa": "FA",
  "bn": "BN",
  "fi": "FI",
  "no": "NO",
  "da": "DA",
};

// Year filter values for publishing year range
List<String> yearValues = [
  "All",
  "2025",
  "2024",
  "2023",
  "2022",
  "2021",
  "2020",
  "2019",
  "2018",
  "2017",
  "2016",
  "2015",
  "2010-2014",
  "2005-2009",
  "2000-2004",
  "1990-1999",
  "1980-1989",
  "Before 1980",
];

// ====================================================================
// ENUMS AND DATA CLASSES
// ====================================================================

class FileName {
  final String md5;
  final String format;
  final String? fileName;

  FileName({required this.md5, required this.format, this.fileName});
}

// ====================================================================
// UI AND SIMPLE STATE PROVIDERS
// ====================================================================

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(super.state);

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;

    // Save to DB
    String pref = 'system';
    if (mode == ThemeMode.light) pref = 'light';
    if (mode == ThemeMode.dark) pref = 'dark';
    await MyLibraryDb.instance.savePreference('themeMode', pref);

    updateSystemUi(mode);
  }

  static void updateSystemUi(ThemeMode mode) {
    if (Platform.isAndroid) {
      bool isDark = mode == ThemeMode.dark;
      if (mode == ThemeMode.system) {
        isDark = ui.PlatformDispatcher.instance.platformBrightness ==
            Brightness.dark;
      }
      // Keep the system bar in step with the MD3 surface palette.
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor:
            isDark ? const Color(0xFF141218) : const Color(0xFFFEF7FF),
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ));
    }
  }

  static Future<ThemeMode> getInitialTheme() async {
    try {
      MyLibraryDb dataBase = MyLibraryDb.instance;
      // Check for new theme mode preference
      var themePref =
          await dataBase.getPreference('themeMode').catchError((e) => null);
      if (themePref != null && themePref is String) {
        if (themePref == 'light') return ThemeMode.light;
        if (themePref == 'dark') return ThemeMode.dark;
        return ThemeMode.system;
      } else {
        // Fallback to legacy darkMode preference
        var legacyDark =
            await dataBase.getPreference('darkMode').catchError((e) => null);
        if (legacyDark != null) {
          return (legacyDark == 0) ? ThemeMode.light : ThemeMode.dark;
        }
      }
    } catch (e) {
      // Ignore
    }
    return ThemeMode.system;
  }
}

final selectedIndexProvider = StateProvider<int>((ref) => 0);
final homePageSelectedIndexProvider = StateProvider<int>((ref) => 0);
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ThemeMode.light);
});
final fontSizeScaleProvider = StateProvider<double>((ref) => 1.0);

/// App language override: null follows the system locale; a value
/// pins the app to that locale. Persisted as the 'locale' preference.
final localeOverrideProvider = StateProvider<Locale?>((ref) => null);

// Search Filter States
final selectedTypeState = StateProvider<String>((ref) => "All");
final selectedSortState = StateProvider<String>((ref) => "Most Relevant");
final selectedFileTypeState = StateProvider<String>((ref) => "All");
final selectedLanguageState = StateProvider<String>((ref) => "All");
final selectedYearState = StateProvider<String>((ref) => "All");
final selectedSourceState = StateProvider<SearchProviderId?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => "");

// Advanced (metadata) search fields from the expandable panel. Empty
// strings mean "not filtering on this field".
final searchAuthorProvider = StateProvider<String>((ref) => "");
final searchPublisherProvider = StateProvider<String>((ref) => "");
final enableFiltersState = StateProvider<bool>((ref) => true);

// Web/Download States
final donationKeyProvider = StateProvider<String>((ref) => "");
final cookieProvider = StateProvider<String>((ref) => "");
final userAgentProvider = StateProvider<String>((ref) => "");
final webViewLoadingState = StateProvider.autoDispose<bool>((ref) => true);

// Download Settings
final showManualDownloadButtonProvider = StateProvider<bool>((ref) => false);

// DDoS challenge solving: headless (invisible) vs visible window.
// Default on - most devices clear DDoS-Guard headlessly. Devices where
// the invisible webview never finishes fall back better to a visible
// window, which the user turns on here.
final backgroundVerificationProvider = StateProvider<bool>((ref) => true);

// Mirror ordering mode. Auto (the default) follows open-slum.org's
// protection/latency priority; the user flips it to manual in
// Settings > Mirrors and orders the list by hand.
final instanceAutoModeProvider = StateProvider<bool>((ref) => true);

// Instance Management States
final instanceManagerProvider =
    Provider<InstanceManager>((ref) => InstanceManager());

// Download Manager States
final downloadManagerProvider = Provider<DownloadManager>((ref) {
  final manager = DownloadManager();
  ref.onDispose(() => manager.dispose());
  return manager;
});

final activeDownloadsProvider =
    StreamProvider<Map<String, DownloadTask>>((ref) {
  final manager = ref.watch(downloadManagerProvider);
  // The manager emits per network chunk; 10 progress updates per second is
  // all any of the progress UIs can show, and coalescing here keeps every
  // listening page from rebuilding dozens of times per second.
  return throttleLatest(
    manager.downloadsStream,
    const Duration(milliseconds: 100),
  );
});

/// Mirrors of one service (SLUM reading + the user's enable choice), as
/// shown in Settings > Mirrors.
final serviceInstancesProvider =
    FutureProvider.family<List<InstanceView>, MirrorService>((ref, service) {
  return ref.watch(instanceManagerProvider).instances(service);
});

@immutable
class MirrorLatencyState {
  const MirrorLatencyState({
    this.testing = false,
    this.testingHosts = const <String>{},
    this.readings = const <String, MirrorLatencyReading>{},
    this.loaded = false,
  });

  final bool testing;
  final Set<String> testingHosts;
  final Map<String, MirrorLatencyReading> readings;

  /// Whether persisted readings have been read at least once, so an empty
  /// [readings] map means "never tested" rather than "still loading".
  final bool loaded;

  MirrorLatencyState copyWith({
    bool? testing,
    Set<String>? testingHosts,
    Map<String, MirrorLatencyReading>? readings,
    bool? loaded,
  }) {
    return MirrorLatencyState(
      testing: testing ?? this.testing,
      testingHosts: testingHosts ?? this.testingHosts,
      readings: readings ?? this.readings,
      loaded: loaded ?? this.loaded,
    );
  }
}

/// True when no local latency reading is fresh enough to affect ordering.
bool hasFreshMirrorLatency(
    Map<String, MirrorLatencyReading> readings, DateTime now) {
  return readings.values.any((reading) => reading.isFreshAt(now));
}

/// The search page nudges the user after readings have loaded and every
/// stored reading is missing or older than 24 hours. It stays visible while
/// a test runs so the hint can show progress in place.
bool shouldShowMirrorLatencyHint(MirrorLatencyState state, DateTime now) {
  return state.loaded && !hasFreshMirrorLatency(state.readings, now);
}

@immutable
class MirrorLatencyResult {
  const MirrorLatencyResult({
    required this.total,
    required this.reachable,
    required this.fastestMs,
  });

  final int total;
  final int reachable;
  final int? fastestMs;
}

typedef MirrorLatencyMeasure = Future<Map<String, int?>> Function(
    Iterable<String> urls);

/// Runs one manual latency test over the enabled, non-down mirrors and
/// persists the readings. The page owns the trigger; this class owns the
/// filtering, in-flight state and storage merge.
class MirrorLatencyNotifier extends StateNotifier<MirrorLatencyState> {
  MirrorLatencyNotifier(
    this._manager,
    this._measure, {
    DateTime Function()? clock,
  })  : _clock = clock ?? DateTime.now,
        super(const MirrorLatencyState());

  final InstanceManager _manager;
  final MirrorLatencyMeasure _measure;
  final DateTime Function() _clock;

  Future<void> load() async {
    final readings = await _manager.localLatencies();
    if (mounted) state = state.copyWith(readings: readings, loaded: true);
  }

  Future<MirrorLatencyResult> test(Iterable<InstanceView> views) async {
    final targets = <SlumSite>[];
    final seen = <String>{};
    for (final view in views) {
      if (!view.enabled || view.site.isDown) continue;
      if (seen.add(view.site.host)) targets.add(view.site);
    }
    if (targets.isEmpty) {
      return const MirrorLatencyResult(
        total: 0,
        reachable: 0,
        fastestMs: null,
      );
    }

    final hosts = targets.map((site) => site.host).toSet();
    state = state.copyWith(testing: true, testingHosts: hosts);
    try {
      final results = await _measure(targets.map((site) => site.url));
      await _manager.saveLocalLatencies(results, testedAt: _clock());
      final readings = await _manager.localLatencies();
      if (mounted) {
        state = MirrorLatencyState(readings: readings, loaded: true);
      }

      var reachable = 0;
      int? fastest;
      for (final value in results.values) {
        if (value == null) continue;
        reachable++;
        if (fastest == null || value < fastest) fastest = value;
      }
      return MirrorLatencyResult(
        total: hosts.length,
        reachable: reachable,
        fastestMs: fastest,
      );
    } catch (_) {
      if (mounted) {
        state = state.copyWith(
          testing: false,
          testingHosts: const <String>{},
        );
      }
      rethrow;
    }
  }
}

final mirrorLatencyProvider =
    StateNotifierProvider<MirrorLatencyNotifier, MirrorLatencyState>((ref) {
  return MirrorLatencyNotifier(
    ref.watch(instanceManagerProvider),
    MirrorLatencyTester().measure,
  );
});

/// The Anna's Archive base URL the "open in site" button uses, or null
/// when no attemptable mirror is known.
///
/// Resolved here, not inside a widget's build: mirrors come from the
/// catalogue (network on a cold cache), and doing that during build
/// started I/O no widget test could settle - it left pending timers
/// behind. A bundled value keeps the button free of I/O and lets tests
/// stub the mirror.
final annaArchiveBaseUrlProvider = FutureProvider<String?>((ref) async {
  final urls = await ref
      .watch(instanceManagerProvider)
      .enabledUrls(MirrorService.annasArchive);
  if (urls.isEmpty) return null;
  final base = urls.first;
  return base.endsWith('/') ? base.substring(0, base.length - 1) : base;
});

// ====================================================================
// DERIVED (COMPUTED) STATE PROVIDERS
// ====================================================================

final getTypeValue = Provider.autoDispose<String>((ref) {
  return typeValues[ref.watch(selectedTypeState)] ?? '';
});

final getSortValue = Provider.autoDispose<String>((ref) {
  return sortValues[ref.watch(selectedSortState)] ?? '';
});

final getFileTypeValue = Provider.autoDispose<String>((ref) {
  final selectedFile = ref.watch(selectedFileTypeState);
  return selectedFile == "All" ? '' : selectedFile.toLowerCase();
});

final getLanguageValue = Provider.autoDispose<String>((ref) {
  return languageValues[ref.watch(selectedLanguageState)] ?? '';
});

final getYearValue = Provider.autoDispose<String>((ref) {
  return ref.watch(selectedYearState) == "All"
      ? ''
      : ref.watch(selectedYearState);
});

// ====================================================================
// ASYNCHRONOUS DATA (FUTURE) PROVIDERS
// ====================================================================

// Provider for Trending Books
final getTrendingBooks = FutureProvider<List<TrendingBookData>>((ref) async {
  // NOTE: Assuming TrendingBookData and the service classes exist and are functional
  GoodReads goodReads = GoodReads();
  // Assuming these classes are available from your project imports
  // ignore: prefer_const_constructors
  final penguinTrending = PenguinRandomHouse();
  // ignore: prefer_const_constructors
  final bookDigits = BookDigits();

  List<TrendingBookData> trendingBooks =
      await Future.wait<List<TrendingBookData>>([
    goodReads.trendingBooks(),
    penguinTrending.trendingBooks(),
    // openLibrary.trendingBooks(), // Commented out as in the original
    bookDigits.trendingBooks(),
  ]).then((List<List<TrendingBookData>> listOfData) =>
          listOfData.expand((element) => element).toList());

  if (trendingBooks.isEmpty) {
    throw Exception(
        'Nothing Trending Today :('); // Use Exception instead of String
  }
  trendingBooks.shuffle();
  return trendingBooks;
});

// Provider for Sub Category Books
final getSubCategoryTypeList = FutureProvider.family
    .autoDispose<List<CategoryBookData>, String>((ref, url) async {
  // NOTE: Assuming CategoryBookData and SubCategoriesTypeList exist
  // ignore: prefer_const_constructors
  SubCategoriesTypeList subCategoriesTypeList = SubCategoriesTypeList();
  List<CategoryBookData> subCategories =
      await subCategoriesTypeList.categoriesBooks(url: url);
  List<CategoryBookData> uniqueArray = subCategories.toSet().toList();
  uniqueArray.shuffle();
  return uniqueArray;
});

/// One page of search results: the query and the 1-based page number
/// ride together as the family key so page 2 of "docker" and page 1 of
/// "docker" are separate cache entries.
@immutable
class SearchPageKey {
  final String query;
  final int page;

  /// Restricts this page to one catalog. Null means the normal chain of
  /// enabled sources. A results route passes the source it was opened
  /// with, then pins deeper pages to the source that produced page 1.
  final SearchProviderId? source;

  /// The results page's "try anyway" escape from a local-timeout skip.
  final bool forceLocalTimeouts;

  const SearchPageKey(
    this.query,
    this.page, {
    this.source,
    this.forceLocalTimeouts = false,
  });

  @override
  bool operator ==(Object other) =>
      other is SearchPageKey &&
      other.query == query &&
      other.page == page &&
      other.source == source &&
      other.forceLocalTimeouts == forceLocalTimeouts;

  @override
  int get hashCode =>
      Object.hash(query, page, source, forceLocalTimeouts);
}

// Provider for one page of search results across all enabled providers
final searchProvider = FutureProvider.family
    .autoDispose<SearchManagerResult, SearchPageKey>((ref, key) async {
  if (key.query.isEmpty) {
    return const SearchManagerResult(books: [], failedProviders: []);
  }

  // A provider failure must not swallow results from the others: the
  // manager returns what it got and lists the stragglers by name.
  final manager = SearchManager();
  final enabled = await manager.enabledProviders();
  final source =
      key.source != null && enabled.contains(key.source) ? key.source : null;
  final result = await manager.search(SearchQuery(
    text: key.query,
    content: ref.watch(getTypeValue),
    sort: ref.watch(getSortValue),
    fileType: ref.watch(getFileTypeValue),
    language: ref.watch(getLanguageValue),
    year: ref.watch(getYearValue),
    author: ref.watch(searchAuthorProvider),
    publisher: ref.watch(searchPublisherProvider),
    filtersEnabled: ref.watch(enableFiltersState),
    page: key.page,
    source: source,
  ), forceLocalTimeouts: key.forceLocalTimeouts);
  final expectedCount = source == null ? enabled.length : 1;
  if (result.books.isEmpty &&
      result.failedProviders.length == expectedCount &&
      expectedCount > 0) {
    // Every enabled provider failed: surface a real error. One failing
    // provider with others merely finding nothing is NOT an error - an
    // empty result from a working source is a valid "no matches".
    throw Exception('All search sources are unreachable: '
        '${result.failedProviders.join(', ')}');
  }
  return result;
});

/// First page of a results route, streamed per source. The page paints as
/// soon as the first catalog answers; slower catalogs are filled in later.
final initialSearchProvider = StreamProvider.family
    .autoDispose<SearchManagerResult, SearchPageKey>((ref, key) {
  if (key.query.isEmpty) {
    return Stream.value(
        const SearchManagerResult(books: [], failedProviders: []));
  }
  final enabledSource = key.source;
  return SearchManager().watch(SearchQuery(
    text: key.query,
    content: ref.watch(getTypeValue),
    sort: ref.watch(getSortValue),
    fileType: ref.watch(getFileTypeValue),
    language: ref.watch(getLanguageValue),
    year: ref.watch(getYearValue),
    author: ref.watch(searchAuthorProvider),
    publisher: ref.watch(searchPublisherProvider),
    filtersEnabled: ref.watch(enableFiltersState),
    page: key.page,
    source: enabledSource,
  ), forceLocalTimeouts: key.forceLocalTimeouts);
});

// Which sources the user turned on in settings.
final searchProviderToggles = FutureProvider<Set<SearchProviderId>>(
    (ref) => SearchManager().enabledProviders());

// The order the user dragged the sources into in settings. Shared by the
// search capsules, the suggestions panel, the loading skeleton and the
// manager's chain, so every surface shows the same journey.
final searchSourceOrderProvider = FutureProvider<List<SearchProviderId>>(
    (ref) => SearchManager().sourceOrder());

// Provider for Book Info Details
//
// Routes by URL through routeBookDetail: libgen detail pages
// (ads.php?md5=), Z-Library /book/ pages, WeLib /md5/ pages, everything
// else to Anna's Archive. The route comes from the open-slum.org
// catalogue (which mirror belongs to which service), so it keeps working
// when SLUM lists a mirror this build never shipped - a hardcoded host
// list made every Z-Library result on a new mirror fail. Routing also
// matters because handing a provider's URL to Anna's used to swap its
// host for an AA mirror that does not carry the book (404 city).
final bookInfoProvider =
    FutureProvider.family<BookInfoData, String>((ref, url) async {
  final cached = await BookInfoCache.read(url);
  if (cached != null) return cached;
  final data = await _fetchBookInfo(ref, url);
  await BookInfoCache.write(url, data);
  return data;
});

Future<BookInfoData> _fetchBookInfo(Ref ref, String url) async {
  final route = await routeBookDetail(url);
  switch (route) {
    case BookDetailRoute.libgen:
      final data = await LibgenService().bookInfo(url);
      if (data == null) {
        throw Exception('Could not read this libgen book page');
      }
      return data;
    case BookDetailRoute.zlibrary:
      final data = await ZlibraryProvider().bookInfo(url);
      if (data == null) {
        throw Exception('Could not read this Z-Library book page');
      }
      return data;
    case BookDetailRoute.welib:
      final data = await WelibProvider().bookInfo(url);
      if (data == null) {
        throw Exception('Could not read this WeLib book page');
      }
      return data;
    case BookDetailRoute.annasArchive:
      final AnnasArchieve annasArchieve = AnnasArchieve();
      final donationKey = ref.watch(donationKeyProvider);
      return annasArchieve.bookInfo(url: url, donationKey: donationKey);
  }
}

// Completed download records
final myLibraryProvider = FutureProvider((ref) async {
  return dataBase.getAll();
});

/// Ids already in the library, resolved in one query so result cards can
/// check membership in memory instead of running a database query per row.
final downloadedBookIdsProvider = FutureProvider<Set<String>>((ref) async {
  final books = await ref.watch(myLibraryProvider.future);
  return books.map((book) => book.id).toSet();
});

final checkIdExists =
    FutureProvider.family.autoDispose<bool, String>((ref, id) async {
  return await dataBase.checkIdExists(id);
});

/// Lazily resolves a cover URL for a result that has none (LibGen
/// search rows ship without covers). Keyed by the book page URL so the
/// same book across pages shares one lookup; autoDispose keeps the
/// cache tied to what is on screen.
final resultCoverProvider =
    FutureProvider.family.autoDispose<String?, String>((ref, url) async {
  // Keep the resolved cover address briefly so scrolling a row away and
  // back reuses it instead of hitting ads.php again. The image bytes stay
  // in CachedNetworkImage's own cache.
  final keepAlive = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 10), keepAlive.close);
  ref.onDispose(timer.cancel);
  if (!url.contains('ads.php?md5=')) return null;
  return LibgenService().fetchCover(url);
});

final getBookByIdProvider =
    FutureProvider.family.autoDispose<MyBook?, String>((ref, id) async {
  return await dataBase.getId(id);
});

final deleteFileFromMyLib =
    FutureProvider.family<void, FileName>((ref, fileName) async {
  return await deleteFileWithDbData(ref, fileName.md5, fileName.format,
      fileName: fileName.fileName);
});
