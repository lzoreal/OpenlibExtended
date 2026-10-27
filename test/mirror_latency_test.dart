// Local latency probing: how long this device takes to receive response
// headers from a mirror. These tests use a real loopback HTTP server so
// the HEAD/GET fallback, timeout and concurrency paths are exercised
// without mocking the network stack.

// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/services/mirror_latency.dart';

void main() {
  group('latency formatting', () {
    test('uses ms below a second and one decimal second above', () {
      expect(formatMirrorLatency(0), '0 ms');
      expect(formatMirrorLatency(999), '999 ms');
      expect(formatMirrorLatency(1000), '1.0 s');
      expect(formatMirrorLatency(1284), '1.3 s');
    });
  });

  group('MirrorLatencyReading', () {
    final now = DateTime.utc(2026, 10, 27, 12);

    test('is fresh for less than 24 hours', () {
      final reading = MirrorLatencyReading(
        milliseconds: 85,
        testedAt: now.subtract(const Duration(hours: 23)),
      );
      expect(reading.isFreshAt(now), isTrue);
    });

    test('is stale at 24 hours or later', () {
      final reading = MirrorLatencyReading(
        milliseconds: 85,
        testedAt: now.subtract(const Duration(hours: 24)),
      );
      expect(reading.isFreshAt(now), isFalse);
    });

    test('a future timestamp is not trusted as fresh', () {
      final reading = MirrorLatencyReading(
        milliseconds: 85,
        testedAt: now.add(const Duration(minutes: 1)),
      );
      expect(reading.isFreshAt(now), isFalse);
    });

    test('round-trips through JSON, including timeouts', () {
      final hit = MirrorLatencyReading(milliseconds: 85, testedAt: now);
      final miss = MirrorLatencyReading(milliseconds: null, testedAt: now);

      final restoredHit = MirrorLatencyReading.fromJson(hit.toJson());
      final restoredMiss = MirrorLatencyReading.fromJson(miss.toJson());

      expect(restoredHit?.milliseconds, 85);
      expect(restoredHit?.testedAt, now);
      expect(restoredMiss?.milliseconds, isNull);
      expect(restoredMiss?.testedAt, now);
      expect(MirrorLatencyReading.fromJson('nope'), isNull);
    });
  });

  group('MirrorLatencyTester', () {
    late HttpServer server;
    late List<String> methods;
    late Map<String, Duration> delays;
    var active = 0;
    var maxActive = 0;

    setUp(() async {
      methods = <String>[];
      delays = <String, Duration>{};
      active = 0;
      maxActive = 0;
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        methods.add(request.method);
        active++;
        if (active > maxActive) maxActive = active;
        await Future<void>.delayed(delays[request.uri.path] ?? Duration.zero);
        final response = request.response;
        response.statusCode = HttpStatus.ok;
        response.write('ok');
        await response.close();
        active--;
      });
    });

    tearDown(() async {
      await server.close(force: true);
    });

    test('probes HEAD once and keys the result by host', () async {
      final tester = MirrorLatencyTester(timeout: const Duration(seconds: 2));

      final results =
          await tester.measure(['http://127.0.0.1:${server.port}/a']);

      expect(results.keys, ['127.0.0.1']);
      expect(results['127.0.0.1'], isNotNull);
      expect(results['127.0.0.1'], greaterThanOrEqualTo(0));
      expect(methods, ['HEAD']);
    });

    test('falls back to GET when HEAD cannot complete', () async {
      final fallbackMethods = <String>[];
      final fallback = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      fallback.listen((request) async {
        fallbackMethods.add(request.method);
        if (request.method == 'HEAD') {
          final socket =
              await request.response.detachSocket(writeHeaders: false);
          socket.destroy();
          return;
        }
        request.response.statusCode = HttpStatus.ok;
        await request.response.close();
      });
      addTearDown(() => fallback.close(force: true));

      final tester = MirrorLatencyTester(timeout: const Duration(seconds: 2));
      final results =
          await tester.measure(['http://127.0.0.1:${fallback.port}/fallback']);

      expect(results.values.single, isNotNull);
      expect(fallbackMethods, ['HEAD', 'GET']);
    });

    test('reports null when the mirror does not answer in time', () async {
      delays['/slow'] = const Duration(seconds: 2);
      final tester = MirrorLatencyTester(
        timeout: const Duration(milliseconds: 150),
      );

      final results =
          await tester.measure(['http://127.0.0.1:${server.port}/slow']);

      expect(results.values.single, isNull);
    });

    test('never exceeds the concurrency limit', () async {
      for (var i = 0; i < 6; i++) {
        delays['/c$i'] = const Duration(milliseconds: 120);
      }
      final tester = MirrorLatencyTester(
        timeout: const Duration(seconds: 2),
        maxConcurrent: 2,
      );

      final results = await tester.measure([
        for (var i = 0; i < 6; i++) 'http://127.0.0.1:${server.port}/c$i',
      ]);

      expect(methods.where((method) => method == 'HEAD'), hasLength(6));
      expect(results.values.single, isNotNull);
      expect(maxActive, lessThanOrEqualTo(2));
    });

    test('treats a refused connection as unreachable', () async {
      final tester = MirrorLatencyTester(
        timeout: const Duration(milliseconds: 300),
      );

      final results = await tester.measure(['http://127.0.0.1:1/nope']);

      expect(results.values.single, isNull);
    });
  });
}
