// WeLib and Anna's Archive only put the file behind a slow page, so the
// download button waits that page out invisibly: the countdown ticks on
// the button and the links are queued as soon as they appear. A sign-in
// redirect (or a page with no links) still falls back to the visible page
// or the old background scrape.

// Dart imports:
import 'dart:async';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/data/models/book_data.dart';
import 'package:openlib/data/services/download_page_waiter.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/ui/core/themes.dart';
import 'package:openlib/ui/features/book_detail/view_models/book_detail_view_model.dart';
import 'package:openlib/ui/features/book_detail/views/book_info_page.dart';

import 'helpers/book_detail_test_support.dart';

const _welibId = '00f8a97a0e03ac203235b306e249aa76';
const _welibLink = 'https://welib.org/md5/$_welibId';
const _welibMirror = 'https://welib.org/slow_download/$_welibId/0/0';
const _fileLink = 'https://x-cdn-x.com/file/The%20Score.pdf';

const _annaId = '3ed47f018f8ad841b1e13683ce33ec5d';
const _annaLink = 'https://annas-archive.gl/md5/$_annaId';
const _annaMirror = 'https://annas-archive.gl/slow_download/$_annaId/0/0';
const _annaMirrorOne = 'https://annas-archive.gl/slow_download/$_annaId/1/0';
const _annaMirrorTwo = 'https://annas-archive.gl/slow_download/$_annaId/2/0';

BookInfoData _welibDetails() => BookInfoData(
      title: 'The Score',
      author: 'Elle Kennedy',
      thumbnail: '',
      publisher: null,
      info: 'English · PDF',
      link: _welibLink,
      md5: _welibId,
      format: 'pdf',
      mirror: _welibMirror,
      description: 'A college romance.',
    );

BookInfoData _annaDetails() => BookInfoData(
      title: 'Dune',
      author: 'Frank Herbert',
      thumbnail: '',
      publisher: null,
      info: 'English · EPUB',
      link: _annaLink,
      md5: _annaId,
      format: 'epub',
      mirror: _annaMirror,
      description: 'A desert planet.',
    );

class FakePageWaiter extends DownloadPageWaiter {
  FakePageWaiter(this.result);

  final DownloadWaitResult result;
  final List<String> pages = [];

  @override
  Future<DownloadWaitResult> wait(
    String pageUrl, {
    void Function(int? secondsLeft)? onTick,
    bool Function()? shouldContinue,
  }) async {
    pages.add(pageUrl);
    return result;
  }
}

class ControlledPageWaiter extends DownloadPageWaiter {
  final Completer<DownloadWaitResult> completer =
      Completer<DownloadWaitResult>();
  void Function(int? secondsLeft)? onTick;
  final List<String> pages = [];

  @override
  Future<DownloadWaitResult> wait(
    String pageUrl, {
    void Function(int? secondsLeft)? onTick,
    bool Function()? shouldContinue,
  }) {
    pages.add(pageUrl);
    this.onTick = onTick;
    return completer.future;
  }

  void tick(int? seconds) => onTick?.call(seconds);
}

BookDetailViewModel _welibVm(FakePageWaiter waiter,
        FakeDownloadRepository downloads) =>
    testBookDetailViewModel(
      url: _welibLink,
      source: 'WeLib',
      downloads: downloads,
      pageWaiter: waiter,
      bookInfo: FakeBookInfoRepository(handler: (_) async => _welibDetails()),
    );

