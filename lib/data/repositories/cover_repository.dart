// Project imports:
import 'package:openlib/data/services/libgen_service.dart';

/// Lazily resolves cover addresses for rows that ship without a thumbnail.
///
/// LibGen search rows carry no cover, but their `ads.php?md5=` page does.
/// Lookups are cached briefly so scrolling a row away and back reuses the
/// answer instead of hitting ads.php again; the image bytes stay in
/// CachedNetworkImage's own cache.
class CoverRepository {
  CoverRepository({LibgenService? libgen, DateTime Function()? clock})
      : _libgen = libgen ?? LibgenService(),
        _clock = clock ?? DateTime.now;

  static const Duration _ttl = Duration(minutes: 10);

  final LibgenService _libgen;
  final DateTime Function() _clock;
  final Map<String, _CoverEntry> _cache = {};
  final Map<String, Future<String?>> _inFlight = {};

  Future<String?> coverFor(String url) {
    // Only LibGen detail pages carry a discoverable cover; every other
    // source's row either has a thumbnail or has nothing to look up.
    if (!url.contains('ads.php?md5=')) return Future.value(null);

    final cached = _cache[url];
    if (cached != null && _clock().difference(cached.resolvedAt) < _ttl) {
      return Future.value(cached.coverUrl);
    }

    final pending = _inFlight[url];
    if (pending != null) return pending;

    final request = _resolve(url);
    _inFlight[url] = request;
    return request;
  }

  Future<String?> _resolve(String url) async {
    try {
      final cover = await _libgen.fetchCover(url);
      _cache[url] = _CoverEntry(cover, _clock());
      return cover;
    } catch (_) {
      // The old provider kept a failed lookup as a null result for the same
      // TTL; the row simply keeps its placeholder.
      _cache[url] = _CoverEntry(null, _clock());
      return null;
    } finally {
      _inFlight.remove(url);
    }
  }
}

class _CoverEntry {
  const _CoverEntry(this.coverUrl, this.resolvedAt);

  final String? coverUrl;
  final DateTime resolvedAt;
}
