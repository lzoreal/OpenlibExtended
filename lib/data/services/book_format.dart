/// Book formats the app can label, filter, download, import and open.
///
/// Lowercase on purpose: this list is also the allowlist for file paths,
/// while the UI uppercases labels for display.
const List<String> bookFormats = [
  'pdf',
  'epub',
  'mobi',
  'azw3',
  'fb2',
  'djvu',
  'txt',
  'cbr',
  'cbz',
];

/// Kindle's older extension; readers treat it like AZW3.
const String _azwAlias = 'azw';

/// Token matching keeps words like "Textbook" or "epub3" from matching.
/// `azw3` precedes `azw` so AZW3 files are not truncated to the alias.
final RegExp _formatToken = RegExp(
  r'(?<![a-z0-9])(epub|pdf|mobi|azw3|azw|fb2|djvu|txt|cbr|cbz)(?![a-z0-9])',
  caseSensitive: false,
);

String? _normalize(String? format) {
  final value = format?.trim().toLowerCase();
  if (value == null || value.isEmpty) return null;
  return value == _azwAlias ? 'azw3' : value;
}

/// Reads the format token out of a catalog's free-form info string, e.g.
/// "English, EPUB, 2 MB".
String? detectBookFormat(String? info) {
  if (info == null || info.isEmpty) return null;
  final match = _formatToken.firstMatch(info);
  if (match == null) return null;
  return _normalize(match.group(1));
}

String? bookFormatLabel(String? format) {
  final normalized = _normalize(format);
  return normalized?.toUpperCase();
}

bool isSupportedBookFormat(String? format) {
  final normalized = _normalize(format);
  return normalized != null && bookFormats.contains(normalized);
}

bool isSupportedBookFile(String path) {
  final dot = path.lastIndexOf('.');
  if (dot == -1 || dot == path.length - 1) return false;
  return isSupportedBookFormat(path.substring(dot + 1));
}

String? bookFormatMimeType(String? format) {
  return switch (_normalize(format)) {
    'pdf' => 'application/pdf',
    'epub' => 'application/epub+zip',
    'mobi' => 'application/x-mobipocket-ebook',
    'azw3' => 'application/vnd.amazon.ebook',
    'fb2' => 'application/x-fictionbook+xml',
    'djvu' => 'image/vnd.djvu',
    'txt' => 'text/plain',
    'cbr' => 'application/vnd.comicbook-rar',
    'cbz' => 'application/vnd.comicbook+zip',
    _ => null,
  };
}
