// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:openlib/services/annas_archieve.dart';
import 'package:openlib/services/database.dart';

/// Remembers parsed book-detail pages across launches.
///
/// The Riverpod family already caches one open per session; this is what
/// makes the second visit after a restart instant too. Entries live in
/// the preferences table under [keyPrefix] so no schema change is needed.
class BookInfoCache {
  static const ttl = Duration(days: 7);

  /// Also used by backups to leave the cache out of the exported file.
  static const keyPrefix = 'bookInfoCache:';

  static String keyFor(String url) {
    final uri = Uri.tryParse(url);
    final host = uri?.host ?? '';
    final md5 = uri?.queryParameters['md5'];
    if (md5 != null && md5.isNotEmpty) return '$keyPrefix$host:$md5';
    final segments = uri?.pathSegments ?? const <String>[];
    final id = segments.isEmpty ? url : segments.last;
    return '$keyPrefix$host:$id';
  }

  static Future<BookInfoData?> read(String url) async {
    final raw = await _readPreference(keyFor(url));
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final savedAt = map['savedAt'];
      final data = map['data'];
      if (savedAt is! int || data is! Map<String, dynamic>) return null;
      final age = DateTime.now().millisecondsSinceEpoch - savedAt;
      if (age > ttl.inMilliseconds) return null;
      return _decode(data);
    } catch (_) {
      return null;
    }
  }

  static Future<void> write(String url, BookInfoData data) async {
    // LibGen's ads page carries a per-page-load get.php key; caching it
    // would hand the download button a key that is already dead.
    if (url.contains('ads.php?md5=')) return;
    // Z-Library's detail page resolves to a signed CDN link that expires
    // within hours, so only the stable metadata is kept; the download
    // button re-resolves a fresh link from the book page.
    final expiringMirror = url.contains('/book/');
    try {
      await MyLibraryDb.instance.savePreference(
        keyFor(url),
        jsonEncode({
          'savedAt': DateTime.now().millisecondsSinceEpoch,
          'data': _encode(
            data,
            includeMirror: !expiringMirror,
          ),
        }),
      );
    } catch (_) {
      // A cache write is never worth failing the page for.
    }
  }

  static Future<String?> _readPreference(String key) async {
    try {
      final value = await MyLibraryDb.instance.getPreference(key);
      return value is String ? value : null;
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _encode(
    BookInfoData data, {
    required bool includeMirror,
  }) =>
      {
        'title': data.title,
        'author': data.author,
        'thumbnail': data.thumbnail,
        'link': data.link,
        'md5': data.md5,
        'publisher': data.publisher,
        'info': data.info,
        'mirror': includeMirror ? data.mirror : null,
        'description': data.description,
        'format': data.format,
        'fast': includeMirror && data.isFastDownload,
      };

  static BookInfoData? _decode(Map<String, dynamic> map) {
    final title = map['title'];
    final link = map['link'];
    final md5 = map['md5'];
    if (title is! String || link is! String || md5 is! String) return null;
    return BookInfoData(
      title: title,
      author: map['author'] as String?,
      thumbnail: map['thumbnail'] as String?,
      publisher: map['publisher'] as String?,
      info: map['info'] as String?,
      link: link,
      md5: md5,
      format: map['format'] as String?,
      mirror: map['mirror'] as String?,
      description: map['description'] as String?,
      isFastDownload: map['fast'] == true,
    );
  }
}
