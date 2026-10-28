// Full-screen fallback page shown when the automatic headless challenge
// solver could not clear DDoS-Guard on its own (e.g. a real human CAPTCHA).
// The page loads the blocked URL in a visible InAppWebView, waits until the
// challenge is gone and the page has fully rendered, stores the captured HTML
// in ChallengeHtmlCache (keyed by request URL) and pops itself. The caller then
// simply retries - the cached HTML is used instead of a doomed Dio request.

// Flutter imports:
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:openlib/l10n/app_localizations.dart';

// Package imports:
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// Project imports:
import 'package:openlib/data/services/challenge_html_cache.dart';
import 'package:openlib/data/services/logger.dart';
import 'package:openlib/data/services/webview_challenge_solver.dart';

class ChallengeSolverPage extends StatefulWidget {
  const ChallengeSolverPage({super.key, required this.url});

  final String url;

  @override
  State<ChallengeSolverPage> createState() => _ChallengeSolverPageState();
}

class _ChallengeSolverPageState extends State<ChallengeSolverPage> {
  final AppLogger _logger = AppLogger();
  InAppWebViewController? _controller;
  Timer? _pollTimer;
  Timer? _introTimer;
  bool _done = false;
  bool _showIntro = true;
  DateTime _introStartedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startIntroTimer();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _introTimer?.cancel();
    super.dispose();
  }

  void _startIntroTimer() {
    _introStartedAt = DateTime.now();
    _introTimer?.cancel();
    // If the page never reports onLoadStop (blocked navigation, slow
    // network), still reveal the page so the user can interact or retry.
    _introTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showIntro = false);
    });
  }

  Future<void> _hideIntroAfterLoad() async {
    final elapsed = DateTime.now().difference(_introStartedAt);
    final remaining = const Duration(milliseconds: 700) - elapsed;
    if (remaining > Duration.zero) await Future.delayed(remaining);
    if (!mounted) return;
    setState(() => _showIntro = false);
  }

  void _reload() {
    if (!mounted) return;
    setState(() => _showIntro = true);
    _startIntroTimer();
    _controller?.reload();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (_done || !mounted) return;
      final controller = _controller;
      if (controller == null) return;

      try {
        final title = (await controller.getTitle()) ?? '';
        final bodySnippet = (await controller.evaluateJavascript(
                    source:
                        "document.body ? document.body.innerHTML.slice(0, 3000) : ''"))
                ?.toString() ??
            '';

        if (title.isEmpty && bodySnippet.isEmpty) return;

        if (WebviewChallengeSolver.isChallengePage(
            title: title, bodySnippet: bodySnippet)) {
          _logger.debug('Challenge still active (solver page)',
              tag: 'ChallengeSolver', metadata: {'title': title});
          return;
        }

        final ready =
            (await controller.evaluateJavascript(source: "document.readyState"))
                    ?.toString() ??
                '';
        if (ready != 'complete') return;

        // Settle so late XHR content lands in the DOM.
        await Future.delayed(const Duration(milliseconds: 2000));
        if (_done || !mounted) return;

        final html = (await controller.evaluateJavascript(
                    source: "document.documentElement.outerHTML"))
                ?.toString() ??
            '';
        if (html.isNotEmpty) {
          _done = true;
          ChallengeHtmlCache.store(widget.url, html);
          _logger.info('Solver page captured HTML',
              tag: 'ChallengeSolver',
              metadata: {'url': widget.url, 'length': html.length});
          _pollTimer?.cancel();
          if (mounted) Navigator.pop(context, true);
        }
      } catch (_) {
        // webview might be mid-navigation; keep polling
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.verifyingAccess),
        actions: [
          IconButton(
            onPressed: _reload,
            tooltip: l10n.retry,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                if (!_showIntro) _buildStatusBanner(context, l10n, scheme),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                        child: InAppWebView(
                          initialUrlRequest:
                              URLRequest(url: WebUri(widget.url)),
                          initialSettings: InAppWebViewSettings(
                            javaScriptEnabled: true,
                            supportZoom: false,
                          ),
                          onWebViewCreated: (controller) {
                            _controller = controller;
                            _startPolling();
                          },
                          onLoadStop: (_, __) => _hideIntroAfterLoad(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchOutCurve: Curves.easeIn,
                child: _showIntro
                    ? const _VerificationIntro(key: ValueKey('intro'))
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(
      BuildContext context, AppLocalizations l10n, ColorScheme scheme) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(Icons.shield_outlined,
                    size: 19, color: scheme.onPrimaryContainer),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.manualVerificationRequired,
                        style: theme.textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(l10n.verificationPageInstructions,
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 4,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationIntro extends StatelessWidget {
  const _VerificationIntro({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  size: 44,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.verifyingAccess,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.verificationPageLoading,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(height: 1.6),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: 180,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
