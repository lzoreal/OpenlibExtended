// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/data/services/goodreads.dart';
import 'package:openlib/state/state.dart';
import 'package:openlib/ui/features/trending/views/categories_page.dart';

void main() {
  testWidgets('constrains the listing grid on wide screens', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final books = List.generate(
      6,
      (index) => CategoryBookData(
        title: 'Book $index',
        thumbnail: 'https://example.com/$index.jpg',
        link: 'https://example.com/book/$index',
      ),
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        getSubCategoryTypeList.overrideWith((ref, url) async => books),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CategoryListingPage(
          url: 'list/tag/classics',
          title: '经典',
        ),
      ),
    ));
    await tester.pump();

    final grid = find.byType(CustomScrollView);
    expect(tester.getSize(grid).width, 840);
    expect(tester.getTopLeft(grid).dx, (1600 - 840) / 2);
  });

  testWidgets('category cards show author, rating and year', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        getSubCategoryTypeList.overrideWith((ref, url) async => [
              CategoryBookData(
                title: '三体',
                thumbnail: 'https://example.com/book.jpg',
                link: 'https://example.com/book',
                author: '刘慈欣',
                rating: '4.3',
                published: '2008',
              ),
            ]),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CategoryListingPage(
          url: 'list/tag/classics',
          title: '经典',
        ),
      ),
    ));
    await tester.pump();

    expect(find.text('刘慈欣'), findsOneWidget);
    expect(find.text('★ 4.3 · 2008'), findsOneWidget);
  });

  testWidgets('category card keeps author, rating and year inside the card',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        getSubCategoryTypeList.overrideWith((ref, url) async => [
              CategoryBookData(
                title: 'Pride and Prejudice (Hardcover)',
                thumbnail: 'https://example.com/book.jpg',
                link: 'https://example.com/book',
                author: 'Jane Austen',
                rating: '4.30',
                published: '1813',
              ),
            ]),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CategoryListingPage(
          url: 'list/tag/classics',
          title: '经典',
        ),
      ),
    ));
    await tester.pump();

    final card = find.byType(Card).first;
    final cardBottom = tester.getBottomLeft(card).dy;
    expect(
      tester.getBottomLeft(find.text('★ 4.30 · 1813')).dy,
      lessThanOrEqualTo(cardBottom),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('category card fits its meta lines at 200% text', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        getSubCategoryTypeList.overrideWith((ref, url) async => [
              CategoryBookData(
                title: 'Pride and Prejudice (Hardcover)',
                thumbnail: 'https://example.com/book.jpg',
                link: 'https://example.com/book',
                author: 'Jane Austen',
                rating: '4.30',
                published: '1813',
              ),
            ]),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: const CategoryListingPage(
              url: 'list/tag/classics',
              title: '经典',
            ),
          ),
        ),
      ),
    ));
    await tester.pump();

    final card = find.byType(Card).first;
    expect(
      tester.getBottomLeft(find.text('★ 4.30 · 1813')).dy,
      lessThanOrEqualTo(tester.getBottomLeft(card).dy),
    );
    expect(tester.takeException(), isNull);
  });
}
