// The book info page must expose its text for copying: SelectionArea wraps
// the scroll view so the title, author, metadata and description are
// selectable. Actions now live in the page's bottom bar, outside the
// selection area.

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/data/models/book_detail_source.dart';
import 'package:openlib/state/state.dart' show annaArchiveBaseUrlProvider;
import 'package:openlib/ui/core/components/book_info_widget.dart';

class _FakeBookData implements BookDetailSource {
  @override
  final String? format = 'epub';
  @override
  final String md5 = '7b2e2c05501894b229e309e39ec0d05d';
  @override
  final String link =
      'https://annas-archive.gl/md5/7b2e2c05501894b229e309e39ec0d05d';
  @override
  final String title = 'Structure of Scientific Revolutions';
  @override
  final String author = 'Thomas S. Kuhn';
  @override
  final String publisher = 'University of Chicago Press';
  @override
  final String info = 'English [en], EPUB, 1.5MB, 2012';
  @override
  final String thumbnail = '';
  @override
  final String description =
      'A book about paradigm shifts in science and how they reshape whole fields.';
}

void main() {
  testWidgets('book info text is selectable for copying', (tester) async {
    final data = _FakeBookData();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        // The "open in site" button resolves its mirror through the
        // catalogue provider; this test is about text selection, so the
        // mirror is stubbed instead of letting build() start I/O.
        annaArchiveBaseUrlProvider.overrideWith((ref) async => null),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BookInfoWidget(data: data),
        ),
      ),
    ));

    await tester.pump();

    // The selectable region wraps the text content.
    expect(find.byType(SelectionArea), findsOneWidget);

    // Title, author, publisher and description all render inside it. The
    // title also appears in the cover fallback, and author/publisher share
    // the byline.
    expect(find.text(data.title), findsWidgets);
    expect(find.textContaining(data.author), findsOneWidget);
    expect(find.textContaining(data.publisher), findsOneWidget);
    expect(find.text(data.description), findsOneWidget);
  });
}
