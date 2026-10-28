// The search page's filter chips and option sheets are built from values
// that stay English on disk (saved preferences and provider queries), so
// this pins the display-only translation layer.

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/data/repositories/mirror_repository.dart';
import 'package:openlib/data/services/instance_manager.dart';
import 'package:openlib/data/services/preference_store.dart';
import 'package:openlib/state/repository_providers.dart'
    show mirrorRepositoryProvider;
import 'package:openlib/ui/categories_page.dart';
import 'package:openlib/ui/search_page.dart';

void main() {
  test('genre cards use the localized title and description', () {
    final zh = lookupAppLocalizations(const Locale('zh'));
    final categories = categoriesTypeValues(zh);

    expect(categories.first.title, '经典');
    expect(categories.first.info, contains('文学'));
    expect(categories.any((c) => c.title == 'Classics'), isFalse);
  });

  testWidgets('search filters render and open in Chinese', (tester) async {
    // The filter option sheet is taller than the default 800x600 test
    // viewport; give it room so the check exercises labels, not layout.
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // The page resolves its mirrors through DI; tests do not run initDi.
          mirrorRepositoryProvider.overrideWithValue(MirrorRepository(
            manager: InstanceManager.forTest(store: MemoryPreferenceStore()),
          )),
        ],
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: SearchPage()),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('搜索建议'), findsOneWidget);
    await tester.tap(find.text('高级搜索'));
    await tester.pumpAndSettle();

    expect(find.text('作者'), findsOneWidget);
    expect(find.text('出版社'), findsOneWidget);
    expect(find.text('类型: 全部'), findsOneWidget);
    expect(find.text('排序方式'), findsOneWidget);
    expect(find.text('文件类型'), findsOneWidget);
    expect(find.text('语言'), findsOneWidget);
    expect(find.text('出版年份'), findsOneWidget);

    await tester.ensureVisible(find.text('类型: 全部'));
    await tester.pump();
    await tester.tap(find.text('类型: 全部'));
    await tester.pumpAndSettle();

    expect(find.text('任意书籍'), findsOneWidget);
    expect(find.text('漫画书'), findsOneWidget);
    expect(find.text('Any Books'), findsNothing);
  });
}
