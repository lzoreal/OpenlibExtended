// Real tests for the storage-move path: changing the storage folder must
// carry the books along and leave nothing behind, whichever direction the
// move goes (the old code only moved files out of the internal default).

// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/data/services/files.dart';

void main() {
  late Directory source;
  late Directory destination;

  setUp(() {
    source = Directory.systemTemp.createTempSync('openlib_move_src');
    destination = Directory.systemTemp.createTempSync('openlib_move_dst');
    // Fresh destination dir content, not the temp root itself.
    destination = Directory('${destination.path}/books')..createSync();
  });

  tearDown(() {
    source.deleteSync(recursive: true);
    destination.deleteSync(recursive: true);
  });

  File writeFile(String dir, String name) {
    final f = File('$dir/$name');
    f.writeAsBytesSync(List.filled(128, 7));
    return f;
  }

  test('moves every supported book format and leaves other files alone',
      () async {
    final books = [
      'book.epub',
      'other.pdf',
      'kindle.mobi',
      'kindle.azw3',
      'legacy.azw',
      'fiction.fb2',
      'scan.djvu',
      'notes.txt',
      'comic.cbr',
      'comic.cbz',
    ];
    for (final name in books) {
      writeFile(source.path, name);
    }
    writeFile(source.path, 'cover.jpg');
    writeFile(source.path, 'draft.docx');

    await moveLibraryFiles(source.path, destination.path);

    for (final name in books) {
      expect(File('${destination.path}/$name').existsSync(), isTrue,
          reason: '$name must arrive in the new directory');
      expect(File('${source.path}/$name').existsSync(), isFalse,
          reason: 'source must be emptied of $name');
    }
    expect(File('${destination.path}/cover.jpg').existsSync(), isFalse,
        reason: 'non-book files are not library content');
    expect(File('${destination.path}/draft.docx').existsSync(), isFalse,
        reason: 'unsupported formats stay in the source folder');
  });

  test('does not overwrite an existing file at the destination', () async {
    final src = writeFile(source.path, 'book.epub');
    final dst = File('${destination.path}/book.epub')
      ..writeAsBytesSync(List.filled(64, 1));

    await moveLibraryFiles(source.path, destination.path);

    expect(dst.lengthSync(), 64, reason: 'the existing destination file wins');
    expect(src.existsSync(), isTrue,
        reason: 'source is kept when the move is a no-op');
  });

  test('missing source directory is a silent no-op', () async {
    // E.g. the folder was on an unmounted SD card.
    await moveLibraryFiles('/nonexistent/openlib/path', destination.path);
    expect(destination.listSync(), isEmpty);
  });

  test('creates the destination directory when it does not exist', () async {
    final nested = Directory('${destination.path}/new/sub');
    writeFile(source.path, 'book.cbz');

    await moveLibraryFiles(source.path, nested.path);

    expect(File('${nested.path}/book.cbz').existsSync(), isTrue,
        reason: 'nested destinations are created recursively');
  });
}
