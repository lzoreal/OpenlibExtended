// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:openlib/app/di.dart';
import 'package:openlib/data/repositories/library_repository.dart';

final libraryRepositoryProvider =
    Provider<LibraryRepository>((ref) => getIt<LibraryRepository>());
