// Dart imports:
import 'dart:async';
import 'dart:io';

/// One local latency reading for a mirror host.
///
/// A null [milliseconds] means the mirror was tested but did not return
/// response headers before the timeout. Readings older than [ttl] are
/// kept for display but no longer influence automatic ordering.
class MirrorLatencyReading {
  const MirrorLatencyReading({
    required this.milliseconds,
    required this.testedAt,
  });

  final int? milliseconds;
  final DateTime testedAt;

  static const Duration ttl = Duration(hours: 24);

  bool isFreshAt(DateTime now) {
    final age = now.difference(testedAt);
    return !age.isNegative && age < ttl;
  }

  bool get isReachable => milliseconds != null;

  Map<String, Object?> toJson() => {
        'ms': milliseconds,
        'testedAt': testedAt.toUtc().toIso8601String(),
      };

  static MirrorLatencyReading? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final testedAt = DateTime.tryParse('${raw['testedAt']}');
    if (testedAt == null) return null;
    final value = raw['ms'];
    if (value != null && value is! int) return null;
    return MirrorLatencyReading(
      milliseconds: value as int?,
      testedAt: testedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MirrorLatencyReading &&
        other.milliseconds == milliseconds &&
        other.testedAt == testedAt;
  }

  @override
  int get hashCode => milliseconds.hashCode ^ testedAt.hashCode;
}

String formatMirrorLatency(int milliseconds) {
  if (milliseconds < 1000) return '$milliseconds ms';
  return '${(milliseconds / 1000).toStringAsFixed(1)} s';
}

/// Measures the time from starting a request until the mirror returns
/// response headers (TTFB). HEAD is tried first because it avoids
/// downloading a page; mirrors that reject or drop HEAD are retried with
/// GET. Any HTTP status counts as reachable - a challenge page still
/// proves the host answered.
class MirrorLatencyTester {
  const MirrorLatencyTester({
    this.timeout = const Duration(seconds: 6),
    this.maxConcurrent = 4,
  });

  final Duration timeout;
  final int maxConcurrent;

  static const String _userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
      'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0 Safari/537.36';

  /// Returns one entry per host. A null value is a tested, unreachable
  /// mirror; hosts missing from the map were not requested.
  Future<Map<String, int?>> measure(Iterable<String> urls) async {
    final targets = <Uri>[];
    final seen = <String>{};
    for (final raw in urls) {
      final uri = Uri.tryParse(raw);
      if (uri == null || uri.host.isEmpty || !seen.add(raw)) continue;
      targets.add(uri);
    }
    if (targets.isEmpty) return <String, int?>{};

    final client = HttpClient()..connectionTimeout = timeout;
    final results = <String, int?>{};
    final limit = maxConcurrent < 1 ? 1 : maxConcurrent;
    try {
      var next = 0;
      Future<void> worker() async {
        while (next < targets.length) {
          final uri = targets[next++];
          results[uri.host] = await _measureOne(client, uri);
        }
      }

      await Future.wait([
        for (var i = 0; i < limit && i < targets.length; i++) worker(),
      ]);
    } finally {
      client.close(force: true);
    }
    return results;
  }

  Future<int?> _measureOne(HttpClient client, Uri uri) async {
    try {
      return await _timed(client, uri, 'HEAD').timeout(timeout);
    } on TimeoutException {
      return null;
    } catch (_) {
      try {
        return await _timed(client, uri, 'GET').timeout(timeout);
      } on TimeoutException {
        return null;
      } catch (_) {
        return null;
      }
    }
  }

  Future<int> _timed(HttpClient client, Uri uri, String method) async {
    final stopwatch = Stopwatch()..start();
    final request = await client.openUrl(method, uri);
    request.followRedirects = true;
    request.maxRedirects = 5;
    request.headers.set(HttpHeaders.userAgentHeader, _userAgent);
    final response = await request.close();
    final elapsed = stopwatch.elapsedMilliseconds;
    final subscription = response.listen(
      (_) {},
      onError: (_) {},
      cancelOnError: true,
    );
    unawaited(subscription.cancel());
    return elapsed;
  }
}
