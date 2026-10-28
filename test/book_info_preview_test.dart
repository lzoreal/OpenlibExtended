import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/data/models/book_data.dart';
import 'package:openlib/state/state.dart'
    show annaArchiveBaseUrlProvider, bookInfoProvider;
import 'package:openlib/ui/book_info_page.dart';
import 'package:openlib/ui/themes.dart';

void main() {
  BookData preview() => BookData(
        title: 'Preview Title',
        author: 'Preview Author',
        thumbnail: '',
        link: 'https://example.com/md5/abc',
        md5: 'abc',
        info: 'English · EPUB · 4 MB',
      );

  BookInfoData details() => BookInfoData(
        title: 'Preview Title',
        author: 'Preview Author',
        thumbnail: '',
        publisher: 'Preview Press',
        info: 'English · EPUB · 4 MB',
        link: 'https://example.com/md5/abc',
        md5: 'abc',
        format: 'EPUB',
        mirror: null,
        description: 'The real description.',
      );

  Widget app(Future<BookInfoData> Function() load) => ProviderScope(
        overrides: [
          annaArchiveBaseUrlProvider.overrideWith((ref) async => null),
          bookInfoProvider.overrideWith((ref, url) => load()),
        ],
        child: MaterialApp(
          theme: lightTheme,
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BookInfoPage(
            url: 'https://example.com/md5/abc',
            source: 'LibGen',
            preview: preview(),
          ),
        ),
      );

  testWidgets('paints the result row while the details load', (tester) async {
    final pending = Completer<BookInfoData>();
    await tester.pumpWidget(app(() => pending.future));
    await tester.pump();

    expect(find.text('Preview Title'), findsWidgets);
    expect(find.text('Preview Author'), findsOneWidget);
    expect(find.text('EPUB'), findsWidgets);
    expect(find.text('4 MB'), findsWidgets);
    expect(
      find.byKey(const ValueKey('detail-description-skeleton')),
      findsOneWidget,
    );
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    final loadingButton = tester.widget<ButtonStyleButton>(
      find.byKey(const ValueKey('detail-loading-download')),
    );
    expect(loadingButton.onPressed, isNull);

    pending.complete(details());
    await tester.pump();
    await tester.pump();

    expect(
      find.byKey(const ValueKey('detail-description-skeleton')),
      findsNothing,
    );
    expect(find.text('The real description.'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('keeps the preview and offers a retry when details fail',
      (tester) async {
    await tester.pumpWidget(app(
      () => Future<BookInfoData>.error(Exception('mirror down')),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.text('Preview Title'), findsWidgets);
    expect(find.text('无法加载书籍详情'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('detail-description-skeleton')),
      findsNothing,
    );
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });
}
