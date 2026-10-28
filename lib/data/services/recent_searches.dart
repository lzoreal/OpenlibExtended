// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:openlib/data/services/database.dart';

const int maxRecentSearches = 6;
const String recentSearchesPreferenceKey = 'recentSearches';

/// Pure list update used by the persistent store and its tests.
List<String> withRecentSearch(List<String> current, String query,
    {int limit = maxRecentSearches}) {
  final clean = query.trim();
  if (clean.isEmpty) return List<String>.of(current);
  final lower = clean.toLowerCase();
  final next = [
    clean,
    ...current.where((entry) => entry.toLowerCase() != lower),
  ];
  return next.take(limit).toList();
}

List<String> withoutRecentSearch(List<String> current, String query) {
  return [
    for (final entry in current)
      if (entry != query) entry,
  ];
}

/// Persistence seam so the notifier can be tested without a database.
abstract class RecentSearchStore {
  Future<List<String>> load();
  Future<void> save(List<String> searches);
}

class DbRecentSearchStore implements RecentSearchStore {
  @override
  Future<List<String>> load() async {
    try {
      final raw = await MyLibraryDb.instance
          .getPreference(recentSearchesPreferenceKey);
      if (raw is! String || raw.isEmpty) return const [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<String>()
          .map((entry) => entry.trim())
          .where((entry) => entry.isNotEmpty)
          .take(maxRecentSearches)
          .toList();
    } catch (_) {
      // Missing preferences and old/corrupt values are simply no history.
      return const [];
    }
  }

  @override
  Future<void> save(List<String> searches) async {
    try {
      await MyLibraryDb.instance.savePreference(
          recentSearchesPreferenceKey, jsonEncode(searches));
    } catch (_) {
      // History is a convenience; a failed write must never block a search.
    }
  }
}
