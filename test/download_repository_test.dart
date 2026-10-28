// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/data/repositories/download_repository.dart';
import 'package:openlib/data/services/download_manager.dart';

void main() {
  test('an untouched queue is empty and unknown ids are ignored', () {
    final repository = DownloadRepository();

    expect(repository.active, isEmpty);
    repository.cancel('no-such-task');
    repository.remove('no-such-task');
    repository.setLocale(const Locale('en'));

    expect(repository.active, isEmpty);
  });

  test('updates forwards the manager stream', () {
    final repository = DownloadRepository();

    expect(repository.updates, isA<Stream<Map<String, DownloadTask>>>());
  });
}
