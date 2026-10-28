// Unit tests for the challenge HTML cache and the challenge-page and
// loadStop-race heuristics of the webview solver. No real webview is
// opened: guiEnabled stays off and the visible fallback is a fake.

// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Dart imports:
import 'dart:async';

// Project imports:
import 'package:openlib/data/services/challenge_html_cache.dart';
import 'package:openlib/data/services/webview_challenge_solver.dart';

void main() {
  setUp(WebviewChallengeSolver.clearAutoSolveFailures);
  tearDown(WebviewChallengeSolver.clearAutoSolveFailures);

  group('ChallengeHtmlCache', () {
    setUp(() {
      ChallengeHtmlCache.clear();
    });

    test('stores and retrieves HTML by URL', () {
      ChallengeHtmlCache.store(
          'https://annas-archive.pk/search?q=test', '<html>results</html>');

      expect(ChallengeHtmlCache.get('https://annas-archive.pk/search?q=test'),
          equals('<html>results</html>'));
      expect(ChallengeHtmlCache.has('https://annas-archive.pk/search?q=test'),
          isTrue);
    });

    test('returns null for uncached URLs', () {
      ChallengeHtmlCache.store('https://annas-archive.pk/search?q=a', 'x');

      expect(ChallengeHtmlCache.get('https://annas-archive.pk/search?q=b'),
          isNull);
      expect(ChallengeHtmlCache.has('https://annas-archive.pk/search?q=b'),
          isFalse);
    });

    test('rejects empty keys and values', () {
      ChallengeHtmlCache.store('', '<html></html>');
      ChallengeHtmlCache.store('https://a', '');

      expect(ChallengeHtmlCache.get(''), isNull);
      expect(ChallengeHtmlCache.get('https://a'), isNull);
    });

    test('overwrites previous entries for the same URL', () {
      ChallengeHtmlCache.store('https://a', 'first');
      ChallengeHtmlCache.store('https://a', 'second');

      expect(ChallengeHtmlCache.get('https://a'), equals('second'));
    });

    test('clear removes all entries', () {
      ChallengeHtmlCache.store('https://a', 'x');
      ChallengeHtmlCache.clear();

      expect(ChallengeHtmlCache.has('https://a'), isFalse);
    });
  });

  group('automatic solve failure cache', () {
    setUp(WebviewChallengeSolver.clearAutoSolveFailures);
    tearDown(WebviewChallengeSolver.clearAutoSolveFailures);

    test('remembers a failure per host and exposes it for the banner', () {
      const url = 'https://annas-archive.pk/search?q=docker';
      expect(WebviewChallengeSolver.autoSolveRecentlyFailed(url), isFalse);

      WebviewChallengeSolver.debugRememberAutoSolveFailure(url);

      expect(WebviewChallengeSolver.autoSolveRecentlyFailed(url), isTrue);
      expect(
        WebviewChallengeSolver.autoSolveRecentlyFailed(
            'https://annas-archive.pk/search?q=other'),
        isTrue,
        reason: 'the whole host is marked, not just one query',
      );
      expect(WebviewChallengeSolver.failedChallenges.value, contains(url));
      expect(
        WebviewChallengeSolver.autoSolveRecentlyFailed(
            'https://z-lib.gd/search?q=x'),
        isFalse,
      );
    });

    test('a successful manual solve clears the failure and the banner', () async {
      const url = 'https://annas-archive.pk/search?q=manual';
      WebviewChallengeSolver.debugRememberAutoSolveFailure(url);
      WebviewChallengeSolver.visibleSolverFallback =
          (_) async => '<html>solved</html>';
      addTearDown(() => WebviewChallengeSolver.visibleSolverFallback = null);

      await WebviewChallengeSolver.requestVisibleSolve(url);

      expect(WebviewChallengeSolver.autoSolveRecentlyFailed(url), isFalse);
      expect(WebviewChallengeSolver.failedChallenges.value, isEmpty);
    });
  });

  group('WebviewChallengeSolver.isChallengePage', () {
    test('detects DDoS-Guard challenge by title', () {
      expect(
          WebviewChallengeSolver.isChallengePage(
              title: 'DDoS-Guard', bodySnippet: ''),
          isTrue);
    });

    test('detects DDoS-Guard challenge by body markers', () {
      expect(
          WebviewChallengeSolver.isChallengePage(
              title: '',
              bodySnippet: '<script src="https://check.ddos-guard.net/x">'),
          isTrue);
    });

    test('detects Cloudflare challenge', () {
      expect(
          WebviewChallengeSolver.isChallengePage(
              title: 'Just a moment...', bodySnippet: 'cf-turnstile'),
          isTrue);
    });

    test('detects a localized Cloudflare challenge title', () {
      for (final title in [
        '请稍候…',
        'Einen Moment…',
        'Un instant…',
        'Un momento…',
      ]) {
        expect(
            WebviewChallengeSolver.isChallengePage(
                title: title, bodySnippet: ''),
            isTrue,
            reason: title);
      }
    });

    test('does not flag real search results', () {
      expect(
          WebviewChallengeSolver.isChallengePage(
              title: 'harry potter - Search - Anna’s Archive',
              bodySnippet: '<div class="js-aarecord-list-outer">books</div>'),
          isFalse);
    });

    test('does not flag a book detail page', () {
      expect(
          WebviewChallengeSolver.isChallengePage(
              title: 'Villa Coco: A Novel - Anna’s Archive',
              bodySnippet: '<div class="main-inner">book details</div>'),
          isFalse);
    });
  });

  // Regression from an Android field log: the challenge had been
  // cleared (title = real page) but the page was not done loading, so
  // onLoadStop completed the solve with null and killed the poll loop.
  // A loadStop may only complete with real captured HTML in hand.
  group('loadStop race regression', () {
    test('real title but empty HTML must not complete', () {
      expect(
          WebviewChallengeSolver.shouldCompleteFromLoadStop(
              'harry potter - Search - Anna’s Archive', null),
          isFalse);
      expect(
          WebviewChallengeSolver.shouldCompleteFromLoadStop(
              'harry potter - Search - Anna’s Archive', ''),
          isFalse);
    });

    test('challenge title with HTML must not complete', () {
      expect(
          WebviewChallengeSolver.shouldCompleteFromLoadStop(
              'DDoS-Guard', '<html>challenge page</html>'),
          isFalse);
    });

    test('real title with captured HTML completes', () {
      expect(
          WebviewChallengeSolver.shouldCompleteFromLoadStop(
              'harry potter - Search - Anna’s Archive',
              '<html>real results</html>'),
          isTrue);
    });
  });

  // A failed headless mobile solve must consult the registered
  // visible-solver hook and cache its result.
  group('visible solver fallback', () {
    test('used and cached when the headless solve returns nothing', () async {
      ChallengeHtmlCache.clear();
      var askedFor = '';
      WebviewChallengeSolver.guiEnabled = false; // no real webview
      WebviewChallengeSolver.overrideIsMobile = true;
      WebviewChallengeSolver.visibleSolverFallback = (url) async {
        askedFor = url;
        return '<html>solved visibly</html>';
      };
      addTearDown(() {
        WebviewChallengeSolver.guiEnabled = true;
        WebviewChallengeSolver.overrideIsMobile = null;
        WebviewChallengeSolver.visibleSolverFallback = null;
      });

      const url = 'https://annas-archive.gl/search?q=race';
      final html = await WebviewChallengeSolver.fetchHtmlAfterChallenge(url);

      expect(askedFor, url);
      expect(html, '<html>solved visibly</html>');
      expect(ChallengeHtmlCache.get(url), '<html>solved visibly</html>');
    });

    test('returns null without caching when the user backs out', () async {
      WebviewChallengeSolver.guiEnabled = false;
      WebviewChallengeSolver.overrideIsMobile = true;
      WebviewChallengeSolver.visibleSolverFallback = (url) async => null;
      addTearDown(() {
        WebviewChallengeSolver.guiEnabled = true;
        WebviewChallengeSolver.overrideIsMobile = null;
        WebviewChallengeSolver.visibleSolverFallback = null;
      });

      final result = await WebviewChallengeSolver.fetchHtmlAfterChallenge(
          'https://annas-archive.pk/backout');

      expect(result, isNull);
      expect(
          ChallengeHtmlCache.get('https://annas-archive.pk/backout'), isNull);
    });

    test('desktop solve does not consult the fallback', () async {
      var fallbackCalls = 0;
      WebviewChallengeSolver.guiEnabled = false;
      WebviewChallengeSolver.overrideIsMobile = false;
      WebviewChallengeSolver.visibleSolverFallback = (url) async {
        fallbackCalls++;
        return '<html>should-not-happen</html>';
      };
      addTearDown(() {
        WebviewChallengeSolver.guiEnabled = true;
        WebviewChallengeSolver.overrideIsMobile = null;
        WebviewChallengeSolver.visibleSolverFallback = null;
      });

      final result = await WebviewChallengeSolver.fetchHtmlAfterChallenge(
          'https://annas-archive.pk/slow');

      expect(result, isNull);
      expect(fallbackCalls, 0);
    });

    // The settings toggle: background verification off means no headless
    // attempt at all - the visible window runs straight away.
    test('headless disabled skips the headless attempt and goes visible',
        () async {
      var fallbackCalls = 0;
      WebviewChallengeSolver.guiEnabled = false;
      WebviewChallengeSolver.headlessEnabled = false;
      WebviewChallengeSolver.overrideIsMobile = true;
      WebviewChallengeSolver.visibleSolverFallback = (url) async {
        fallbackCalls++;
        return '<html>visible</html>';
      };
      addTearDown(() {
        WebviewChallengeSolver.guiEnabled = true;
        WebviewChallengeSolver.headlessEnabled = true;
        WebviewChallengeSolver.overrideIsMobile = null;
        WebviewChallengeSolver.visibleSolverFallback = null;
      });

      final result = await WebviewChallengeSolver.fetchHtmlAfterChallenge(
          'https://annas-archive.pk/toggle');

      expect(fallbackCalls, 1);
      expect(result, '<html>visible</html>');
    });
  });

  test('without a cleared session there is nothing to reuse', () async {
    await WebviewChallengeSolver.clearSessions();
    addTearDown(WebviewChallengeSolver.clearSessions);

    expect(WebviewChallengeSolver.sessionCount, 0);
    expect(
      await WebviewChallengeSolver.fetchWithSession(
          'https://welib.org/search?q=docker'),
      isNull,
    );
  });

  group('verification entry points', () {
    test('a host that failed headless stops trying it on mobile', () {
      WebviewChallengeSolver.guiEnabled = true;
      WebviewChallengeSolver.overrideIsMobile = true;
      WebviewChallengeSolver.clearHeadlessFailures();
      addTearDown(() {
        WebviewChallengeSolver.guiEnabled = true;
        WebviewChallengeSolver.overrideIsMobile = null;
        WebviewChallengeSolver.clearHeadlessFailures();
        WebviewChallengeSolver.clearPendingChallenges();
      });

      const url = 'https://welib.org/search?q=docker';
      expect(WebviewChallengeSolver.shouldTryHeadless(url), isTrue);

      WebviewChallengeSolver.debugRememberHeadlessFailure(url);

      expect(WebviewChallengeSolver.shouldTryHeadless(url), isFalse);
      expect(
        WebviewChallengeSolver.shouldTryHeadless('https://welib.org/md5/abc'),
        isFalse,
        reason: 'the failure is remembered per host',
      );
      expect(
        WebviewChallengeSolver.shouldTryHeadless('https://annas-archive.gl/x'),
        isTrue,
      );
    });

    test('the requested visible solve caches its HTML and runs once',
        () async {
      ChallengeHtmlCache.clear();
      var calls = 0;
      final started = Completer<void>();
      final release = Completer<void>();
      WebviewChallengeSolver.visibleSolverFallback = (url) async {
        calls++;
        if (!started.isCompleted) started.complete();
        await release.future;
        return '<html>solved by the user</html>';
      };
      addTearDown(() {
        WebviewChallengeSolver.visibleSolverFallback = null;
        WebviewChallengeSolver.clearPendingChallenges();
      });

      const url = 'https://welib.org/search?q=manual';
      WebviewChallengeSolver.pendingChallenges.value = [url];

      final first = WebviewChallengeSolver.requestVisibleSolve(url);
      await started.future;
      // A second tap while the page is open must not push it twice.
      await WebviewChallengeSolver.requestVisibleSolve(url);
      release.complete();
      await first;

      expect(calls, 1);
      expect(ChallengeHtmlCache.get(url), '<html>solved by the user</html>');
      expect(WebviewChallengeSolver.pendingChallenges.value, isEmpty);
    });
  });
}
