// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:openlib/app/di.dart';
import 'package:openlib/data/repositories/download_repository.dart';
import 'package:openlib/data/repositories/library_repository.dart';
import 'package:openlib/data/repositories/search_repository.dart';

final libraryRepositoryProvider =
    Provider<LibraryRepository>((ref) => getIt<LibraryRepository>());

final searchRepositoryProvider =
    Provider<SearchRepository>((ref) => getIt<SearchRepository>());

final downloadRepositoryProvider =
    Provider<DownloadRepository>((ref) => getIt<DownloadRepository>());
