// WeLib only puts the file behind its public-server page, so the download
// button opens that page instead of resolving a link headlessly - the same
// flow "open at source" uses, and the one design/ui_prototype.html shows.

// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/data/models/book_data.dart';
import 'package:openlib/ui/features/book_detail/view_models/book_detail_view_model.dart';

import 'helpers/book_detail_test_support.dart';

const _welibId = '00f8a97a0e03ac203235b306e249aa76';
const _welibLink = 'https://welib.org/md5/$_welibId';
const _welibMirror = 'https://welib.org/slow_download/$_welibId/0/0';

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

void main() {
  test('WeLib download opens the source download page', () async {
    final downloads = FakeDownloadRepository();
    addTearDown(downloads.close);
    final vm = testBookDetailViewModel(
      url: _welibLink,
      source: 'WeLib',
      downloads: downloads,
      bookInfo: FakeBookInfoRepository(handler: (_) async => _welibDetails()),
    );
    addTearDown(vm.dispose);

    await vm.load();
    final plan = await vm.startDownload();

    expect(plan, isA<DownloadNeedsMirrors>());
    expect((plan as DownloadNeedsMirrors).url, _welibMirror);
    expect(downloads.addedWithMirrorUrl, isEmpty);
    expect(downloads.added, isEmpty);
  });

  test('mirrors captured on the page queue the file', () async {
    final downloads = FakeDownloadRepository();
    addTearDown(downloads.close);
    final vm = testBookDetailViewModel(
      url: _welibLink,
      source: 'WeLib',
      downloads: downloads,
      bookInfo: FakeBookInfoRepository(handler: (_) async => _welibDetails()),
    );
    addTearDown(vm.dispose);

    await vm.load();
    const file = 'https://x-cdn-x.com/file/The%20Score.pdf';
    final started = await vm.startWithMirrors(_welibMirror, [file]);

    expect(started, isTrue);
    expect(downloads.added.single.mirrors, [file]);
    expect(downloads.added.single.md5, _welibId);
  });
}
