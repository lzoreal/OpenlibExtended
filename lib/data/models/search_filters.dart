enum SearchFilterKind { type, sort, fileType, language, year }

class SearchFilters {
  const SearchFilters({
    this.type = 'All',
    this.sort = 'Most Relevant',
    this.fileType = 'All',
    this.language = 'All',
    this.year = 'All',
  });

  final String type;
  final String sort;
  final String fileType;
  final String language;
  final String year;

  SearchFilters copyWith({
    String? type,
    String? sort,
    String? fileType,
    String? language,
    String? year,
  }) {
    return SearchFilters(
      type: type ?? this.type,
      sort: sort ?? this.sort,
      fileType: fileType ?? this.fileType,
      language: language ?? this.language,
      year: year ?? this.year,
    );
  }
}
