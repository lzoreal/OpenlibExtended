// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Project imports:
import 'package:openlib/data/services/annas_archieve.dart';
import 'package:openlib/data/services/backup_service.dart';
import 'package:openlib/data/services/book_info_cache.dart';
import 'package:openlib/data/services/database.dart';

import 'helpers/fake_path_provider.dart';

BookInfoData _sample() => BookInfoData(
      title: 'Cached Title',
      author: 'Cached Author',
      thumbnail: 'https://example.com/cover.jpg',
      publisher: 'Cached Press',
      info: 'English · EPUB · 4 MB',
      link: 'https://annas-archive.gl/md5/abc',
      md5: 'abc',
      format: 'EPUB',
      mirror: 'https://annas-archive.gl/slow_download/abc/0/0',
      description: 'Cached description',
      isFastDownload: true,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    PathProviderPlatform.instance = FakePathProvider('cache');
    final database = await MyLibraryDb.instance.database;
    await database.delete('preferences');
  });

  test('round trips a parsed detail page', () async {
    const url = 'https://annas-archive.gl/md5/abc';
    await BookInfoCache.write(url, _sample());

    final cached = await BookInfoCache.read(url);

    expect(cached, isNotNull);
    expect(cached!.title, 'Cached Title');
    expect(cached.author, 'Cached Author');
    expect(cached.mirror, 'https://annas-archive.gl/slow_download/abc/0/0');
    expect(cached.description, 'Cached description');
    expect(cached.format, 'EPUB');
    expect(cached.isFastDownload, isTrue);
  });

  test('ignores entries older than the ttl', () async {
    const url = 'https://annas-archive.gl/md5/old';
    await BookInfoCache.write(url, _sample());

    final key = BookInfoCache.keyFor(url);
    final raw = await MyLibraryDb.instance.getPreference(key) as String;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    map['savedAt'] = DateTime.now()
        .subtract(const Duration(days: 8))
        .millisecondsSinceEpoch;
    await MyLibraryDb.instance.savePreference(key, jsonEncode(map));

    expect(await BookInfoCache.read(url), isNull);
  });

  test('backups leave the cache out', () async {
    await MyLibraryDb.instance.savePreference('themeMode', 'dark');
    await BookInfoCache.write(
      'https://annas-archive.gl/md5/backup',
      _sample(),
    );

    final json = await BackupService().createBackupJson();

    expect(json.contains(BookInfoCache.keyPrefix), isFalse);
    expect(json.contains('themeMode'), isTrue);
  });

  test('z-lib entries drop the expiring signed mirror', () async {
    const url = 'https://z-lib.gd/book/12345/slug.html';
    await BookInfoCache.write(url, _sample());

    final cached = await BookInfoCache.read(url);

    expect(cached, isNotNull);
    expect(cached!.title, 'Cached Title');
    expect(cached.mirror, isNull);
    expect(cached.isFastDownload, isFalse);
  });

  test('libgen pages are not cached at all', () async {
    const url = 'https://libgen.li/ads.php?md5=abc';
    await BookInfoCache.write(url, _sample());

    expect(await BookInfoCache.read(url), isNull);
  });
}
