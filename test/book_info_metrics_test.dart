import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/services/annas_archieve.dart';
import 'package:openlib/state/state.dart' show annaArchiveBaseUrlProvider;
import 'package:openlib/ui/components/book_info_widget.dart';
import 'package:openlib/ui/themes.dart';

void main() {
  testWidgets('detail hero cover is 112x168 and title is 16/24 w800',
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
              info: '',
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

    expect(
      tester.getSize(find.byKey(const ValueKey('detail-cover'))),
      const Size(112, 168),
    );
    final title =
        tester.widget<Text>(find.byKey(const ValueKey('detail-title')));
    expect(title.style!.fontSize, 16);
    expect(title.style!.height, closeTo(24 / 16, 0.0001));
    expect(title.style!.fontWeight, FontWeight.w800);
  });
}
