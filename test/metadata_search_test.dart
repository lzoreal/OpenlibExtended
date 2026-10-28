// Real tests for metadata-aware search: how the provider mappers turn
// advanced-search fields into backend-native parameters. URL building is
// pure string logic - tested directly, no network.

// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:openlib/data/services/annas_archieve.dart';
import 'package:openlib/data/services/search_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final api = AnnasArchieve();
  const base = 'https://annas-archive.example';

  group("Anna's Archive field-scoped query", () {
    test('author and publisher become q= field terms', () {
      final url = api.urlEncoder(
        searchQuery: 'hobbit',
        content: '',
        sort: '',
        fileType: '',
        language: '',
        year: '',
        author: 'j r r tolkien',
        publisher: 'harper collins',
        enableFilters: true,
        currentBaseUrl: base,
      );
      expect(url, startsWith('$base/search?index=&sort='));
      expect(
          url,
          contains(
              'q=author:%22j+r+r+tolkien%22+publisher:%22harper+collins%22+hobbit'));
    });

    test('fields without values keep the plain query untouched', () {
      final url = api.urlEncoder(
        searchQuery: 'dune',
        content: '',
        sort: '',
        fileType: '',
        language: '',
        year: '',
        author: '',
        publisher: '',
        enableFilters: true,
        currentBaseUrl: base,
      );
      expect(url, contains('q=dune'));
      expect(url, isNot(contains('author:')));
      expect(url, isNot(contains('publisher:')));
    });

    test('whitespace-only fields are ignored', () {
      final url = api.urlEncoder(
        searchQuery: 'dune',
        content: '',
        sort: '',
        fileType: '',
        language: '',
        year: '',
        author: '   ',
        publisher: '',
        enableFilters: true,
        currentBaseUrl: base,
      );
      expect(url, isNot(contains('author:')));
    });
  });

  group('SearchQuery metadata plumbing', () {
    test('isEmpty is false when only metadata fields are set', () {
      const query = SearchQuery(text: '', author: 'tolkien');
      expect(query.isEmpty, isFalse);
      expect(const SearchQuery(text: '').isEmpty, isTrue);
    });
  });

  group('Libgen columns mapping', () {
    test('author-only search targets the author column', () async {
      final requested = <Uri>[];
      final dio = _RecordingDio(requested);
      final provider = LibgenProvider(dio: dio, mirrors: ['https://lg.example']);

      try {
        await provider.search(const SearchQuery(
          text: '',
          author: 'Asimov',
          filtersEnabled: true,
        ));
      } catch (_) {
        // Recording Dio throws after capture; the URL is what matters.
      }

      expect(requested, isNotEmpty);
      final uri = requested.single;
      expect(uri.queryParameters['req'], 'Asimov');
      expect(uri.queryParametersAll['columns[]'], contains('a'));
      expect(uri.queryParametersAll['columns[]'], isNot(contains('p')));
    });

    test('author plus text are folded into req together', () async {
      final requested = <Uri>[];
      final dio = _RecordingDio(requested);
      final provider = LibgenProvider(dio: dio, mirrors: ['https://lg.example']);

      try {
        await provider.search(const SearchQuery(
          text: 'foundation',
          author: 'Asimov',
          filtersEnabled: true,
        ));
      } catch (_) {}

      expect(requested, isNotEmpty);
      expect(requested.single.queryParameters['req'], 'Asimov foundation');
    });

    test('plain searches never send columns', () async {
      final requested = <Uri>[];
      final dio = _RecordingDio(requested);
      final provider = LibgenProvider(dio: dio, mirrors: ['https://lg.example']);

      try {
        await provider.search(const SearchQuery(text: 'foundation'));
      } catch (_) {}

      expect(requested, isNotEmpty);
      expect(requested.single.queryParameters.containsKey('columns'), isFalse);
    });

    test('metadata fields are skipped when filters are disabled', () async {
      final requested = <Uri>[];
      final dio = _RecordingDio(requested);
      final provider = LibgenProvider(dio: dio, mirrors: ['https://lg.example']);

      try {
        await provider.search(const SearchQuery(
          text: 'foundation',
          author: 'Asimov',
          filtersEnabled: false,
        ));
      } catch (_) {}

      expect(requested, isNotEmpty);
      expect(requested.single.queryParameters['req'], 'foundation');
      expect(requested.single.queryParameters.containsKey('columns'), isFalse);
    });
  });
}

/// A Dio substitute that records the request URL and throws - the
/// libgen search loop then moves on and reports failure, but the test
/// already captured what it needs: the exact query string.
class _RecordingDio implements Dio {
  _RecordingDio(this.requests);

  final List<Uri> requests;

  @override
  Future<Response<T>> get<T>(String path,
      {Object? data,
      Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onReceiveProgress}) async {
    requests.add(Uri.parse(path));
    throw Exception('recording stop');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
