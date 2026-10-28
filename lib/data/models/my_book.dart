// Project imports:
import 'package:openlib/data/models/book_detail_source.dart';

class MyBook implements BookDetailSource {
  final String id;
  @override
  final String title;
  @override
  final String? author;
  @override
  final String? thumbnail;
  @override
  final String link;
  @override
  final String? publisher;
  @override
  final String? info;
  @override
  final String? description;
  @override
  final String? format;
  final String? fileName;

  MyBook(
      {required this.id,
      required this.title,
      required this.author,
      required this.thumbnail,
      required this.link,
      required this.publisher,
      required this.info,
      required this.format,
      required this.description,
      this.fileName});

  // Getter for compatibility with the detail page, which expects 'md5'.
  @override
  String get md5 => id;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'thumbnail': thumbnail,
      'link': link,
      'publisher': publisher,
      'info': info,
      'format': format,
      'description': description,
      'fileName': fileName
    };
  }

  @override
  String toString() {
    return 'MyBook{id: $id,title: $title,author: $author,thumbnail: $thumbnail,link: $link,publisher: $publisher,info: $info,format: $format,description:$description,fileName:$fileName}';
  }

  // Get actual filename - uses fileName if available, otherwise falls back to id.format
  String getFileName() {
    if (fileName != null && fileName!.isNotEmpty) {
      return fileName!;
    }
    return "$id.$format";
  }
}
