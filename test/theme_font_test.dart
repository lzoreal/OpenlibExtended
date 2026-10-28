// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/ui/core/themes.dart';

void main() {
  test('theme keeps Latin and CJK on one weight-consistent font', () {
    final style = lightTheme.textTheme.bodyMedium!;
    expect(style.fontFamilyFallback, contains('Microsoft YaHei UI'));
    if (Platform.isWindows) {
      expect(style.fontFamily, 'Microsoft YaHei UI');
    }
  });
}
