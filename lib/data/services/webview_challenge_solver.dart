// Cross-platform DDoS-challenge solver.
//
// Anna's Archive is protected by DDoS-Guard. Its clearance cookies are HttpOnly
// AND bound to the browser context, so extracting them and replaying through Dio
// never works (that was the alpha's approach and it loops 403 forever). Instead
// we let a real browser engine pass the challenge and capture the fully rendered
// page HTML:
//
//   - Android/iOS: HeadlessInAppWebView runs invisible and automatic. If a real
//     human CAPTCHA appears, callers fall back to the visible solver page.
//   - Linux/Windows/macOS: desktop_webview_window opens a visible window (the
//     challenge usually auto-passes within seconds).
//
// Captured HTML is stored in ChallengeHtmlCache keyed by the request URL, so a
// retry ("Try Again") or another mirror attempt can parse it directly.

// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:desktop_webview_window/desktop_webview_window.dart'
    as desktop_webview;
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// Project imports:
import 'package:openlib/data/services/challenge_html_cache.dart';
import 'package:openlib/data/services/logger.dart';
import 'package:openlib/data/services/platform_utils.dart';

class WebviewChallengeSolver {
  WebviewChallengeSolver._();

  static final AppLogger _logger = AppLogger();

  /// Android/iOS use flutter_inappwebview; desktop uses desktop_webview_window.
  static bool get isSupported =>
      PlatformUtils.isMobile || PlatformUtils.isDesktop;

  /// Escape hatch for tests and headless environments: when false, no real
  /// webview is opened (headless or desktop window) and the solve returns
  /// null — but a registered [visibleSolverFallback] is still consulted,
  /// so tests can exercise the fallback without any webview.
  static bool guiEnabled = true;

  /// When false (user turned "verify in background" off in settings), the
  /// headless attempt is skipped on mobile and the visible window runs
  /// straight away - some devices never finish an invisible webview.
  static bool headlessEnabled = true;

  /// UI hook: when a headless mobile solve fails, this is called so the app
  /// shell to push the visible solver page over the current screen. It
  /// returns the captured HTML (which we then cache) or null when the user
  /// backs out without solving. A callback keeps this service free of UI
  /// imports. Registered by the app shell at startup.
  static Future<String?> Function(String url)? visibleSolverFallback;

  /// URLs currently waiting on an invisible solve, so the UI can offer the
  /// verification page right away instead of letting the user watch a
  /// spinner for the whole headless timeout.
  static final ValueNotifier<List<String>> pendingChallenges =
      ValueNotifier(const []);

  static void _addPending(String url) {
    if (pendingChallenges.value.contains(url)) return;
    pendingChallenges.value = [...pendingChallenges.value, url];
  }

  static void _removePending(String url) {
    if (!pendingChallenges.value.contains(url)) return;
    pendingChallenges.value =
        pendingChallenges.value.where((value) => value != url).toList();
  }

  /// Hosts whose headless attempt already failed: the invisible webview
  /// cannot pass these, so later challenges skip straight to the visible
  /// page. The first attempt still runs the full timeout.
  static const Duration _headlessRetryAfter = Duration(minutes: 30);
  static final Map<String, DateTime> _headlessFailures = {};

  /// Automatic solving (headless plus visible fallback) already failed for
  /// this host recently. Later searches must not spend another full timeout
  /// or auto-open the verification page; the user can retry manually.
  static const Duration _autoSolveRetryAfter = Duration(minutes: 30);
  static final Map<String, DateTime> _autoSolveFailures = {};

  /// Blocked URLs whose automatic solve failed, for the results page's
  /// manual verification banner.
  static final ValueNotifier<List<String>> failedChallenges =
      ValueNotifier(const []);

  static String _failureHost(String url) => Uri.tryParse(url)?.host ?? url;

  static bool _autoSolveRecentlyFailed(String url) {
    final host = _failureHost(url);
    final at = _autoSolveFailures[host];
    if (at == null) return false;
    if (DateTime.now().difference(at) > _autoSolveRetryAfter) {
      _autoSolveFailures.remove(host);
      return false;
    }
    return true;
  }

  static void _rememberAutoSolveFailure(String url) {
    _autoSolveFailures[_failureHost(url)] = DateTime.now();
    _addFailed(url);
  }

  static void _clearAutoSolveFailure(String url) {
    final host = _failureHost(url);
    _autoSolveFailures.remove(host);
    failedChallenges.value = [
      for (final candidate in failedChallenges.value)
        if (_failureHost(candidate) != host) candidate,
    ];
  }

