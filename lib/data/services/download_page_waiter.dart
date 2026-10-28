// Waits out a slow-download page without showing it.
//
// Anna's Archive and WeLib only hand over the file links after a short
// countdown (and WeLib may redirect to a sign-in first). Opening the page
// for every download made the user watch that countdown; this runs the
// same page in an invisible webview that shares the app's cookie jar,
// reports the seconds left to the detail button, and returns the links
// when they appear.

// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// Project imports:
import 'package:openlib/data/services/download_page_links.dart';
import 'package:openlib/data/services/logger.dart';
import 'package:openlib/data/services/platform_utils.dart';
import 'package:openlib/data/services/webview_challenge_solver.dart';

enum DownloadWaitOutcome {
  /// The page handed over one file link or a mirror list.
  links,

  /// The site sent the page to its sign-in form; the user has to log in.
  needsLogin,

  /// The page stayed gated or never produced a link.
  unavailable,
}

class DownloadWaitResult {
  const DownloadWaitResult.links(this.links)
      : outcome = DownloadWaitOutcome.links;
  const DownloadWaitResult.needsLogin()
      : outcome = DownloadWaitOutcome.needsLogin,
        links = const [];
  const DownloadWaitResult.unavailable()
      : outcome = DownloadWaitOutcome.unavailable,
        links = const [];

  final DownloadWaitOutcome outcome;
  final List<String> links;
}

/// Reads the first number out of the page's countdown element, e.g.
/// "12" or "12s"; anything outside a plausible range is ignored.
int? countdownSecondsFrom(String? text) {
  if (text == null) return null;
  final match = RegExp(r'\d+').firstMatch(text);
  if (match == null) return null;
  final value = int.tryParse(match.group(0)!);
  if (value == null || value < 0 || value > 300) return null;
  return value;
}

class DownloadPageWaiter {
  const DownloadPageWaiter();

  static final AppLogger _logger = AppLogger();

  /// WeLib counts down about 30 s; the rest is slack for the page load.
  static const Duration _timeout = Duration(seconds: 45);
  static const Duration _challengeGrace = Duration(seconds: 10);
  static const Duration _pollInterval = Duration(seconds: 1);

  static const String _stateJs = r'''
(function () {
  function links() {
    var out = [];
    var a = document.querySelector('a.js-partner-download-link[href]');
    if (a) out.push(a.href);
    if (!out.length) {
      var p = document.querySelector('p[class="mb-4 text-xl font-bold"]');
      var pa = p ? p.querySelector('a[href]') : null;
      if (pa) out.push(pa.href);
    }
    if (!out.length) {
      var box = document.querySelector('div.mb-4.text-xl.font-bold');
      var ba = box ? box.querySelector('a[href]') : null;
      if (ba) out.push(ba.href);
    }
    if (!out.length) {
      document.querySelectorAll('ul>li>a[href]').forEach(function (x) {
        if (x.href.indexOf('http') === 0) out.push(x.href);
      });
    }
    return out;
  }
  function countdown() {
    var selectors = [
      'span.js-partner-countdown',
      '[id*="countdown" i]',
      '[class*="countdown" i]'
    ];
    for (var i = 0; i < selectors.length; i++) {
      var el = document.querySelector(selectors[i]);
      if (el) {
        var text = (el.textContent || '').trim();
        if (text) return text;
      }
    }
    var body = document.body ? document.body.innerText : '';
    var m = (body || '').slice(0, 4000).match(/(\d+)\s*(?:s\b|sec|second|秒)/i);
    return m ? m[0] : '';
  }
  return JSON.stringify({ links: links(), countdown: countdown() });
})()
''';

  /// [onTick] receives the seconds left (null while the page is still
  /// loading or does not expose one). [shouldContinue] lets the caller
  /// abandon the wait when its page is gone.
  Future<DownloadWaitResult> wait(
    String pageUrl, {
    void Function(int? secondsLeft)? onTick,
    bool Function()? shouldContinue,
  }) async {
    if (!PlatformUtils.isMobile) return const DownloadWaitResult.unavailable();
    HeadlessInAppWebView? headless;
    InAppWebViewController? controller;
    DateTime? challengeSince;
    try {
      final holder = Completer<InAppWebViewController>();
      headless = HeadlessInAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(pageUrl)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          supportZoom: false,
          incognito: false,
          clearCache: false,
        ),
        onWebViewCreated: (created) {
          if (!holder.isCompleted) holder.complete(created);
        },
      );
      unawaited(headless.run());

      final deadline = DateTime.now().add(_timeout);
      while (DateTime.now().isBefore(deadline)) {
        if (shouldContinue?.call() == false) {
          return const DownloadWaitResult.unavailable();
        }
        controller ??= await _waitForController(holder);
        final active = controller;
        if (active != null) {
          final currentUrl = (await active.getUrl())?.toString() ?? pageUrl;
          if (isLoginUrl(currentUrl)) {
            _logger.info('Download page needs a sign-in',
                tag: 'PageWaiter', metadata: {'url': currentUrl});
            return const DownloadWaitResult.needsLogin();
          }
          final state = await _readState(active);
          if (state.links.isNotEmpty) {
            _logger.info('Download page handed over its links',
                tag: 'PageWaiter',
                metadata: {'url': pageUrl, 'count': state.links.length});
            return DownloadWaitResult.links(state.links);
          }
          final title = (await active.getTitle()) ?? '';
          if (WebviewChallengeSolver.isChallengePage(
              title: title, bodySnippet: '')) {
            challengeSince ??= DateTime.now();
            if (DateTime.now().difference(challengeSince) > _challengeGrace) {
              return const DownloadWaitResult.unavailable();
            }
          } else {
            challengeSince = null;
            onTick?.call(state.countdown);
          }
        }
        await Future.delayed(_pollInterval);
      }
      return const DownloadWaitResult.unavailable();
    } catch (e) {
      _logger.warning('Silent download wait failed',
          tag: 'PageWaiter', error: e);
      return const DownloadWaitResult.unavailable();
    } finally {
      try {
        await headless?.dispose();
      } catch (_) {}
    }
  }

  static Future<({List<String> links, int? countdown})> _readState(
      InAppWebViewController controller) async {
    try {
      final raw = await controller.evaluateJavascript(source: _stateJs);
      Map<String, dynamic>? map;
      if (raw is String) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) map = decoded;
      } else if (raw is Map) {
        map = raw.map((key, value) => MapEntry('$key', value));
      }
      if (map == null) return (links: const <String>[], countdown: null);
      final rawLinks = map['links'];
      final countdown = map['countdown'];
      return (
        links: rawLinks is List
            ? [
                for (final link in rawLinks)
                  if (link is String && link.startsWith('http')) link,
              ]
            : const <String>[],
        countdown: countdown is String ? countdownSecondsFrom(countdown) : null,
      );
    } catch (_) {
      return (links: const <String>[], countdown: null);
    }
  }

  static Future<InAppWebViewController?> _waitForController(
      Completer<InAppWebViewController> holder) async {
    if (holder.isCompleted) return await holder.future;
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (DateTime.now().isBefore(deadline)) {
      if (holder.isCompleted) return await holder.future;
      await Future.delayed(const Duration(milliseconds: 200));
    }
    return null;
  }
}
