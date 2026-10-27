import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UI code has no stray fontSize literals outside tokens', () {
    final files = Directory('lib/ui')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    final offenders = <String>[];
    for (final file in files) {
      if (file.path.endsWith('swiss_grid.dart') ||
          file.path.endsWith('themes.dart') ||
          file.path.endsWith('error_widget.dart')) {
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (RegExp(r'fontSize:\s*[0-9]').hasMatch(lines[i])) {
          offenders.add('${file.path}:${i + 1}');
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
