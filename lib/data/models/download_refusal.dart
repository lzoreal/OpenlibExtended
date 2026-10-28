/// Stable refusal codes produced by the mirror providers.
///
/// The data layer never returns user-facing text: the detail page maps these
/// codes to localized strings, so every mirror reason reads in the app's
/// current language.
class DownloadRefusal {
  const DownloadRefusal._();

  static const zlibNoDownloadLink = 'zlib:no-download-link';
  static const zlibDailyLimit = 'zlib:daily-limit';
  static const zlibSignIn = 'zlib:sign-in';

  static const welibNoDownloadLink = 'welib:no-download-link';
  static const welibPageUnreadable = 'welib:page-unreadable';
  static const welibRateLimit = 'welib:rate-limit';
  static const welibBotCheck = 'welib:bot-check';
}
