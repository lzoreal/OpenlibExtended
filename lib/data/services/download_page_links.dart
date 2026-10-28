// What a download-page poller should read from the page currently open.
//
// Split from the webview widget so the silent WeLib waiter and both
// pollers (mobile and desktop) share one rule: a sign-in page carries no
// file link, and reading anchors there queues navigation links as mirrors.

/// True for WeLib's `/account/?redirect_after_login=...` form (and the
/// equivalent Z-Library routes).
bool isLoginUrl(String url) {
  final lower = url.toLowerCase();
  return lower.contains('/account') ||
      lower.contains('login') ||
      lower.contains('register');
}

enum DownloadPageKind {
  /// A sign-in / registration page; wait for the site to send the user
  /// back to the download page.
  wait,

  /// The page carries the file link itself.
  fileLink,

  /// A mirror list page; every list anchor is a candidate file.
  mirrorList,
}

DownloadPageKind downloadPageKindFor(String url) {
  if (isLoginUrl(url)) return DownloadPageKind.wait;
  if (url.toLowerCase().contains('slow_download')) {
    return DownloadPageKind.fileLink;
  }
  return DownloadPageKind.mirrorList;
}
