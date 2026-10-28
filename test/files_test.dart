// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/data/services/files.dart';

void main() {
  group('generateBookFileName', () {
    test('keeps non-ASCII titles and adds a short unique suffix', () {
      final name = generateBookFileName(
        title: '三体',
        format: 'epub',
        md5: '0123456789abcdef0123456789abcdef',
      );

      expect(name, '三体_01234567.epub');
    });

    test('different ids do not collide for the same title', () {
      final first = generateBookFileName(
        title: 'Dune',
        format: 'epub',
        md5: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      );
      final second = generateBookFileName(
        title: 'Dune',
        format: 'epub',
        md5: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
      );

      expect(first, isNot(second));
    });

    test('strips path separators and trailing dots', () {
      final name = generateBookFileName(
        title: 'A/B: C? ',
        format: 'pdf',
        md5: 'md5hash_001',
      );

      expect(name, isNot(contains('/')));
      expect(name, isNot(contains(':')));
      expect(name, isNot(contains('?')));
      expect(name, endsWith('.pdf'));
    });

    test('falls back to the id when the title has no usable characters', () {
      final name = generateBookFileName(
        title: '😀 😀',
        format: 'epub',
        md5: 'abcdef123456',
      );

      expect(name, 'abcdef12.epub');
    });

    test('avoids Windows reserved device names', () {
      final name = generateBookFileName(
        title: 'CON',
        format: 'epub',
        md5: '',
      );

      expect(name, 'Con_book.epub');
    });
  });
}
