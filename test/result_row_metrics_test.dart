import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/ui/components/search_result_card.dart';
import 'package:openlib/ui/themes.dart';

void main() {
  testWidgets('result row is 96 high with a 56x80 cover', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 360,
              height: 96,
              child: SearchResultCard(
                title: 'Book',
                author: 'Author',
                thumbnail: null,
                info: 'PDF',
                link: 'https://x',
                onClick: () {},
              ),
            ),
          ),
        ),
      ),
    ));

    final cover = find.byKey(const ValueKey('result-cover'));
    expect(tester.getSize(cover), const Size(56, 80));
    expect(tester.getSize(find.byType(SearchResultCard)), const Size(360, 96));
  });
}
