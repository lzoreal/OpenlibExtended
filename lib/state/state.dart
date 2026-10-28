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
import 'package:openlib/app/app_settings.dart';
import 'package:openlib/app/di.dart';
import 'package:openlib/data/models/search_result.dart';
import 'package:openlib/data/models/trending_book_data.dart';
import 'package:openlib/data/services/database.dart';
import 'package:openlib/data/services/goodreads.dart';
import 'package:openlib/data/services/instance_manager.dart';
import 'package:openlib/data/services/mirror_latency_controller.dart';
import 'package:openlib/data/services/download_manager.dart';
import 'package:openlib/data/repositories/download_repository.dart';
import 'package:openlib/data/services/stream_throttle.dart';
import 'package:openlib/state/repository_providers.dart';

export 'package:openlib/data/services/mirror_latency_controller.dart';

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

/// Source of truth for the search filters while the search page moves off
/// Riverpod; the providers below stay read-only bridges until W5/W6.
final appSettingsProvider =
    ChangeNotifierProvider<AppSettings>((ref) => getIt<AppSettings>());

// Search Filter States
final selectedTypeState =
    Provider<String>((ref) => ref.watch(appSettingsProvider).filters.type);
final selectedSortState =
    Provider<String>((ref) => ref.watch(appSettingsProvider).filters.sort);
final selectedFileTypeState =
    Provider<String>((ref) => ref.watch(appSettingsProvider).filters.fileType);
final selectedLanguageState =
    Provider<String>((ref) => ref.watch(appSettingsProvider).filters.language);
final selectedYearState =
    Provider<String>((ref) => ref.watch(appSettingsProvider).filters.year);

// Advanced (metadata) search fields from the expandable panel. Empty
// strings mean "not filtering on this field".
final searchAuthorProvider =
    Provider<String>((ref) => ref.watch(appSettingsProvider).searchAuthor);
final searchPublisherProvider =
    Provider<String>((ref) => ref.watch(appSettingsProvider).searchPublisher);
final enableFiltersState =
    Provider<bool>((ref) => ref.watch(appSettingsProvider).filtersEnabled);

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

// Download Manager States
// No onDispose: DownloadManager is process-wide, and closing its broadcast
// controller is irreversible.
final downloadManagerProvider = Provider<DownloadRepository>((ref) {
  return ref.watch(downloadRepositoryProvider);
});

final activeDownloadsProvider =
    StreamProvider<Map<String, DownloadTask>>((ref) {
  final repository = ref.watch(downloadRepositoryProvider);
  // The manager emits per network chunk; 10 progress updates per second is
  // all any of the progress UIs can show, and coalescing here keeps every
  // listening page from rebuilding dozens of times per second.
  return throttleLatest(
    repository.updates,
    const Duration(milliseconds: 100),
  );
});

/// Mirrors of one service (SLUM reading + the user's enable choice), as
/// shown in Settings > Mirrors.
final serviceInstancesProvider =
    FutureProvider.family<List<InstanceView>, MirrorService>((ref, service) {
  return ref.watch(mirrorRepositoryProvider).instances(service);
});

final mirrorLatencyProvider =
    ChangeNotifierProvider<MirrorLatencyNotifier>(
        (ref) => getIt<MirrorLatencyNotifier>());

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
      .watch(mirrorRepositoryProvider)
      .enabledUrls(MirrorService.annasArchive);
  if (urls.isEmpty) return null;
  final base = urls.first;
  return base.endsWith('/') ? base.substring(0, base.length - 1) : base;
});

// ====================================================================
// DERIVED (COMPUTED) STATE PROVIDERS
// ====================================================================

// ====================================================================
// ASYNCHRONOUS DATA (FUTURE) PROVIDERS
// ====================================================================

// Provider for Trending Books
final getTrendingBooks = FutureProvider<List<TrendingBookData>>((ref) async {
  final trendingBooks =
      await ref.watch(trendingRepositoryProvider).trendingBooks();

  if (trendingBooks.isEmpty) {
    throw Exception('Nothing Trending Today :(');
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

// Which sources the user turned on in settings.
final searchProviderToggles = FutureProvider<Set<SearchProviderId>>(
    (ref) => ref.watch(searchRepositoryProvider).enabledProviders());

// The order the user dragged the sources into in settings. Shared by the
// search capsules, the suggestions panel, the loading skeleton and the
// manager's chain, so every surface shows the same journey.
final searchSourceOrderProvider = FutureProvider<List<SearchProviderId>>(
    (ref) => ref.watch(searchRepositoryProvider).sourceOrder());

// Completed download records
final myLibraryProvider = FutureProvider((ref) async {
  return ref.watch(libraryRepositoryProvider).allBooks();
});
