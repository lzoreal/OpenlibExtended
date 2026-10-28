// Dart imports:
import 'dart:io';

// Package imports:
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

// Project imports:
import 'package:openlib/data/services/book_format.dart';
import 'package:openlib/data/services/database.dart';

MyLibraryDb dataBase = MyLibraryDb.instance;

// Generate a safe filename: Title_hash.extension. The short hash keeps
// different books with identical titles (or titles the filesystem
// rejects) from overwriting each other.
String generateBookFileName({
  required String title,
  String? author,
  String? info,
  required String format,
  required String md5,
}) {
  // Remove control characters, emojis and path separators, but keep
  // non-ASCII letters so CJK titles survive instead of collapsing to a
  // hash.
  String removeSpecialChars(String text) {
    return text
        .replaceAll(RegExp(r'[\u0000-\u001F\u007F]'), '')
        .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{2600}-\u{26FF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{2700}-\u{27BF}]', unicode: true), '')
        .trim();
  }

  // Extract text from parentheses and combine with main title
  String extractAndCombineTitle(String text) {
    String cleaned = removeSpecialChars(text);

    // Extract content inside parentheses
    List<String> parentheticalContent = [];
    RegExp parenRegex = RegExp(r'\(([^)]+)\)');
    for (var match in parenRegex.allMatches(cleaned)) {
      String content = match.group(1)?.trim() ?? '';
      if (content.isNotEmpty) {
        parentheticalContent.add(content);
      }
    }

    // Remove parentheses and their content from main title
    String mainTitle = cleaned.replaceAll(parenRegex, ' ');

    // Remove brackets and their content
    mainTitle = mainTitle.replaceAll(RegExp(r'\[[^\]]*\]'), '');

    // Remove numbering patterns like "- 184"
    mainTitle = mainTitle.replaceAll(RegExp(r'\s*-\s*\d+\s*'), ' ');

    // Remove characters that are invalid on at least one target
    // platform, and trailing dots/spaces that Windows drops.
    mainTitle = mainTitle
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '')
        .replaceAll(RegExp(r'[.\s]+$'), '')
        .trim();

    // Convert main title to PascalCase
    String toPascalCase(String input) {
      List<String> words = input.split(RegExp(r'\s+'));
      words = words.where((w) => w.isNotEmpty).map((w) {
        String lower = w.toLowerCase();
        if (lower.length > 1) {
          return lower[0].toUpperCase() + lower.substring(1);
        }
        return lower.toUpperCase();
      }).toList();
      return words.join('');
    }

    String result = toPascalCase(mainTitle);

    // Add parenthetical content as separate parts
    for (var content in parentheticalContent) {
      String cleanedContent = content
          .replaceAll(RegExp(r'[<>:"/\\|?*]'), '')
          .replaceAll(RegExp(r'[.\s]+$'), '')
          .trim();
      String pascalContent = toPascalCase(cleanedContent);
      if (pascalContent.isNotEmpty) {
        result = "${result}_$pascalContent";
      }
    }

    return result;
  }

  // Truncate by runes so a multi-byte character is never split.
  String truncate(String text, int maxLength) {
    if (text.runes.length <= maxLength) return text;
    return String.fromCharCodes(text.runes.take(maxLength));
  }

  String safeTitle = extractAndCombineTitle(title);

  // Leave room for the id suffix and extension within filesystem limits
  String baseName = truncate(safeTitle, 180);

  // Remove trailing underscores
  baseName = baseName.replaceAll(RegExp(r'_+$'), '');

  // The book id is the best available stable unique key; keep it short
  // but never let it add path separators or spaces to the name.
  final hash = md5.replaceAll(RegExp(r'[^0-9A-Za-z]'), '');
  final hashSuffix = hash.length >= 8 ? hash.substring(0, 8) : hash;

  if (baseName.isEmpty) {
    baseName = hashSuffix.isNotEmpty ? hashSuffix : 'book';
  } else if (hashSuffix.isNotEmpty) {
    baseName = '${baseName}_$hashSuffix';
  }

  // Windows reserves these device names at every directory level.
  if (RegExp(r'^(con|prn|aux|nul|com[1-9]|lpt[1-9])$', caseSensitive: false)
      .hasMatch(baseName)) {
    baseName = '${baseName}_book';
  }

  return "$baseName.$format";
}

/// Lets the user pick the folder books are stored in.
///
/// On iOS the native folder picker can end up unusable (the Open button
/// greyed out on some document providers), so a cancelled pick falls
/// back to the app's Documents directory instead of leaving the user
/// stuck. Returns null only when a real pick succeeded and was applied.
Future<String?> pickBookStorageDirectory({bool? isIOS}) async {
  final onIOS = isIOS ?? Platform.isIOS;
  try {
    final picked = await FilePicker.getDirectoryPath();
    // null means the user cancelled - not an error, no fallback.
    return picked;
  } catch (e) {
    if (onIOS) {
      // The picker itself is broken (greyed-out Open button on some
      // document providers): fall back to the app's Documents
      // directory, which is always writable and shows up in the
      // Files app through UIFileSharingEnabled.
      return getApplicationDocumentsDirectory().then((dir) => dir.path);
    }
    rethrow;
  }
}

Future<String> get getBookStorageDefaultDirectory async {
  if (Platform.isAndroid) {
    final directory = await getExternalStorageDirectory();
    return directory!.path;
  } else {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}

Future<void> moveFilesToAndroidInternalStorage() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final directoryExternal = await getExternalStorageDirectory();
    List<FileSystemEntity> files = Directory(directory.path).listSync();
    for (var element in files) {
      if (isSupportedBookFile(element.path)) {
        String fileName = element.path.split('/').last;
        File file = File(element.path);
        file.copySync('${directoryExternal!.path}/$fileName');
        file.deleteSync();
      }
    }
  } catch (e) {
    // ignore: avoid_print
    print(e);
  }
}

Future<void> moveLibraryFiles(String sourcePath, String destinationPath) async {
  final source = Directory(sourcePath);
  if (!await source.exists()) return;

  await for (final entity in source.list(recursive: false)) {
    if (entity is File) {
      if (isSupportedBookFile(entity.path)) {
        try {
          final fileName = entity.path.split(Platform.pathSeparator).last;
          final newPath = '$destinationPath${Platform.pathSeparator}$fileName';

          // Ensure destination directory exists
          final destDir = Directory(destinationPath);
          if (!await destDir.exists()) {
            await destDir.create(recursive: true);
          }

          final destFile = File(newPath);
          if (!await destFile.exists()) {
            await entity.copy(newPath);
            await entity.delete();
          }
        } catch (e) {
          // ignore: avoid_print
          print("Error moving file: ${entity.path} -> $e");
        }
      }
    }
    // We intentionally ignore directories to avoid moving unwanted folders
  }
}

Future<bool> isFileExists(String filePath) async {
  return await File(filePath).exists();
}

Future<void> deleteFile(String filePath) async {
  if (await isFileExists(filePath) == true) {
    await File(filePath).delete();
  }
}

Future<String> getFilePath(String fileName) async {
  final bookStorageDirectory =
      await dataBase.getPreference('bookStorageDirectory');
  String filePath = '$bookStorageDirectory/$fileName';
  bool isExists = await isFileExists(filePath);
  if (isExists == true) {
    return filePath;
  }
  throw "File Not Exists";
}
