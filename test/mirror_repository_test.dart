// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/data/repositories/mirror_repository.dart';
import 'package:openlib/data/services/instance_manager.dart';
import 'package:openlib/data/services/preference_store.dart';

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
}
