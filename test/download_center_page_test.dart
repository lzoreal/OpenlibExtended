// The download center replaces the old library tab. These tests pin the
// three states that matter: empty, active task, and a completed record.

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/services/database.dart';
import 'package:openlib/services/download_manager.dart';
import 'package:openlib/state/state.dart' show activeDownloadsProvider;
import 'package:openlib/ui/download_center_page.dart';

void main() {
  Widget app({
    Map<String, DownloadTask> downloads = const {},
    List<CompletedDownload> completed = const [],
    TextScaler textScaler = TextScaler.noScaling,
  }) {
    return ProviderScope(
      overrides: [
        activeDownloadsProvider.overrideWith((ref) => Stream.value(downloads)),
        completedDownloadsProvider.overrideWith((ref) async => completed),
      ],
      child: MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
        home: const Scaffold(body: DownloadCenterPage()),
      ),
    );
  }

  Future<void> disposePage(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }

  testWidgets('shows the empty state with a search action', (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();

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

    await tester.pumpWidget(app(downloads: {
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
    }));
    await tester.pump();

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

    await tester.pumpWidget(app(
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
    ));
    await tester.pump();

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

    await tester.pumpWidget(app(
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
    ));
    await tester.pump();

    expect(find.text('50%'), findsWidgets);
    expect(tester.takeException(), isNull);

    await disposePage(tester);
  });

  testWidgets('renders a completed record with an open action', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(app(completed: [
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
    ]));
    await tester.pump();

    expect(find.text('已完成的书'), findsOneWidget);
    expect(find.text('打开'), findsOneWidget);
    expect(find.text('已完成'), findsWidgets);

    // The status chip and the open button read as one control group:
    // same height, not one tall pill next to a shorter button.
    final status = tester
        .getSize(find.byKey(const ValueKey('completed-status-pill')));
    final open =
        tester.getSize(find.byKey(const ValueKey('completed-open-button')));
    expect(status.height, 36);
    expect(open.height, status.height);

    await disposePage(tester);
  });

  testWidgets('remove-record dialog offers deleting the local file',
      (tester) async {
    await tester.pumpWidget(app(completed: [
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
    ]));
    await tester.pump();

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

    await tester.pumpWidget(app(completed: [
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
    ]));
    await tester.pump();

    // The 0 / 1 / 0 counters and the "tap a title" hint are both gone.
    expect(find.text('0'), findsNothing);
    expect(find.text('点书名看详情 · 点打开用外部阅读器'), findsNothing);

    await disposePage(tester);
  });
}
