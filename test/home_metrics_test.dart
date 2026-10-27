import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/services/open_library.dart' show TrendingBookData;
import 'package:openlib/state/state.dart' show getTrendingBooks;
import 'package:openlib/ui/categories_page.dart' show GenreShortcutSection;
import 'package:openlib/ui/themes.dart';
import 'package:openlib/ui/trending_page.dart';

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
}
