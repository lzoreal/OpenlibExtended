// Project imports:
import 'package:openlib/data/models/book_detail_source.dart';

class BookData implements BookDetailSource {
  @override
  final String title;
  @override
  final String? author;
  @override
  final String? thumbnail;
  @override
  final String link;
  @override
  final String md5;
  @override
  final String? publisher;
  @override
  final String? info;

  /// A search row carries no description or format of its own; the
  /// detail page fills them in when the book page arrives.
  @override
  String? get description => null;

  @override
  String? get format => null;

  /// Which catalog produced this result, for UI labelling. Null on
  /// records that predate tagging (trending rows, older caches).
  final String? source;

  BookData(
      {required this.title,
      this.author,
      this.thumbnail,
      required this.link,
      required this.md5,
      this.publisher,
      this.info,
      this.source});

  BookData copyWith({String? source, String? thumbnail}) => BookData(
        title: title,
        author: author,
        thumbnail: thumbnail ?? this.thumbnail,
        link: link,
        md5: md5,
        publisher: publisher,
        info: info,
        source: source ?? this.source,
      );
}

class BookInfoData extends BookData {
  String? mirror;
  @override
  final String? description;
  @override
  final String? format;
  bool isFastDownload;

  BookInfoData(
      {required super.title,
      required super.author,
      required super.thumbnail,
      required super.publisher,
      required super.info,
      required super.link,
      required super.md5,
      required this.format,
      required this.mirror,
      required this.description,
      this.isFastDownload = false});
}
