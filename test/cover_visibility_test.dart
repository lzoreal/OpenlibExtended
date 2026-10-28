// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/state/state.dart'
    show downloadedBookIdsProvider, resultCoverProvider;
import 'package:openlib/ui/components/search_result_card.dart';
import 'package:openlib/ui/components/visible_builder.dart';

Widget _app(Widget child) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('VisibilityBuilder reports only on-screen rows', (tester) async {
    tester.view.physicalSize = const Size(400, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final visible = <int>{};
    await tester.pumpWidget(_app(
      ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) => SizedBox(
          height: 80,
          child: VisibilityBuilder(
            builder: (context, isVisible) {
              if (isVisible) visible.add(index);
              return Text('row $index ${isVisible ? 'on' : 'off'}');
            },
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(visible, containsAll([0, 1, 2]));
    expect(visible, isNot(contains(9)), reason: 'far rows are off-screen');

    visible.clear();
    await tester.drag(find.byType(ListView), const Offset(0, -320));
    await tester.pumpAndSettle();

    expect(visible, isNot(isEmpty));
    expect(visible, isNot(contains(0)),
        reason: 'row 0 has scrolled out of the viewport');
  });

  testWidgets('prefetchExtent marks just-offscreen rows as visible',
      (tester) async {
    tester.view.physicalSize = const Size(400, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final visible = <int>{};
    await tester.pumpWidget(_app(
      ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) => SizedBox(
          height: 100,
          child: VisibilityBuilder(
            prefetchExtent: 150,
            builder: (context, isVisible) {
              if (isVisible) visible.add(index);
              return Text('prefetch $index ${isVisible ? 'on' : 'off'}');
            },
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(visible, containsAll([0, 1, 2, 3]),
        reason: 'the next row starts loading before it enters the viewport');
    expect(visible, isNot(contains(5)));
  });

  testWidgets('downloaded badge comes from the shared id set',
      (tester) async {
    Future<void> pumpCard(Set<String> ids) {
      return tester.pumpWidget(ProviderScope(
        key: ValueKey(ids.toString()),
        overrides: [
          downloadedBookIdsProvider.overrideWith((ref) async => ids),
        ],
        child: _app(SearchResultCard(
          title: 'Downloaded',
          author: 'Author',
          thumbnail: null,
          info: 'English, EPUB, 1 MB',
          link: 'https://example.com/book',
          md5: 'book-1',
          onClick: () {},
        )),
      ));
    }

    await pumpCard({'book-1'});
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await pumpCard({'other'});
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_rounded), findsNothing);
  });

  testWidgets('search result covers are only looked up for visible rows',
      (tester) async {
    tester.view.physicalSize = const Size(400, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final lookups = <String>[];
    await tester.pumpWidget(ProviderScope(
      overrides: [
        resultCoverProvider.overrideWith((ref, link) {
          lookups.add(link);
          return Future<String?>.value(null);
        }),
      ],
      child: _app(ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) => SearchResultCard(
          title: 'Book $index',
          author: 'Author',
          thumbnail: null,
          info: 'English, EPUB, 1 MB',
          link: 'https://libgen.li/ads.php?md5=$index',
          md5: null,
          onClick: () {},
        ),
      )),
    ));
    await tester.pumpAndSettle();

    expect(lookups, isNotEmpty);
    expect(lookups.length, lessThan(20),
        reason: 'off-screen rows must not resolve their covers');

    final before = lookups.length;
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();

    expect(lookups.length, greaterThan(before),
        reason: 'newly visible rows resolve their covers');
  });
}
