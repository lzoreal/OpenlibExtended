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
//   - Windows: desktop_webview_window is created hidden, so the challenge
//     passes off-screen; it only comes forward when the silent budget runs
//     out. Linux has no hide API in the plugin, so its window is visible.
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

  @visibleForTesting
  static Future<String?> Function(String url, Duration timeout)?
      debugHeadlessSolver;

  @visibleForTesting
  static Future<bool> Function(String url, Duration timeout)? debugSessionProbe;

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

  /// How long an invisible attempt may run before the challenge is treated
  /// as one that needs a human. Real auto-passes on this network cleared in
  /// about 14 s (challenge plus page load), so the budget has to cover that;
  /// an interactive Turnstile checkbox never clears and shows up as a page
  /// after this long.
  @visibleForTesting
  static Duration headlessManualAfter = const Duration(seconds: 20);

  /// Extra time for a capture that is still running after the budget: the
  /// challenge already cleared, the page is just slow to finish loading.
  static const Duration _captureGrace = Duration(seconds: 15);

  /// Hosts whose headless page last showed real content, so a budget expiry
  /// can tell "already cleared, still loading" from "needs a human".
  static final Map<String, DateTime> _lastContentAt = {};

  static void _markContent(String url) {
    _lastContentAt[Uri.tryParse(url)?.host ?? url] = DateTime.now();
  }

  static bool _clearedSince(String url, DateTime since) {
    final at = _lastContentAt[Uri.tryParse(url)?.host ?? url];
    return at != null && at.isAfter(since);
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
    _headlessFailures.remove(host);
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
        await adoptSession(url);
      }
    } finally {
      _visibleSolveInFlight.remove(url);
      _removePending(url);
    }
  }

  static final Set<String> _visibleSolveInFlight = {};

  /// Hosts where keeping an invisible session after a manual solve already
  /// failed: some devices cannot render a hidden webview, and repeating the
  /// probe only delays the next step.
  static const Duration _sessionProbeRetryAfter = Duration(minutes: 30);
  static const Duration _sessionProbeTimeout = Duration(seconds: 8);
  static final Map<String, DateTime> _sessionProbeFailures = {};

  @visibleForTesting
  static void clearSessionProbeFailures() => _sessionProbeFailures.clear();

  /// Keeps an invisible session for the host after a visible solve, so the
  /// next search/detail/download fetch reuses the clearance instead of
  /// prompting again. Runs even when [headlessEnabled] is off: it only loads
  /// a page the browser has already been let through, it does not solve.
  static Future<void> adoptSession(String url) async {
    if (!guiEnabled || !isSupported || !_isMobile) return;
    final host = Uri.tryParse(url)?.host;
    if (host == null || _sessions.containsKey(host)) return;
    final failedAt = _sessionProbeFailures[host];
    if (failedAt != null) {
      if (DateTime.now().difference(failedAt) < _sessionProbeRetryAfter) {
        return;
      }
      _sessionProbeFailures.remove(host);
    }
    _logger.debug('Adopting a hidden session after the visible solve',
        tag: 'ChallengeSolver', metadata: {'url': url});
    final probe = debugSessionProbe ?? _probeSession;
    final kept = await probe(url, _sessionProbeTimeout);
    if (!kept) {
      _sessionProbeFailures[host] = DateTime.now();
      _logger.info(
          'Hidden session probe failed; later steps will verify again',
          tag: 'ChallengeSolver',
          metadata: {'url': url});
    } else {
      _logger.info('Hidden session kept for later steps',
          tag: 'ChallengeSolver', metadata: {'host': host});
    }
  }

  /// Loads [url] in an invisible webview and keeps it as the host's session
  /// once the page is past the challenge. The page only has to be usable,
  /// not fully captured: waiting for a complete document here left hosts
  /// without a session and pushed the next step back to the visible page.
  static Future<bool> _probeSession(String url, Duration timeout) async {
    HeadlessInAppWebView? headless;
    InAppWebViewController? controller;
    var kept = false;
    try {
      final holder = Completer<InAppWebViewController>();
      headless = HeadlessInAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          supportZoom: false,
          incognito: false,
          clearCache: false,
        ),
        onWebViewCreated: (controller) {
          if (!holder.isCompleted) holder.complete(controller);
        },
      );
      unawaited(headless.run());
      final deadline = DateTime.now().add(timeout);
      while (DateTime.now().isBefore(deadline)) {
        controller ??= await _waitForController(holder);
        if (controller != null) {
          final title = (await controller.getTitle()) ?? '';
          if (title.isNotEmpty &&
              !isChallengePage(title: title, bodySnippet: '')) {
            _keepSession(url, headless, controller);
            kept = true;
            return true;
          }
        }
        await Future.delayed(const Duration(milliseconds: 500));
      }
      return false;
    } catch (e) {
      _logger.debug('Hidden session probe failed',
          tag: 'ChallengeSolver',
          metadata: {'url': url, 'error': e.toString()});
      return false;
    } finally {
      if (!kept) {
        try {
          await headless?.dispose();
        } catch (_) {}
      }
    }
  }

  /// Fetches [url] through the already-cleared browser session of its host,
  /// when one exists. This is what makes the second and later searches on
  /// a gated site skip verification entirely. Null when there is no
  /// session (or it is busy / the page is still gated), and callers then
  /// fall back to the normal HTTP path.
  static Future<String?> fetchWithSession(String url) async {
    final host = Uri.tryParse(url)?.host;
    if (host == null) return null;
    final session = _sessions[host];
    if (session == null || session.busy) {
      _logger.debug('No cleared session to reuse',
          tag: 'ChallengeSolver',
          metadata: {'host': host, 'busy': session?.busy});
      return null;
    }
    session.busy = true;
    var lastTitle = '';
    try {
      final controller = session.controller;
      await controller.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
      final deadline = DateTime.now().add(const Duration(seconds: 20));
      while (DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 700));
        try {
          final title = (await controller.getTitle()) ?? '';
          if (title.isNotEmpty) lastTitle = title;
          if (title.isNotEmpty &&
              !isChallengePage(title: title, bodySnippet: '')) {
            _logger.debug('Cleared session served the page',
                tag: 'ChallengeSolver', metadata: {'url': url});
            // The session only has to be usable: gate on the page title,
            // not on a complete document - WeLib keeps firing requests and
            // never settled to readyState=complete inside the deadline.
            await Future<void>.delayed(const Duration(milliseconds: 800));
            final html = await _js(
                controller, "document.documentElement.outerHTML");
            if (html == null || html.isEmpty) {
              _logger.debug('Cleared session page had no HTML yet',
                  tag: 'ChallengeSolver', metadata: {'url': url});
            } else {
              ChallengeHtmlCache.store(url, html);
              return html;
            }
          }
        } catch (_) {
          // Keep polling until the deadline.
        }
      }
      _logger.info('Cleared session could not load the page',
          tag: 'ChallengeSolver', metadata: {'url': url, 'title': lastTitle});
      return null;
    } catch (_) {
      return null;
    } finally {
      session.busy = false;
    }
  }

  static void _keepSession(String url, HeadlessInAppWebView webview,
      InAppWebViewController? controller) {
    final host = Uri.tryParse(url)?.host;
    if (host == null || controller == null) {
      _logger.debug('Not keeping the session: missing host or controller',
          tag: 'ChallengeSolver',
          metadata: {'url': url, 'hasController': controller != null});
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
    bool Function()? shouldContinue,
  }) async {
    if (!isSupported || shouldContinue?.call() == false) return null;
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
    final headlessSolver = debugHeadlessSolver ?? _solveHeadless;
    var headlessTimedOut = false;
    String? html;
    if (tryHeadless && _isMobile) {
      final startedAt = DateTime.now();
      final headless = headlessSolver(url, effectiveTimeout);
      try {
        // Stay invisible, but not for the whole timeout: a challenge that
        // is still up after the budget needs a human, not more waiting.
        html = await headless.timeout(headlessManualAfter);
      } on TimeoutException {
        if (_clearedSince(url, startedAt)) {
          // The challenge cleared; only the HTML capture is behind.
          try {
            html = await headless.timeout(_captureGrace);
          } on TimeoutException {
            headlessTimedOut = true;
          }
        } else {
          headlessTimedOut = true;
        }
        if (headlessTimedOut) {
          _logger.info('Silent solve still challenged; showing the page',
              tag: 'ChallengeSolver',
              metadata: {'url': url, 'budget': headlessManualAfter.inSeconds});
        }
      }
    } else if (tryHeadless) {
      // Two gated sources challenged at once used to open two windows on
      // the same WebView2 profile; the second one failed to initialise and
      // showed a blank page. Only one verification window at a time.
      html = await _oneDesktopWindowAtATime(
          () => _solveDesktopWindow(url, effectiveTimeout));
    }

    if (tryHeadless && !headlessTimedOut) {
      if (html == null && _isMobile) {
        _rememberHeadlessFailure(url);
      } else if (html != null) {
        _headlessFailures.remove(Uri.tryParse(url)?.host ?? url);
      }
    }

    if (shouldContinue?.call() == false) return null;

    if (html == null && _isMobile && visibleSolverFallback != null) {
      _logger.info('Headless solve failed, using visible fallback',
          tag: 'ChallengeSolver', metadata: {'url': url});
      html = await visibleSolverFallback!(url);
    }

    if (html != null) {
      ChallengeHtmlCache.store(url, html);
      _clearAutoSolveFailure(url);
      // A headless success already kept its session; after a manual solve
      // this is what stops the next step from prompting all over again.
      await adoptSession(url);
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
            _markContent(url);
            // Not ready yet (readyState != complete)? Just wait — the poll
            // loop picks the page up. Never complete with null here: that
            // used to kill the solve right after the challenge was cleared.
            final html = await _captureHtml(controller);
            _logger.debug('Headless load capture',
                tag: 'ChallengeSolver',
                metadata: {'title': title, 'length': html?.length ?? 0});
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
              _markContent(url);
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

  static Future<void> _desktopWindowGate = Future<void>.value();

  /// Runs [action] after every earlier desktop challenge window finished.
  /// WebView2 allows one environment per user-data folder and the plugin
  /// uses the same folder for every window.
  static Future<T> _oneDesktopWindowAtATime<T>(
      Future<T> Function() action) {
    final previous = _desktopWindowGate;
    final done = Completer<void>();
    _desktopWindowGate = done.future;
    return previous
        .then((_) => action())
        .whenComplete(() {
      if (!done.isCompleted) done.complete();
    });
  }

  static Future<String?> _solveDesktopWindow(
      String url, Duration timeout) async {
    desktop_webview.Webview? webview;
    var closedByUser = false;
    var solved = false;
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
      // The window is created visible: WebView2 stalled when the window was
      // hidden before its first navigation, which made every desktop
      // challenge fail without even showing the page.
      webview.launch(url, triggerOnUrlRequestEvent: false);

      final deadline = DateTime.now().add(timeout);
      var titleOkPolls = 0;
      var blankPolls = 0;
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

        if (title.isEmpty && bodySnippet.isEmpty) {
          blankPolls++;
          // The plugin can drop the first navigation (WebView2 not ready
          // yet); re-issue it a couple of times instead of showing
          // about:blank for the whole timeout.
          if (blankPolls == 3 || blankPolls == 6) {
            _logger.info('Challenge window blank, re-issuing the navigation',
                tag: 'ChallengeSolver',
                metadata: {'url': url, 'polls': blankPolls});
            try {
              webview.launch(url, triggerOnUrlRequestEvent: false);
            } catch (_) {}
          }
          // A window that is still blank after ~15s is not coming back;
          // close it (finally) so the next challenge can open cleanly.
          if (blankPolls >= 10) {
            _logger.warning('Challenge window stayed blank',
                tag: 'ChallengeSolver', metadata: {'url': url});
            return null;
          }
          continue;
        }
        blankPolls = 0;

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
          solved = true;
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
      // closes the window manually there. Windows can close, and leaving an
      // unsolved window behind keeps its WebView2 profile locked.
      if (!solved && PlatformUtils.isWindows) {
        try {
          webview?.close();
        } catch (_) {}
      }
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
    if (ready != 'complete') {
      _logger.debug('Page not ready for capture',
          tag: 'ChallengeSolver', metadata: {'readyState': ready});
      return null;
    }
    // Settle delay so late XHR content lands in the DOM.
    await Future.delayed(const Duration(milliseconds: 2000));
    final html =
        await _js(controllerOrWebview, "document.documentElement.outerHTML");
    return html;
  }

  /// Evaluates JS and decodes the result, handling JSON-encoded bridges.
  ///
  /// The mobile controller exposes `evaluateJavascript(source:)` while the
  /// desktop window keeps `evaluateJavaScript(String)`. Calling the wrong
  /// one threw inside the try and silently returned null, which made every
  /// headless solve "time out" even after the challenge had cleared.
  static Future<String?> _js(dynamic view, String script) async {
    try {
      final result = view is InAppWebViewController
          ? await view.evaluateJavascript(source: script)
          : await view.evaluateJavaScript(script);
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
