// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/state/state.dart' show fileType;
import 'package:openlib/ui/core/components/book_card_widget.dart'
    show getFileType, getLanguage;

void main() {
  test('book cards label newer formats', () {
    expect(getFileType('English, MOBI, 1 MB'), 'MOBI');
    expect(getFileType('English, AZW3, 1 MB'), 'AZW3');
    expect(getFileType('English, AZW, 1 MB'), 'AZW3');
    expect(getFileType('Russian, FB2, 1 MB'), 'FB2');
    expect(getFileType('French, DJVU, 8 MB'), 'DJVU');
    expect(getFileType('English, TXT, 1 MB'), 'TXT');
  });

  test('book cards keep existing labels uppercase', () {
    expect(getFileType('English, PDF, 1 MB'), 'PDF');
    expect(getFileType('English, EPUB, 1 MB'), 'EPUB');
    expect(getFileType('Comic, CBR, 1 MB'), 'CBR');
    expect(getFileType('Comic, CBZ, 1 MB'), 'CBZ');
    expect(getFileType('English, 1 MB'), isNull);
  });

  test('book cards read language names as well as codes', () {
    expect(getLanguage('English, PDF, 1 MB'), 'EN');
    expect(getLanguage('Chinese · EPUB · 4 MB'), 'ZH');
    expect(getLanguage('English [en], EPUB, 1.5MB'), 'EN');
    expect(getLanguage('German, EPUB, 2 MB'), 'DE');
    expect(getLanguage('Telugu, PDF, 1 MB'), isNull);
    expect(getLanguage(null), isNull);
  });

  test('search filter offers every supported format', () {
    expect(fileType.first, 'All');
    expect(
      fileType.map((value) => value.toLowerCase()),
      containsAll([
        'pdf',
        'epub',
        'mobi',
        'azw3',
        'fb2',
        'djvu',
        'txt',
        'cbr',
        'cbz',
      ]),
    );
  });
}
