/// Identifies a book file for open/delete actions.
class FileName {
  final String md5;
  final String format;
  final String? fileName;

  FileName({required this.md5, required this.format, this.fileName});
}
