import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/data/services/goodreads.dart';

void main() {
  test('category parser keeps author, rating and published year', () {
    final html =
        File('test/fixtures/goodreads_category.html').readAsStringSync();
    final books = SubCategoriesTypeList().parseCategoryBooks(html);

    expect(books, hasLength(2));
    expect(books.first.title, '三体');
    expect(books.first.author, '刘慈欣');
    expect(books.first.rating, '4.12');
    expect(books.first.published, '2008');
    expect(books.first.link, '/book/show/1');
    expect(books.first.thumbnail, contains('._SY225_.'));
    expect(books.last.rating, '4.35');
    expect(books.last.published, '1993');
    expect(books.last.thumbnail, contains('._SX148_.'));
  });

  test('shelf listing keeps author, rating and published year', () {
    final html =
        File('test/fixtures/goodreads_shelf.html').readAsStringSync();
    final books = SubCategoriesTypeList().parseCategoryBooks(html);

    expect(books, hasLength(2));
    expect(books.first.title, 'Pride and Prejudice');
    expect(books.first.author, 'Jane Austen');
    expect(books.first.rating, '4.30');
    expect(books.first.published, '1813');
    expect(books.first.link, '/book/show/129915654-pride-and-prejudice');
    expect(books.first.thumbnail, contains('._SX148_.'));
    expect(books.last.author, 'Markus Zusak');
    expect(books.last.rating, '4.39');
    expect(books.last.published, '2005');
  });

  test('keeps series parentheticals while dropping edition suffixes', () {
    const html = '''
      <div class="elementList">
        <img src="https://images.example/little-women._SY75_.jpg" />
        <a class="bookTitle">Little Women (Little Women, #1)</a>
        <a class="authorName">Louisa May Alcott</a>
        <span class="greyText smallText">avg rating 4.24 — published 1868</span>
      </div>
    ''';
    final books = SubCategoriesTypeList().parseCategoryBooks(html);

    expect(books.single.title, 'Little Women (Little Women, #1)');
  });
}