  static void _addFailed(String url) {
    if (url.isEmpty) return;
    final current = failedChallenges.value;
    if (current.contains(url)) return;
    failedChallenges.value = [...current, url].take(4).toList();
  }

  @visibleForTesting
  static void clearAutoSolveFailures() {
    _autoSolveFailures.clear();
    failedChallenges.value = const [];
  }

  @visibleForTesting
  static bool autoSolveRecentlyFailed(String url) =>
      _autoSolveRecentlyFailed(url);

  @visibleForTesting
  static void debugRememberAutoSolveFailure(String url) =>
      _rememberAutoSolveFailure(url);

  /// Solved browser sessions kept alive per host, so a later search on the
  /// same site reuses the clearance instead of verifying again. The list
  /// is trimmed to the newest [_maxSessions].
  static const int _maxSessions = 2;
  static final Map<String, _SolvedSession> _sessions = {};

  @visibleForTesting
  static void clearHeadlessFailures() => _headlessFailures.clear();

  @visibleForTesting
  static void clearPendingChallenges() => pendingChallenges.value = const [];

  @visibleForTesting
  static int get sessionCount => _sessions.length;

  @visibleForTesting
  static Future<void> clearSessions() async {
    final sessions = _sessions.values.toList();
    _sessions.clear();
    for (final session in sessions) {
      await session.dispose();
    }
  }

  static bool _headlessRecentlyFailed(String url) {
    final host = Uri.tryParse(url)?.host ?? url;
    final at = _headlessFailures[host];
    if (at == null) return false;
    if (DateTime.now().difference(at) > _headlessRetryAfter) {
      _headlessFailures.remove(host);
      return false;
    }
    return true;
  }

  /// Whether an invisible solve is worth attempting for [url]: skipped on
  /// mobile for hosts whose invisible attempt already failed recently,
  /// because repeating it only costs the user another full timeout.
  @visibleForTesting
  static bool shouldTryHeadless(String url) =>
      guiEnabled &&
      !(_isMobile && _headlessRecentlyFailed(url)) &&
      (headlessEnabled || !_isMobile);

  @visibleForTesting
  static void debugRememberHeadlessFailure(String url) =>
      _rememberHeadlessFailure(url);

  static void _rememberHeadlessFailure(String url) {
    _headlessFailures[Uri.tryParse(url)?.host ?? url] = DateTime.now();
  }

  /// Opens the visible verification page for [url] and resolves once the
  /// user is done. Idempotent: a second tap while the page is already open
  /// does nothing. The captured HTML lands in [ChallengeHtmlCache], which
  /// is what unblocks the provider still waiting on this URL.
  static Future<void> requestVisibleSolve(String url) async {
    final fallback = visibleSolverFallback;
    if (fallback == null || _visibleSolveInFlight.contains(url)) return;
    _visibleSolveInFlight.add(url);
    try {
      final html = await fallback(url);
      if (html != null) {
        ChallengeHtmlCache.store(url, html);
        _clearAutoSolveFailure(url);
      }
    } finally {
      _visibleSolveInFlight.remove(url);
      _removePending(url);
    }
  }

  static final Set<String> _visibleSolveInFlight = {};

