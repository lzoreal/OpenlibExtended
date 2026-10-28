// Display labels and persisted values shared by the search filters.

Map<String, String> typeValues = {
  'All': '',
  'Any Books': 'book_any',
  'Unknown Books': 'book_unknown',
  'Fiction Books': 'book_fiction',
  'Non-fiction Books': 'book_nonfiction',
  'Comic Books': 'book_comic',
  'Magazine': 'magazine',
  'Standards Document': 'standards_document',
  'Journal Article': 'journal_article'
};

Map<String, String> sortValues = {
  'Most Relevant': '',
  'Newest': 'newest',
  'Oldest': 'oldest',
  'Largest': 'largest',
  'Smallest': 'smallest',
};

// Values double as the persisted filterFileType preference, so keep the
// historical casing of the original entries; chips display them uppercase.
List<String> fileType = [
  "All",
  "PDF",
  "Epub",
  "Mobi",
  "Azw3",
  "Fb2",
  "Djvu",
  "Txt",
  "Cbr",
  "Cbz",
];

// Language filter values (display name: code)
Map<String, String> languageValues = {
  "All": "",
  "English": "en",
  "Spanish": "es",
  "French": "fr",
  "German": "de",
  "Italian": "it",
  "Portuguese": "pt",
  "Russian": "ru",
  "Chinese": "zh",
  "Japanese": "ja",
  "Korean": "ko",
  "Arabic": "ar",
  "Hindi": "hi",
  "Malayalam": "ml",
  "Dutch": "nl",
  "Polish": "pl",
  "Turkish": "tr",
  "Swedish": "sv",
  "Indonesian": "id",
  "Vietnamese": "vi",
  "Czech": "cs",
  "Greek": "el",
  "Romanian": "ro",
  "Hungarian": "hu",
  "Ukrainian": "uk",
  "Hebrew": "he",
  "Thai": "th",
  "Persian": "fa",
  "Bengali": "bn",
  "Finnish": "fi",
  "Norwegian": "no",
  "Danish": "da",
};

// Reverse map: language code to uppercase display code
Map<String, String> languageCodeToDisplay = {
  "en": "EN",
  "es": "ES",
  "fr": "FR",
  "de": "DE",
  "it": "IT",
  "pt": "PT",
  "ru": "RU",
  "zh": "ZH",
  "ja": "JA",
  "ko": "KO",
  "ar": "AR",
  "hi": "HI",
  "ml": "ML",
  "nl": "NL",
  "pl": "PL",
  "tr": "TR",
  "sv": "SV",
  "id": "ID",
  "vi": "VI",
  "cs": "CS",
  "el": "EL",
  "ro": "RO",
  "hu": "HU",
  "uk": "UK",
  "he": "HE",
  "th": "TH",
  "fa": "FA",
  "bn": "BN",
  "fi": "FI",
  "no": "NO",
  "da": "DA",
};

// Year filter values for publishing year range
List<String> yearValues = [
  "All",
  "2025",
  "2024",
  "2023",
  "2022",
  "2021",
  "2020",
  "2019",
  "2018",
  "2017",
  "2016",
  "2015",
  "2010-2014",
  "2005-2009",
  "2000-2004",
  "1990-1999",
  "1980-1989",
  "Before 1980",
];
