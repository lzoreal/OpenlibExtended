import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/data/services/download_manager.dart' show DownloadTask;
import 'package:openlib/data/models/trending_book_data.dart'
    show TrendingBookData;
import 'package:openlib/state/state.dart'
    show
        activeDownloadsProvider,
        getTrendingBooks,
        homePageSelectedIndexProvider;
import 'package:openlib/ui/features/trending/views/categories_page.dart' show GenreShortcutSection;
import 'package:openlib/ui/features/shell/views/home_page.dart';
import 'package:openlib/ui/core/themes.dart';
import 'package:openlib/ui/features/trending/views/trending_page.dart';

void main() {
  testWidgets('trending poster is 128 wide with a 192-high cover',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        getTrendingBooks.overrideWith((ref) async => [
              TrendingBookData(title: 'Book', thumbnail: ''),
            ]),
      ],
      child: MaterialApp(
        theme: lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: TrendingPage()),
      ),
    ));
    await tester.pumpAndSettle();

    final poster = find.byKey(const ValueKey('trending-poster')).first;
    expect(tester.getSize(poster).width, 128);
    expect(
      tester.getSize(find.byKey(const ValueKey('trending-cover')).first).height,
      192,
    );
  });

  testWidgets('home tabs use the settings pill track and swipe',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        getTrendingBooks.overrideWith((ref) async => const []),
        activeDownloadsProvider.overrideWith(
          (ref) => Stream.value(const <String, DownloadTask>{}),
        ),
      ],
      child: MaterialApp(
        theme: lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: HomePage()),
      ),
    ));
    await tester.pump();

    final track = find.byKey(const ValueKey('pill-tabs-track'));
    expect(tester.getSize(track).height, 44);
    expect(
      tester.getSize(find.byKey(const ValueKey('home-search-field'))).height,
      52,
    );
    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.labelStyle?.fontSize, 12);
    expect(tabBar.labelStyle?.fontWeight, FontWeight.w800);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomePage)),
    );
    expect(container.read(homePageSelectedIndexProvider), 0);

    await tester.fling(
      find.byType(TabBarView),
      const Offset(-320, 0),
      1200,
    );
    await tester.pumpAndSettle();

    expect(container.read(homePageSelectedIndexProvider), 1);
  });

  testWidgets('home fits 200% text and keeps swipeable tabs', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        getTrendingBooks.overrideWith((ref) async => const []),
        activeDownloadsProvider.overrideWith(
          (ref) => Stream.value(const <String, DownloadTask>{}),
        ),
      ],
      child: MaterialApp(
        theme: lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: const Scaffold(body: HomePage()),
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.fling(
      find.byType(TabBarView),
      const Offset(-320, 0),
      1200,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('genre shortcut tiles are 64 high', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: 360,
            child: GenreShortcutSection(title: 'Genres', count: 2),
          ),
        ),
      ),
    ));

    expect(tester.getSize(find.byType(Card).first).height, 64);
  });

  testWidgets('trending strip and genre tiles grow with 200% text',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        getTrendingBooks.overrideWith((ref) async => [
              TrendingBookData(title: 'Book', thumbnail: ''),
            ]),
      ],
      child: MaterialApp(
        theme: lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: const Scaffold(body: TrendingPage()),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(const ValueKey('trending-strip'))).height,
      264,
    );

    await tester.pumpWidget(MaterialApp(
      theme: lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: const Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 360,
              child: GenreShortcutSection(title: 'Genres', count: 2),
            ),
          ),
        ),
      ),
    ));
    expect(tester.getSize(find.byType(Card).first).height, 92);
  });
}
