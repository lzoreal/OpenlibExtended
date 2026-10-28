// The download center replaces the old library tab. These tests pin the
// three states that matter: empty, active task, and a completed record.

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/data/models/my_book.dart';
import 'package:openlib/data/services/download_manager.dart';
import 'package:openlib/ui/features/library/view_models/library_view_model.dart';
import 'package:openlib/ui/features/library/views/download_center_page.dart';

import 'helpers/library_test_support.dart';

void main() {
  Future<LibraryViewModel> pumpCenter(
    WidgetTester tester, {
    Map<String, DownloadTask> downloads = const {},
    List<CompletedDownload> completed = const [],
    TextScaler textScaler = TextScaler.noScaling,
    VoidCallback? onBrowseSearch,
  }) async {
    final viewModel = testLibraryViewModel(
      library: TestLibraryRepository(
        books: [for (final item in completed) item.book],
      ),
      downloads: TestDownloadRepository(initial: downloads),
    );
    addTearDown(viewModel.dispose);
    await viewModel.load();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
        home: Scaffold(
          body: DownloadCenterPage(
            viewModel: viewModel,
            onBrowseSearch: onBrowseSearch,
          ),
        ),
      ),
    );
    await tester.pump();
    return viewModel;
  }

  Future<void> disposePage(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }

  testWidgets('shows the empty state with a search action', (tester) async {
    await pumpCenter(tester);

    expect(find.text('下载中心'), findsOneWidget);
    expect(find.text('还没有下载任务'), findsOneWidget);
    expect(find.text('去搜索'), findsOneWidget);

    await disposePage(tester);
  });

  testWidgets('renders an active task with aggregate progress', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpCenter(tester, downloads: {
      'task-1': DownloadTask(
        id: 'task-1',
        md5: 'md5',
        title: '测试书',
        author: '测试作者',
        format: 'epub',
        link: 'https://example.com/book',
        mirrors: const ['https://libgen.example/get.php?id=1'],
        status: DownloadStatus.downloading,
        progress: 0.5,
        downloadedBytes: 50,
        totalBytes: 100,
      ),
    });

    expect(find.text('测试书'), findsWidgets);
    expect(find.text('50%'), findsWidgets);
    expect(find.text('进行中'), findsWidgets);
    expect(
      tester.getSize(find.byKey(const ValueKey('download-cover'))),
      const Size(64, 96),
    );

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.tabs.length, 3);
    expect(
      tester.getSize(find.byKey(const ValueKey('pill-tabs-track'))).height,
      44,
    );

    await disposePage(tester);
  });

  testWidgets('swiping tabs filters active and completed work', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpCenter(
      tester,
      downloads: {
        'task-1': DownloadTask(
          id: 'task-1',
          md5: 'md5',
          title: '测试书',
          author: '测试作者',
          format: 'epub',
          link: 'https://example.com/book',
          mirrors: const ['https://libgen.example/get.php?id=1'],
          status: DownloadStatus.downloading,
          progress: 0.5,
          downloadedBytes: 50,
          totalBytes: 100,
        ),
      },
      completed: [
        CompletedDownload(
          book: MyBook(
            id: 'book-1',
            title: '已完成的书',
            author: '作者',
            thumbnail: null,
            link: 'https://example.com/book',
            publisher: null,
            info: null,
            format: 'epub',
            description: null,
            fileName: 'book.epub',
          ),
          sizeBytes: 2 * 1024 * 1024,
          modifiedAt: DateTime.now(),
        ),
      ],
    );

    await tester.fling(
      find.byType(TabBarView),
      const Offset(-320, 0),
      1200,
    );
    await tester.pumpAndSettle();
    expect(find.text('测试书'), findsWidgets);
    expect(find.text('已完成的书'), findsNothing);

    await tester.fling(
      find.byType(TabBarView),
      const Offset(-320, 0),
      1200,
    );
    await tester.pumpAndSettle();
    expect(find.text('测试书'), findsNothing);
    expect(find.text('已完成的书'), findsOneWidget);

    await disposePage(tester);
  });

  testWidgets('download task survives 200% text scale', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpCenter(
      tester,
      textScaler: const TextScaler.linear(2),
      downloads: {
        'task-1': DownloadTask(
          id: 'task-1',
          md5: 'md5',
          title: '测试书',
          author: '测试作者',
          format: 'epub',
          link: 'https://example.com/book',
          mirrors: const ['https://libgen.example/get.php?id=1'],
          status: DownloadStatus.downloading,
          progress: 0.5,
          downloadedBytes: 50,
          totalBytes: 100,
        ),
      },
    );

    expect(find.text('50%'), findsWidgets);
    expect(tester.takeException(), isNull);

    await disposePage(tester);
  });

  testWidgets('renders a completed record with an open action', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpCenter(tester, completed: [
      CompletedDownload(
        book: MyBook(
          id: 'book-1',
          title: '已完成的书',
          author: '作者',
          thumbnail: null,
          link: 'https://example.com/book',
          publisher: null,
          info: null,
          format: 'epub',
          description: null,
          fileName: 'book.epub',
        ),
        sizeBytes: 2 * 1024 * 1024,
        modifiedAt: DateTime.now(),
      ),
    ]);

    expect(find.text('已完成的书'), findsOneWidget);
    expect(find.text('打开'), findsOneWidget);
    expect(find.text('已完成'), findsWidgets);

    // The status chip and the open button read as one control group:
    // same height, not one tall pill next to a shorter button.
    final status =
        tester.getSize(find.byKey(const ValueKey('completed-status-pill')));
    final open =
        tester.getSize(find.byKey(const ValueKey('completed-open-button')));
    expect(status.height, 36);
    expect(open.height, status.height);

    await disposePage(tester);
  });

  testWidgets('remove-record dialog offers deleting the local file',
      (tester) async {
    await pumpCenter(tester, completed: [
      CompletedDownload(
        book: MyBook(
          id: 'book-1',
          title: '已完成的书',
          author: '作者',
          thumbnail: null,
          link: 'https://example.com/book',
          publisher: null,
          info: null,
          format: 'epub',
          description: null,
          fileName: 'book.epub',
        ),
        sizeBytes: 2 * 1024 * 1024,
        modifiedAt: DateTime.now(),
      ),
    ]);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除记录'));
    await tester.pumpAndSettle();

    expect(find.text('同时移除文件'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);

    await tester.tap(find.text('同时移除文件'));
    await tester.pump();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);

    await disposePage(tester);
  });

  testWidgets('completed list drops the stats row and the hint',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpCenter(tester, completed: [
      CompletedDownload(
        book: MyBook(
          id: 'book-1',
          title: '已完成的书',
          author: '作者',
          thumbnail: null,
          link: 'https://example.com/book',
          publisher: null,
          info: null,
          format: 'epub',
          description: null,
          fileName: 'book.epub',
        ),
        sizeBytes: 2 * 1024 * 1024,
        modifiedAt: DateTime.now(),
      ),
    ]);

    // The 0 / 1 / 0 counters and the "tap a title" hint are both gone.
    expect(find.text('0'), findsNothing);
    expect(find.text('点书名看详情 · 点打开用外部阅读器'), findsNothing);

    await disposePage(tester);
  });

  testWidgets('selects completed records and deletes them as one batch',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    MyBook book(String id) => MyBook(
          id: id,
          title: '书 $id',
          author: '作者',
          thumbnail: null,
          link: 'https://example.com/$id',
          publisher: null,
          info: null,
          format: 'epub',
          description: null,
          fileName: '$id.epub',
        );

    await pumpCenter(tester, completed: [
      CompletedDownload(
        book: book('a'),
        sizeBytes: 1024,
        modifiedAt: DateTime(2026, 10, 28, 12),
      ),
      CompletedDownload(
        book: book('b'),
        sizeBytes: 1024,
        modifiedAt: DateTime(2026, 10, 27, 12),
      ),
    ]);

    await tester.tap(find.byTooltip('选择'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(Checkbox), findsNWidgets(2));
    expect(find.text('已选 0 项'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    expect(find.text('已选 1 项'), findsOneWidget);

    await tester.tap(find.text('删除 1 项'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('书 a'), findsNothing);
    expect(find.text('书 b'), findsOneWidget);
    expect(find.text('已选 0 项'), findsNothing);

    await disposePage(tester);
  });
}
