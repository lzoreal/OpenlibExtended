import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/data/models/search_result.dart';
import 'package:openlib/data/repositories/mirror_repository.dart';
import 'package:openlib/data/services/download_manager.dart' show DownloadTask;
import 'package:openlib/data/services/instance_manager.dart';
import 'package:openlib/data/services/preference_store.dart';
import 'package:openlib/state/repository_providers.dart'
    show mirrorRepositoryProvider;
import 'package:openlib/state/state.dart';
import 'package:openlib/ui/features/shell/views/home_page.dart';
import 'package:openlib/ui/features/search/views/search_page.dart';
import 'package:openlib/ui/core/themes.dart';

/// The search page resolves its mirrors through DI; tests do not run initDi.
Override _mirrorOverride() =>
    mirrorRepositoryProvider.overrideWithValue(MirrorRepository(
      manager: InstanceManager.forTest(store: MemoryPreferenceStore()),
    ));

void main() {
  testWidgets('search field is 52 high and tabs use the pill track',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        _mirrorOverride(),
        getTrendingBooks.overrideWith((ref) async => const []),
        searchProviderToggles.overrideWith(
          (ref) async => {SearchProviderId.libgen},
        ),
      ],
      child: MaterialApp(
        theme: lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: SearchPage()),
      ),
    ));
    await tester.pump();

    expect(tester.getSize(find.byType(SearchBar)).height, 52);
    expect(
      tester.getSize(find.byKey(const ValueKey('pill-tabs-track'))).height,
      44,
    );
    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.labelStyle?.fontWeight, FontWeight.w800);

    await tester.fling(
      find.byType(TabBarView),
      const Offset(-320, 0),
      1200,
    );
    await tester.pumpAndSettle();

    expect(find.text('Author'), findsOneWidget);
  });

  testWidgets('search tabs fit 200% text and still swipe', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        _mirrorOverride(),
        searchProviderToggles.overrideWith(
          (ref) async => {SearchProviderId.libgen},
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
            child: const Scaffold(body: SearchPage()),
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

    expect(find.text('Author'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('discovery and search fields start at the same offset',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Future<void> pumpPage(Widget page) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          _mirrorOverride(),
          getTrendingBooks.overrideWith((ref) async => const []),
          activeDownloadsProvider.overrideWith(
            (ref) => Stream.value(const <String, DownloadTask>{}),
          ),
          searchProviderToggles.overrideWith(
            (ref) async => {SearchProviderId.libgen},
          ),
        ],
        child: MaterialApp(
          theme: lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: page),
        ),
      ));
      await tester.pump();
    }

    await pumpPage(const HomePage());
    final homeField = find.byKey(const ValueKey('home-search-field'));
    final homeTop = tester.getTopLeft(homeField).dy;

    await pumpPage(const SearchPage());
    final searchTop = tester.getTopLeft(find.byType(SearchBar)).dy;

    expect(homeTop, searchTop);
  });
}
