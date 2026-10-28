// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/data/services/download_manager.dart'
    show DownloadStatus;
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/ui/core/components/active_downloads_widget.dart';
import 'package:openlib/ui/core/themes.dart';
import 'package:openlib/ui/features/shell/view_models/active_downloads_view_model.dart';

import 'helpers/book_detail_test_support.dart';

void main() {
  testWidgets('failed tasks can be dismissed in either direction',
      (tester) async {
    final downloads = FakeDownloadRepository(active: {
      'a': testDownloadTask(md5: 'a', status: DownloadStatus.failed),
      'b': testDownloadTask(md5: 'b', status: DownloadStatus.failed),
    });
    addTearDown(downloads.close);
    final viewModel = ActiveDownloadsViewModel(downloads: downloads);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(MaterialApp(
      theme: lightTheme,
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: ActiveDownloadsWidget(viewModel: viewModel)),
    ));
    await tester.pump();

    const first = ValueKey('active-download-task-a');
    const second = ValueKey('active-download-task-b');
    expect(find.byKey(first), findsOneWidget);
    expect(find.byKey(second), findsOneWidget);

    await tester.drag(find.byKey(first), const Offset(600, 0));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 150));
    expect(downloads.cancelled, ['task-a']);
    expect(find.byKey(second), findsOneWidget);

    await tester.drag(find.byKey(second), const Offset(-600, 0));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 150));
    expect(downloads.cancelled, ['task-a', 'task-b']);
    expect(find.byType(Card), findsNothing);
  });

  testWidgets('completed tasks can be swiped away too', (tester) async {
    final downloads = FakeDownloadRepository(active: {
      'done': testDownloadTask(md5: 'done', status: DownloadStatus.completed),
      'busy': testDownloadTask(md5: 'busy', status: DownloadStatus.downloading),
    });
    addTearDown(downloads.close);
    final viewModel = ActiveDownloadsViewModel(downloads: downloads);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(MaterialApp(
      theme: lightTheme,
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: ActiveDownloadsWidget(viewModel: viewModel)),
    ));
    await tester.pump();

    await tester.drag(
      find.byKey(const ValueKey('active-download-task-done')),
      const Offset(600, 0),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 150));

    expect(downloads.cancelled, ['task-done']);
    // The running task stays, without a swipe affordance.
    expect(find.text('Title'), findsOneWidget);
    expect(find.byType(Dismissible), findsNothing);
  });

  testWidgets('tasks that are still running cannot be dismissed', (tester) async {
    final downloads = FakeDownloadRepository(active: {
      'a': testDownloadTask(md5: 'a', status: DownloadStatus.downloading),
    });
    addTearDown(downloads.close);
    final viewModel = ActiveDownloadsViewModel(downloads: downloads);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(MaterialApp(
      theme: lightTheme,
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: ActiveDownloadsWidget(viewModel: viewModel)),
    ));
    await tester.pump();

    expect(find.byType(Dismissible), findsNothing);
    expect(downloads.cancelled, isEmpty);
  });
}
