// Every mirror refusal is a code the UI localizes, so a limit or sign-in
// wall reads in the app's language instead of raw English.

// Flutter imports:
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/data/models/download_refusal.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/ui/features/book_detail/views/book_info_page.dart'
    show refusalMessage;

void main() {
  test('Z-Library refusals render in Chinese', () {
    final zh = lookupAppLocalizations(const Locale('zh'));
    expect(refusalMessage(zh, DownloadRefusal.zlibDailyLimit), contains('每日下载上限'));
    expect(refusalMessage(zh, DownloadRefusal.zlibSignIn), contains('登录'));
    expect(refusalMessage(zh, DownloadRefusal.zlibNoDownloadLink),
        contains('没有提供下载链接'));
  });

  test('WeLib refusals render in Chinese', () {
    final zh = lookupAppLocalizations(const Locale('zh'));
    expect(refusalMessage(zh, DownloadRefusal.welibRateLimit), contains('限制下载'));
    expect(refusalMessage(zh, DownloadRefusal.welibBotCheck), contains('人机验证'));
    expect(refusalMessage(zh, DownloadRefusal.welibNoDownloadLink),
        zh.welibNoDownloadLink);
    expect(refusalMessage(zh, DownloadRefusal.welibPageUnreadable),
        zh.welibPageUnreadable);
  });

  test('unknown refusals fall back to the raw reason or no-mirrors', () {
    final en = lookupAppLocalizations(const Locale('en'));
    expect(refusalMessage(en, null), en.noMirrors);
    expect(refusalMessage(en, 'mirror said something new'),
        'mirror said something new');
  });
}
