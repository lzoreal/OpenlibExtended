import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/data/models/book_data.dart';
import 'package:openlib/state/state.dart' show annaArchiveBaseUrlProvider;
import 'package:openlib/ui/core/components/book_info_widget.dart';
import 'package:openlib/ui/core/themes.dart';

void main() {
  testWidgets('detail hero cover is 128x192 and title is 16/24 w800',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        annaArchiveBaseUrlProvider.overrideWith((ref) async => null),
      ],
      child: MaterialApp(
        theme: lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BookInfoWidget(
            data: BookInfoData(
              title: 'Book Title',
              author: 'Author',
              thumbnail: '',
              publisher: '',
              info: 'ISBN: 9787536692930',
              link: 'https://x',
              md5: 'm',
              format: 'PDF',
              mirror: null,
              description: 'Description',
            ),
            source: 'LibGen',
          ),
        ),
      ),
    ));

    expect(find.text('9787536692930'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('detail-cover'))),
      const Size(128, 192),
    );
    final title =
        tester.widget<Text>(find.byKey(const ValueKey('detail-title')));
    expect(title.style!.fontSize, 16);
    expect(title.style!.height, closeTo(24 / 16, 0.0001));
    expect(title.style!.fontWeight, FontWeight.w800);
    expect(
      tester.getSize(find.byKey(const ValueKey('detail-stamp'))).width,
      lessThan(160),
    );
  });
}
