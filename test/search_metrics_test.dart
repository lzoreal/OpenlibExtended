import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/services/search_manager.dart';
import 'package:openlib/state/state.dart';
import 'package:openlib/ui/search_page.dart';
import 'package:openlib/ui/themes.dart';

void main() {
  testWidgets('search field is 48 high and mode switch is 44', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        getTrendingBooks.overrideWith((ref) async => const []),
        searchProviderToggles.overrideWith(
          (ref) async => {SearchProviderId.libgen},
        ),
      ],
      child: MaterialApp(
        theme: lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SearchPage(),
      ),
    ));
    await tester.pump();

    expect(tester.getSize(find.byType(SearchBar)).height, 48);
    expect(
      tester.getSize(find.byKey(const ValueKey('search-mode-switch'))).height,
      44,
    );
  });
}
