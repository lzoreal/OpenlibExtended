// The detail action bar follows the live download queue: progress replaces
// the download button, and tapping it pauses/resumes the task.

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/data/models/book_data.dart';
import 'package:openlib/data/services/download_manager.dart'
    show DownloadStatus;
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/ui/core/themes.dart';
import 'package:openlib/ui/features/book_detail/views/book_info_page.dart';

import 'helpers/book_detail_test_support.dart';

BookData _preview() => BookData(
      title: 'Dune',
      author: 'Frank Herbert',
      thumbnail: '',
      link: 'https://example.com/md5/abc',
      md5: 'abc',
      info: 'English · EPUB · 1 MB',
    );

BookInfoData _details() => BookInfoData(
      title: 'Dune',
      author: 'Frank Herbert',
      thumbnail: '',
      publisher: 'Penguin',
      info: 'English · EPUB · 1 MB',
      link: 'https://example.com/md5/abc',
      md5: 'abc',
      format: 'EPUB',
      mirror: null,
      description: 'A desert planet.',
    );

void main() {
  test('invalidates automatic verification when the detail owner is disposed',
      () async {
    final bookInfo = FakeBookInfoRepository(handler: (_) async => _details());
    final vm = testBookDetailViewModel(
      preview: _preview(),
      bookInfo: bookInfo,
    );

    await vm.load();
    final shouldContinue = bookInfo.continuations.single!;
    expect(shouldContinue(), isTrue);
    vm.dispose();
    expect(shouldContinue(), isFalse);
  });

  test('tracks the task by md5 and toggles pause, resume and retry', () async {
    final downloads = FakeDownloadRepository(
      active: {'t': testDownloadTask(progress: 0.4)},
    );
    addTearDown(downloads.close);
    final vm = testBookDetailViewModel(
      preview: _preview(),
      downloads: downloads,
      bookInfo: FakeBookInfoRepository(handler: (_) async => _details()),
    );
    addTearDown(vm.dispose);

    expect(vm.task, isNotNull);
    expect(vm.taskProgress, 0.4);
    expect(vm.taskPaused, isFalse);

    await vm.toggleTask();
    expect(downloads.paused, ['task-abc']);

    downloads.emit(
        {'t': testDownloadTask(status: DownloadStatus.paused, progress: 0.4)});
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(vm.taskPaused, isTrue);
    await vm.toggleTask();
    expect(downloads.resumed, ['task-abc']);

    downloads.emit(
        {'t': testDownloadTask(status: DownloadStatus.failed, progress: 0.2)});
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(vm.taskFailed, isTrue);
    await vm.toggleTask();
    expect(downloads.retried, ['task-abc']);
  });

  test('reuses the cover already resolved by the results row', () async {
    final covers = FakeCoverRepository(cover: 'https://covers/abc.jpg');
    final vm = testBookDetailViewModel(
      preview: _preview(),
      covers: covers,
      bookInfo: FakeBookInfoRepository(handler: (_) async => _details()),
    );
    addTearDown(vm.dispose);

    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(covers.requests, ['https://example.com/md5/abc']);
    expect(vm.coverUrl, 'https://covers/abc.jpg');
  });

  testWidgets('the action bar shows progress and pauses on tap',
      (tester) async {
    final downloads = FakeDownloadRepository(
      active: {'t': testDownloadTask(progress: 0.42)},
    );
    addTearDown(downloads.close);
    final vm = testBookDetailViewModel(
      preview: _preview(),
      downloads: downloads,
      bookInfo: FakeBookInfoRepository(handler: (_) async => _details()),
    );
    addTearDown(vm.dispose);

    await tester.pumpWidget(MaterialApp(
      theme: lightTheme,
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BookInfoPage(
        url: 'https://example.com/md5/abc',
        source: 'LibGen',
        preview: _preview(),
        viewModel: vm,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('正在下载 42% · 点击暂停'), findsOneWidget);
    expect(find.text('下载本书'), findsNothing);

    await tester.tap(find.text('正在下载 42% · 点击暂停'));
    await tester.pump();
    expect(downloads.paused, ['task-abc']);

    downloads.emit({
      't': testDownloadTask(status: DownloadStatus.paused, progress: 0.42),
    });
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('已暂停 42% · 点击继续'), findsOneWidget);

    await tester.tap(find.text('已暂停 42% · 点击继续'));
    await tester.pump();
    expect(downloads.resumed, ['task-abc']);
  });

  testWidgets('detail failure does not leave a loading download button',
      (tester) async {
    final vm = testBookDetailViewModel(
      preview: _preview(),
      bookInfo: FakeBookInfoRepository(
        handler: (_) async => throw StateError('offline'),
      ),
    );
    addTearDown(vm.dispose);

    await tester.pumpWidget(MaterialApp(
      theme: lightTheme,
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BookInfoPage(
        url: 'https://example.com/md5/abc',
        source: 'LibGen',
        preview: _preview(),
        viewModel: vm,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('无法加载书籍详情'), findsOneWidget);
    expect(find.byKey(const ValueKey('detail-loading-download')), findsNothing);
    expect(find.text('下载本书'), findsNothing);
    expect(find.text('重试'), findsOneWidget);
  });
}
