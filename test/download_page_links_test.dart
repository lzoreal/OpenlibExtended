// The download-page pollers must not harvest links from a sign-in page:
// WeLib sends anonymous downloads to /account/ and only returns to the
// download page after the user signs in.

// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/data/services/download_page_links.dart';

void main() {
  test('a sign-in redirect waits instead of harvesting links', () {
    expect(
      downloadPageKindFor('https://welib.org/account/?redirect_after_login='
          '%2Fslow_download%2Fabc%2F0%2F0&md5=abc'),
      DownloadPageKind.wait,
    );
    expect(downloadPageKindFor('https://z-lib.gd/login'), DownloadPageKind.wait);
    expect(isLoginUrl('https://welib.org/account/?x=1'), isTrue);
    expect(isLoginUrl('https://welib.org/slow_download/abc/0/0'), isFalse);
  });

  test('download pages are read as a file link', () {
    expect(
      downloadPageKindFor('https://welib.org/slow_download/abc/0/0'),
      DownloadPageKind.fileLink,
    );
    expect(
      downloadPageKindFor('https://annas-archive.gl/slow_download/abc'),
      DownloadPageKind.fileLink,
    );
  });

  test('any other page is read as a mirror list', () {
    expect(
      downloadPageKindFor('https://annas-archive.gl/md5/abc'),
      DownloadPageKind.mirrorList,
    );
  });
}
