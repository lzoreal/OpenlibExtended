import 'dart:io';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// Shared fake [PathProviderPlatform] for tests.
///
/// Each suite gets a unique base directory (timestamp + PID) so concurrent
/// `flutter test` files never collide on the same SQLite DB or storage path.
///
/// Usage:
/// ```dart
/// PathProviderPlatform.instance = FakePathProvider('searchmgr');
/// ```
class FakePathProvider extends PathProviderPlatform {
  FakePathProvider(String suiteName)
      : _base =
            '/tmp/openlib_${suiteName}_${DateTime.now().millisecondsSinceEpoch}_$pid';

  final String _base;

  String get base => _base;

  Future<String> _dir(String name) async {
    final dir = Directory('$_base/$name');
    await dir.create(recursive: true);
    return dir.path;
  }

  @override
  Future<String?> getApplicationSupportPath() => _dir('support');

  @override
  Future<String?> getApplicationDocumentsPath() => _dir('documents');

  @override
  Future<String?> getTemporaryPath() => _dir('temp');

  @override
  Future<String?> getLibraryPath() => _dir('library');
}