  /// Fetches [url] through the already-cleared browser session of its host,
  /// when one exists. This is what makes the second and later searches on
  /// a gated site skip verification entirely. Null when there is no
  /// session (or it is busy / the page is still gated), and callers then
  /// fall back to the normal HTTP path.
  static Future<String?> fetchWithSession(String url) async {
    final host = Uri.tryParse(url)?.host;
    if (host == null) return null;
    final session = _sessions[host];
    if (session == null || session.busy) return null;
    session.busy = true;
    try {
      final controller = session.controller;
      await controller.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
      final deadline = DateTime.now().add(const Duration(seconds: 20));
      while (DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 700));
        try {
          final title = (await controller.getTitle()) ?? '';
          if (title.isNotEmpty &&
              !isChallengePage(title: title, bodySnippet: '')) {
            final html = await _captureHtml(controller);
            if (html != null && html.isNotEmpty) {
              ChallengeHtmlCache.store(url, html);
              return html;
            }
          }
        } catch (_) {
          // Keep polling until the deadline.
        }
      }
      return null;
    } catch (_) {
      return null;
    } finally {
      session.busy = false;
    }
  }

  static void _keepSession(
      String url, HeadlessInAppWebView webview, InAppWebViewController? controller) {
    final host = Uri.tryParse(url)?.host;
    if (host == null || controller == null) {
      return;
    }
    final existing = _sessions.remove(host);
    if (existing != null && !identical(existing.webview, webview)) {
      existing.dispose();
    }
    _sessions[host] = _SolvedSession(host, webview, controller);
    while (_sessions.length > _maxSessions) {
      final oldest = _sessions.keys.first;
      final dropped = _sessions.remove(oldest);
      dropped?.dispose();
    }
  }

  /// Test seam for the mobile/desktop branch: when set, overrides the real
  /// platform check. Production never sets it.
  @visibleForTesting
  static bool? overrideIsMobile;

  static bool get _isMobile => overrideIsMobile ?? PlatformUtils.isMobile;

  /// Returns true when the given page looks like an unfinished DDoS protection
  /// challenge (DDoS-Guard or Cloudflare) instead of real content.
  static bool isChallengePage({
    required String title,
    required String bodySnippet,
  }) {
    final t = title.toLowerCase();
    final b = bodySnippet.toLowerCase();
    const titleMarkers = [
      'ddos-guard',
      'just a moment',
      'attention required',
      'checking your browser',
      // Cloudflare localizes the interstitial title to the browser locale.
      '请稍候',
      'einen moment',
      'un instant',
      'un momento',
    ];
    const bodyMarkers = [
      'ddos-guard/js-challenge',
      'check.ddos-guard.net',
      'ddg-l10n-title',
      'cf-turnstile',
      'challenge-platform',
      'cf-browser-verification',
    ];
    return titleMarkers.any(t.contains) || bodyMarkers.any(b.contains);
  }

  /// Solves the challenge for [url] and returns the fully rendered page HTML,
  /// or null if the challenge could not be cleared within [timeout].
  ///
  /// Desktop opens a visible window (default 3 min — the user may need to
  /// click a checkbox); mobile runs a headless webview (default 60 s,
  /// fully automatic). The result is also stored in ChallengeHtmlCache.
  ///
  /// On mobile, a headless failure falls back to [visibleSolverFallback]
  /// when it is registered (headless misses human CAPTCHAs and races like
  /// the loadStop/readyState one); the desktop window is already visible,
  /// so no fallback is needed there.
  static Future<String?> fetchHtmlAfterChallenge(
    String url, {
    Duration? timeout,
  }) async {
    if (!isSupported) return null;
    if (_autoSolveRecentlyFailed(url)) {
      _addFailed(url);
      return null;
    }

    final effectiveTimeout = timeout ??
        (_isMobile ? const Duration(seconds: 60) : const Duration(minutes: 3));

    // A host whose invisible attempt already failed goes straight to the
    // visible page: repeating a solve that cannot pass only made the user
    // wait the whole timeout again.
    final tryHeadless = shouldTryHeadless(url);
    var html = tryHeadless
        ? (_isMobile
            ? await _solveHeadless(url, effectiveTimeout)
            : await _solveDesktopWindow(url, effectiveTimeout))
        : null;

    if (tryHeadless) {
      if (html == null && _isMobile) {
        _rememberHeadlessFailure(url);
      } else if (html != null) {
        _headlessFailures.remove(Uri.tryParse(url)?.host ?? url);
      }
    }

    if (html == null && _isMobile && visibleSolverFallback != null) {
      _logger.info('Headless solve failed, using visible fallback',
          tag: 'ChallengeSolver', metadata: {'url': url});
      html = await visibleSolverFallback!(url);
    }

    if (html != null) {
      ChallengeHtmlCache.store(url, html);
      _clearAutoSolveFailure(url);
    } else {
      _rememberAutoSolveFailure(url);
    }
    return html;
  }

  // ------------------------------------------------------------------
  // MOBILE: HeadlessInAppWebView (invisible, automatic)
  // ------------------------------------------------------------------

  /// Decides whether an onLoadStop may complete the solve. Only a real page
  /// with captured HTML counts — a loadStop on a page that is still loading
  /// (null/empty HTML) must NOT complete, or the poll loop below would be
  /// dead and the solve would return null even though the challenge had
  /// already been cleared. See the Android log regression this guards.
  @visibleForTesting
  static bool shouldCompleteFromLoadStop(String title, String? capturedHtml) =>
      capturedHtml != null &&
      capturedHtml.isNotEmpty &&
      !isChallengePage(title: title, bodySnippet: '');

  static Future<String?> _solveHeadless(String url, Duration timeout) async {
    HeadlessInAppWebView? headless;
    InAppWebViewController? controller;
    var keepSession = false;
    // The UI offers the visible page while this runs; a solve done there
    // lands in the cache and is picked up below.
    _addPending(url);
    try {
      final completer = Completer<String?>();
      final controllerHolder = Completer<InAppWebViewController>();

      headless = HeadlessInAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          supportZoom: false,
          incognito: false,
          clearCache: false,
        ),
        onLoadStop: (controller, loadedUrl) async {
          try {
            final title = (await controller.getTitle()) ?? '';
            final bodySnippet = (await _js(controller,
                    "document.body ? document.body.innerHTML.slice(0, 3000) : ''")) ??
                '';
            _logger.debug('Headless load stopped',
                tag: 'ChallengeSolver',
                metadata: {'title': title, 'url': loadedUrl.toString()});
            if (isChallengePage(title: title, bodySnippet: bodySnippet)) {
              return; // challenge page; wait for next load
            }
            // Not ready yet (readyState != complete)? Just wait — the poll
            // loop picks the page up. Never complete with null here: that
            // used to kill the solve right after the challenge was cleared.
            final html = await _captureHtml(controller);
            if (shouldCompleteFromLoadStop(title, html) &&
                !completer.isCompleted) {
              completer.complete(html);
            }
          } catch (e) {
            _logger.debug('Headless onLoadStop check failed',
                tag: 'ChallengeSolver', metadata: {'error': e.toString()});
          }
        },
        onWebViewCreated: (controller) {
          if (!controllerHolder.isCompleted) {
            controllerHolder.complete(controller);
          }
        },
      );

      unawaited(headless.run());
      final deadline = DateTime.now().add(timeout);
      final session = headless;
      while (DateTime.now().isBefore(deadline)) {
        if (completer.isCompleted) break;
        // Someone solved this URL elsewhere (the user tapping "verify now"
        // in the results page): use that HTML instead of waiting out the
        // deadline for a solve that already happened.
        final cached = ChallengeHtmlCache.get(url);
        if (cached != null) {
          completer.complete(cached);
          break;
        }
        // Headless webviews can stop loading without an onLoadStop for the
        // final page; also poll the controller directly.
        try {
          controller ??= await _waitForController(controllerHolder);
          if (controller != null) {
            final title = (await controller.getTitle()) ?? '';
            if (title.isNotEmpty &&
                !isChallengePage(title: title, bodySnippet: '')) {
              final html = await _captureHtml(controller);
              if (html != null && html.isNotEmpty && !completer.isCompleted) {
                completer.complete(html);
              }
            }
          }
        } catch (_) {}
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      // The only place the completer may complete with null: the deadline.
      if (!completer.isCompleted) completer.complete(null);
      final html = await completer.future;
      final solvedController = controller;
      if (html != null && solvedController != null) {
        // Keep this cleared webview alive: the next search on the same
        // host can navigate it instead of verifying all over again.
        _keepSession(url, session, solvedController);
        keepSession = true;
      }
      return html;
    } catch (e, st) {
      _logger.error('Headless challenge solver failed',
          tag: 'ChallengeSolver', error: e, stackTrace: st);
      return null;
    } finally {
      if (!keepSession) {
        try {
          await headless?.dispose();
        } catch (_) {}
      }
      _removePending(url);
    }
  }

  static Future<InAppWebViewController?> _waitForController(
      Completer<InAppWebViewController> completer) async {
    if (completer.isCompleted) return await completer.future;
    // Poll the completer without a typed onTimeout closure.
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (DateTime.now().isBefore(deadline)) {
      if (completer.isCompleted) return await completer.future;
      await Future.delayed(const Duration(milliseconds: 200));
    }
    return null;
  }

  // ------------------------------------------------------------------
  // DESKTOP: visible desktop_webview_window
  // ------------------------------------------------------------------

  static Future<String?> _solveDesktopWindow(
      String url, Duration timeout) async {
    desktop_webview.Webview? webview;
    var closedByUser = false;
    try {
      webview = await desktop_webview.WebviewWindow.create(
        configuration: const desktop_webview.CreateConfiguration(
          windowHeight: 700,
          windowWidth: 1000,
          title: "Verifying access...",
        ),
      );
      webview.onClose.then((_) => closedByUser = true);
      // The plugin cancels the first navigation and only re-issues it after a
      // Dart URL-request callback; without one the window stays about:blank.
      webview.setOnUrlRequestCallback((_) => true);
      webview.launch(url, triggerOnUrlRequestEvent: false);

      final deadline = DateTime.now().add(timeout);
      var titleOkPolls = 0;
      while (DateTime.now().isBefore(deadline)) {
        await Future.delayed(const Duration(milliseconds: 1500));
        if (closedByUser) {
          _logger.info('Challenge webview closed by user',
              tag: 'ChallengeSolver');
          return null;
        }

        final title = await _js(webview, "document.title") ?? '';
        final bodySnippet = await _js(
              webview,
              "(document.body ? document.body.innerHTML.slice(0, 3000) : '')",
            ) ??
            '';

        if (title.isEmpty && bodySnippet.isEmpty) continue;

        if (isChallengePage(title: title, bodySnippet: bodySnippet)) {
          titleOkPolls = 0;
          _logger.debug('Challenge still active',
              tag: 'ChallengeSolver',
              metadata: {'title': title.isEmpty ? '(none)' : title});
          continue;
        }

        final readyState = await _js(webview, "document.readyState") ?? '';
        if (readyState != 'complete') {
          titleOkPolls++;
          _logger.debug('Page rendering, waiting for readyState=complete',
              tag: 'ChallengeSolver',
              metadata: {'readyState': readyState, 'polls': titleOkPolls});
          if (titleOkPolls < 10) continue;
        }

        // Some results pages inject their list after readyState flips;
        // capturing straight away stores the empty shell and parses to zero.
        await Future.delayed(const Duration(seconds: 2));
        final settledTitle = await _js(webview, "document.title") ?? '';
        if (isChallengePage(title: settledTitle, bodySnippet: '')) {
          titleOkPolls = 0;
          _logger.debug('Challenge reappeared while settling',
              tag: 'ChallengeSolver');
          continue;
        }

        final html = await _js(webview, "document.documentElement.outerHTML");
        if (html != null && html.isNotEmpty) {
          _logger.info('Challenge solved, captured page HTML',
              tag: 'ChallengeSolver',
              metadata: {'length': html.length, 'title': title});
          _closeSolvedWindow(webview);
          return html;
        }
      }
      _logger.warning('Challenge solver timed out', tag: 'ChallengeSolver');
      return null;
    } catch (e, st) {
      _logger.error('Desktop challenge solver failed',
          tag: 'ChallengeSolver', error: e, stackTrace: st);
      return null;
    } finally {
      // Closing programmatically crashed GTK in earlier versions; the user
      // closes the window manually.
      webview = null;
    }
  }

  /// Windows keeps the native verification window open after a successful
  /// solve; close it so the user is not left with a stale page. Linux still
  /// needs a manual close because programmatic closing crashed GTK.
  static void _closeSolvedWindow(desktop_webview.Webview webview) {
    if (!PlatformUtils.isWindows) return;
    try {
      webview.close();
    } catch (_) {
      // Already closed by the user.
    }
  }

  // ------------------------------------------------------------------
  // SHARED HELPERS
  // ------------------------------------------------------------------

  /// Captures outerHTML once the document is complete and settled.
  static Future<String?> _captureHtml(dynamic controllerOrWebview) async {
    final ready = await _js(controllerOrWebview, "document.readyState") ?? '';
    if (ready != 'complete') return null;
    // Settle delay so late XHR content lands in the DOM.
    await Future.delayed(const Duration(milliseconds: 2000));
    final html =
        await _js(controllerOrWebview, "document.documentElement.outerHTML");
    return html;
  }

  /// Evaluates JS and decodes the result, handling JSON-encoded bridges.
  static Future<String?> _js(dynamic view, String script) async {
    try {
      final result = await view.evaluateJavaScript(script);
      if (result == null) return null;
      var s = result.toString();
      if (s == 'null') return null;
      // WebKit and inappwebview bridges may return strings JSON-encoded.
      if (s.length >= 2 && s.startsWith('"') && s.endsWith('"')) {
        try {
          final decoded = json.decode(s);
          if (decoded is String) return decoded;
        } catch (_) {}
        return s.substring(1, s.length - 1);
      }
      return s;
    } catch (_) {
      return null;
    }
  }
}

/// A cleared invisible webview kept alive per host so later pages on the
/// same site can be fetched through the same browser session.
class _SolvedSession {
  _SolvedSession(this.host, this.webview, this.controller);

  final String host;
  final HeadlessInAppWebView webview;
  final InAppWebViewController controller;
  bool busy = false;

  Future<void> dispose() async {
    try {
      await webview.dispose();
    } catch (_) {}
  }
}