void main() {
  test('WeLib slow page is waited out and the file link queued', () async {
    final downloads = FakeDownloadRepository();
    addTearDown(downloads.close);
    final waiter = FakePageWaiter(
      const DownloadWaitResult.links([_fileLink]),
    );
    final vm = _welibVm(waiter, downloads);
    addTearDown(vm.dispose);

    await vm.load();
    final plan = await vm.startDownload();

    expect(waiter.pages, [_welibMirror]);
    expect(plan, isA<DownloadStarted>());
    expect((plan as DownloadStarted).fast, isTrue);
    expect(downloads.addedWithMirrorUrl.single.mirrorUrl, _fileLink);
    expect(downloads.addedWithMirrorUrl.single.task.isDirectLink, isTrue);
  });

  test('WeLib sign-in redirect falls back to the visible page', () async {
    final downloads = FakeDownloadRepository();
    addTearDown(downloads.close);
    final vm = _welibVm(
      FakePageWaiter(const DownloadWaitResult.needsLogin()),
      downloads,
    );
    addTearDown(vm.dispose);

    await vm.load();
    final plan = await vm.startDownload();

    expect(plan, isA<DownloadNeedsMirrors>());
    expect((plan as DownloadNeedsMirrors).url, _welibMirror);
    expect(downloads.addedWithMirrorUrl, isEmpty);
  });

  test("Anna's Archive mirror list is waited out and queued", () async {
    final downloads = FakeDownloadRepository();
    addTearDown(downloads.close);
    final waiter = FakePageWaiter(
      const DownloadWaitResult.links([_annaMirrorOne, _annaMirrorTwo]),
    );
    final vm = testBookDetailViewModel(
      url: _annaLink,
      source: "Anna's Archive",
      downloads: downloads,
      pageWaiter: waiter,
      bookInfo: FakeBookInfoRepository(handler: (_) async => _annaDetails()),
    );
    addTearDown(vm.dispose);

    await vm.load();
    final plan = await vm.startDownload();

    expect(waiter.pages, [_annaMirror]);
    expect(plan, isA<DownloadStarted>());
    expect((plan as DownloadStarted).fast, isFalse);
    expect(downloads.added.single.mirrors, [_annaMirrorOne, _annaMirrorTwo]);
    expect(downloads.addedWithMirrorUrl, isEmpty);
  });

  test("Anna's Archive single file link is queued as a fast link", () async {
    final downloads = FakeDownloadRepository();
    addTearDown(downloads.close);
    final waiter = FakePageWaiter(
      const DownloadWaitResult.links([_fileLink]),
    );
    final vm = testBookDetailViewModel(
      url: _annaLink,
      source: "Anna's Archive",
      downloads: downloads,
      pageWaiter: waiter,
      bookInfo: FakeBookInfoRepository(handler: (_) async => _annaDetails()),
    );
    addTearDown(vm.dispose);

    await vm.load();
    final plan = await vm.startDownload();

    expect(plan, isA<DownloadStarted>());
    expect((plan as DownloadStarted).fast, isTrue);
    expect(downloads.addedWithMirrorUrl.single.mirrorUrl, _fileLink);
  });

  test("Anna's Archive keeps the background scrape when the page has no links",
      () async {
    final downloads = FakeDownloadRepository();
    addTearDown(downloads.close);
    final vm = testBookDetailViewModel(
      url: _annaLink,
      source: "Anna's Archive",
      downloads: downloads,
      pageWaiter: FakePageWaiter(const DownloadWaitResult.unavailable()),
      bookInfo: FakeBookInfoRepository(handler: (_) async => _annaDetails()),
    );
    addTearDown(vm.dispose);

    await vm.load();
    final plan = await vm.startDownload();

    if (Platform.isLinux) {
      // Linux ships no headless WebView, so the button hands the page to the
      // visible browser instead of queueing a task.
      expect(plan, isA<DownloadNeedsMirrors>());
      expect((plan as DownloadNeedsMirrors).url, _annaMirror);
      expect(downloads.addedWithMirrorUrl, isEmpty);
      return;
    }

    expect(plan, isA<DownloadStarted>());
    expect(downloads.addedWithMirrorUrl.single.mirrorUrl, _annaMirror);
    expect(downloads.addedWithMirrorUrl.single.task.isDirectLink, isFalse);
  });

  testWidgets('the download button counts the wait down', (tester) async {
    final waiter = ControlledPageWaiter();
    final downloads = FakeDownloadRepository();
    addTearDown(downloads.close);
    final vm = testBookDetailViewModel(
      url: _welibLink,
      source: 'WeLib',
      downloads: downloads,
      pageWaiter: waiter,
      bookInfo: FakeBookInfoRepository(handler: (_) async => _welibDetails()),
    );
    addTearDown(vm.dispose);

    await tester.pumpWidget(MaterialApp(
      theme: lightTheme,
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BookInfoPage(
        url: _welibLink,
        source: 'WeLib',
        preview: null,
        viewModel: vm,
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('下载本书'), findsOneWidget);

    unawaited(vm.startDownload());
    await tester.pump();
    expect(find.text('正在准备下载…'), findsOneWidget);

    waiter.tick(12);
    await tester.pump();
    expect(find.text('等待下载 12s'), findsOneWidget);

    waiter.completer.complete(const DownloadWaitResult.links([_fileLink]));
    await tester.pumpAndSettle();
    expect(downloads.addedWithMirrorUrl.single.mirrorUrl, _fileLink);
  });
}
