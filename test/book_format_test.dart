// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/services/book_format.dart';

void main() {
  group('detectBookFormat', () {
    test('detects every supported format in catalog info strings', () {
      expect(detectBookFormat('English, PDF, 2 MB'), 'pdf');
      expect(detectBookFormat('English, EPUB, 2 MB'), 'epub');
      expect(detectBookFormat('English, MOBI, 2 MB'), 'mobi');
      expect(detectBookFormat('English, AZW3, 2 MB'), 'azw3');
      expect(detectBookFormat('English, FB2, 2 MB'), 'fb2');
      expect(detectBookFormat('English, DJVU, 2 MB'), 'djvu');
      expect(detectBookFormat('English, TXT, 2 MB'), 'txt');
      expect(detectBookFormat('English, CBR, 2 MB'), 'cbr');
      expect(detectBookFormat('English, CBZ, 2 MB'), 'cbz');
    });

    test('treats the legacy azw extension as the azw3 family', () {
      expect(detectBookFormat('English, AZW, 2 MB'), 'azw3');
    });

    test('is case insensitive and tolerates brackets and commas', () {
      expect(detectBookFormat('[en], mobi, 1.2MB'), 'mobi');
      expect(detectBookFormat('Azw3'), 'azw3');
      expect(detectBookFormat('German [de], PDF, 15.1MB'), 'pdf');
    });

    test('does not match a format inside a longer word', () {
      expect(detectBookFormat('Textbook of PDFormatics'), isNull);
      expect(detectBookFormat('TXTbook'), isNull);
      expect(detectBookFormat('epub3'), isNull);
    });

    test('returns null without an info string or a recognizable format', () {
      expect(detectBookFormat(null), isNull);
      expect(detectBookFormat(''), isNull);
      expect(detectBookFormat('English, 2 MB'), isNull);
    });
  });

  group('bookFormats', () {
    test('lists the nine supported formats', () {
      expect(bookFormats, [
        'pdf',
        'epub',
        'mobi',
        'azw3',
        'fb2',
        'djvu',
        'txt',
        'cbr',
        'cbz',
      ]);
    });
  });

  group('isSupportedBookFormat', () {
    test('accepts supported formats regardless of case', () {
      for (final format in bookFormats) {
        expect(isSupportedBookFormat(format.toUpperCase()), isTrue);
      }
    });

    test('accepts azw as a supported alias', () {
      expect(isSupportedBookFormat('AZW'), isTrue);
    });

    test('rejects other extensions', () {
      expect(isSupportedBookFormat('docx'), isFalse);
      expect(isSupportedBookFormat(''), isFalse);
      expect(isSupportedBookFormat(null), isFalse);
    });
  });

  group('bookFormatMimeType', () {
    test('maps each supported format to a concrete MIME type', () {
      expect(bookFormatMimeType('pdf'), 'application/pdf');
      expect(bookFormatMimeType('epub'), 'application/epub+zip');
      expect(bookFormatMimeType('mobi'), 'application/x-mobipocket-ebook');
      expect(bookFormatMimeType('azw3'), 'application/vnd.amazon.ebook');
      expect(bookFormatMimeType('azw'), 'application/vnd.amazon.ebook');
      expect(bookFormatMimeType('fb2'), 'application/x-fictionbook+xml');
      expect(bookFormatMimeType('djvu'), 'image/vnd.djvu');
      expect(bookFormatMimeType('txt'), 'text/plain');
      expect(bookFormatMimeType('cbr'), 'application/vnd.comicbook-rar');
      expect(bookFormatMimeType('cbz'), 'application/vnd.comicbook+zip');
    });

    test('returns null for unknown formats', () {
      expect(bookFormatMimeType('docx'), isNull);
      expect(bookFormatMimeType(null), isNull);
    });
  });

  group('isSupportedBookFile', () {
    test('matches supported extensions in paths', () {
      expect(isSupportedBookFile('/books/a.epub'), isTrue);
      expect(isSupportedBookFile('/books/a.AZW3'), isTrue);
      expect(isSupportedBookFile(r'C:\books\a.mobi'), isTrue);
      expect(isSupportedBookFile('/books/a.txt'), isTrue);
    });

    test('rejects non-book files', () {
      expect(isSupportedBookFile('/books/notes.md'), isFalse);
      expect(isSupportedBookFile('/books/archive.epub.bak'), isFalse);
    });
  });
}
