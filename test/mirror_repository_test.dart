// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/data/repositories/mirror_repository.dart';
import 'package:openlib/data/services/instance_manager.dart';
import 'package:openlib/data/services/preference_store.dart';
import 'package:openlib/data/services/slum_catalogue.dart';

/// Serves the captured open-slum.org pages under their real paths.
Future<HttpServer> _slumServer() async {
  const files = {
    '/annas.html': 'slum_annas.html',
    '/libgen.html': 'slum_libgen.html',
    '/zlibrary.html': 'slum_zlibrary.html',
    '/other.html': 'slum_other.html',
  };

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((request) async {
    final name = files[request.uri.path];
    final file = name == null ? null : File('test/fixtures/$name');
    if (file != null && await file.exists()) {
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.html
        ..write(await file.readAsString());
    } else {
      request.response.statusCode = HttpStatus.notFound;
    }
    await request.response.close();
  });
  return server;
}

void main() {
  test('delegates latency persistence to the manager', () async {
    // forTest() without a store drops writes, so the repository's
    // delegation is only visible with an in-memory store behind it.
    final repository = MirrorRepository(
      manager: InstanceManager.forTest(store: MemoryPreferenceStore()),
    );
    // Readings are stored as UTC, so a local stamp would not compare equal
    // to the parsed reading even for the same instant.
    final testedAt = DateTime.utc(2026, 10, 28, 12);

    await repository.saveLocalLatencies(
      {'https://example.com': 120, 'https://slow.example.com': null},
      testedAt: testedAt,
    );

    final readings = await repository.localLatencies();
    expect(readings['https://example.com']?.milliseconds, 120);
    expect(readings['https://example.com']?.testedAt, testedAt);
    expect(readings['https://slow.example.com']?.isReachable, isFalse);
  });

  test('enabledUrls forwards the headless filter and the user switches',
      () async {
    final server = await _slumServer();
    addTearDown(server.close);
    final store = MemoryPreferenceStore();
    final repository = MirrorRepository(
      manager: InstanceManager.forTest(
        catalogue: SlumCatalogue(
          store: store,
          baseUrl: 'http://127.0.0.1:${server.port}',
        ),
        store: store,
      ),
    );

    final all =
        await repository.enabledUrls(MirrorService.zlibrary, force: true);
    final headless = await repository.enabledUrls(MirrorService.zlibrary,
        force: true, headlessOnly: true);

    final browserOnly = (await repository.instances(MirrorService.zlibrary,
            force: true))
        .firstWhere(
            (view) => !view.isDown && !view.site.protection.solvableHeadless);
    final switchedOff = headless.first;

    expect(all, contains(browserOnly.url));
    expect(headless, isNot(contains(browserOnly.url)),
        reason: 'a mirror only a browser can clear must drop out when the '
            'caller asks for headless-capable hosts');
    expect(headless, contains(switchedOff));

    await repository.setEnabled(
        MirrorService.zlibrary, Uri.parse(switchedOff).host, false);

    expect(await repository.enabledUrls(MirrorService.zlibrary, force: true),
        isNot(contains(switchedOff)));
    expect(
        await repository.enabledUrls(MirrorService.zlibrary,
            force: true, headlessOnly: true),
        isNot(contains(switchedOff)));
  });
}
