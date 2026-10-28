/// The fields a book surface needs, shared by search results, fetched
/// details and library records. The detail page renders one of these
/// while the full detail page is still loading.
abstract interface class BookDetailSource {
  String get title;
  String? get author;
  String? get thumbnail;
  String get link;
  String? get md5;
  String? get publisher;
  String? get info;
  String? get description;
  String? get format;
}
