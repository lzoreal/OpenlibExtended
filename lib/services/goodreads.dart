// Package imports:
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;

// Project imports:
import 'package:openlib/services/network_error.dart';
import 'package:openlib/services/logger.dart';

class CategoryBookData {
  final String? title;
  final String? thumbnail;
  final String? link;
  final String? author;
  final String? rating;
  final String? published;

  CategoryBookData({
    this.title,
    this.thumbnail,
    this.link,
    this.author,
    this.rating,
    this.published,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryBookData &&
        other.title == title &&
        other.thumbnail == thumbnail &&
        other.link == link &&
        other.author == author &&
        other.rating == rating &&
        other.published == published;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        thumbnail.hashCode ^
        link.hashCode ^
        author.hashCode ^
        rating.hashCode ^
        published.hashCode;
  }
}

String baseUrl = "https://www.goodreads.com/";

class SubCategoriesTypeList {
  List<CategoryBookData> parseCategoryBooks(dynamic data) => _parser(data);

  String _cleanTitle(String title) => title.replaceFirst(
        RegExp(
          r'\s*\((?:mass market paperback|paperback|hardcover|kindle edition|ebook|audiobook)\)\s*$',
          caseSensitive: false,
        ),
        '',
      );

  List<CategoryBookData> _parser(dynamic data) {
    final document = parse(data.toString());
    final categoriesBooks = <CategoryBookData>[];
    final rows = document.querySelectorAll('.elementList');

    if (rows.isNotEmpty) {
      for (final row in rows) {
        final image =
            row.querySelector('.listImgs img') ?? row.querySelector('img');
        final thumbnail = image?.attributes['src'];
        final rawTitle = row.querySelector('a.bookTitle')?.text.trim() ??
            image?.attributes['title']?.trim();
        final title = rawTitle == null ? null : _cleanTitle(rawTitle);
        if (title == null || title.isEmpty || thumbnail == null) continue;

        final author = row.querySelector('a.authorName')?.text.trim();
        final stats = row.querySelector('.greyText.smallText')?.text.trim();
        final ratingMatch = stats == null
            ? null
            : RegExp(r'([0-9.]+)\s+avg rating|avg rating\s+([0-9.]+)')
                .firstMatch(stats);
        final rating = ratingMatch?.group(1) ?? ratingMatch?.group(2);
        final published = stats == null
            ? null
            : RegExp(
                r'(?:first\s+)?published\s+(?:in\s+)?(\d{4})',
                caseSensitive: false,
              ).firstMatch(stats)?.group(1);

        categoriesBooks.add(
          CategoryBookData(
            title: title,
            thumbnail: thumbnail
                .replaceAll("._SY75_.", "._SY225_.")
                .replaceAll("._SX50_.", "._SX148_."),
            link: row.querySelector('a.bookTitle')?.attributes['href'],
            author: author == null || author.isEmpty ? null : author,
            rating: rating,
            published: published,
          ),
        );
      }
      if (categoriesBooks.isNotEmpty) return categoriesBooks;
    }

    final categoryList = document.querySelectorAll('.listImgs a');
    for (final element in categoryList) {
      final image = element.querySelector('img');
      final title = image?.attributes['title']?.trim();
      final thumbnail = image?.attributes['src'];
      if (title == null || title.isEmpty || thumbnail == null) continue;
      categoriesBooks.add(
        CategoryBookData(
          title: title,
          thumbnail: thumbnail
              .replaceAll("._SY75_.", "._SY225_.")
              .replaceAll("._SX50_.", "._SX148_."),
          link: element.attributes['href'],
        ),
      );
    }
    return categoriesBooks;
  }

  Future<List<CategoryBookData>> categoriesBooks({required String url}) async {
    final logger = AppLogger();
    try {
      final dio = Dio();
      final tag = url.split('/').last;
      final shelf = await _fetchCategoryPages(dio, 'shelf/show/$tag');
      if (shelf.isNotEmpty) return shelf;
      return await _fetchCategoryPages(dio, url);
    } on DioException catch (e) {
      logger.error('Failed to fetch categories',
          tag: 'GoodReads', error: e.message ?? e.error);
      throw NetworkError.fromException(e,
          responseBody: e.response?.data?.toString());
    }
  }

  Future<List<CategoryBookData>> _fetchCategoryPages(
      Dio dio, String path) async {
    final options = Options(
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20));
    final response = await dio.get('$baseUrl$path', options: options);
    final response1 = await dio.get('$baseUrl$path?page=2', options: options);
    return _parser('${response.data.toString()}${response1.data.toString()}');
  }
}
