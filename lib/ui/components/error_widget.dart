// User-friendly error display widget with solutions
// Handles network errors, Cloudflare blocks, connectivity issues

// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openlib/l10n/app_localizations.dart';

// Package imports:
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:openlib/services/network_error.dart';
import 'package:openlib/services/logger.dart';
import 'package:openlib/services/platform_utils.dart';
import 'package:openlib/ui/challenge_solver_page.dart';

String _networkErrorTitle(AppLocalizations l10n, NetworkError error) {
  return switch (error.kind) {
    NetworkErrorKind.bookNotFound => l10n.networkErrorBookNotFoundTitle,
    NetworkErrorKind.bookDetailsUnavailable =>
      l10n.networkErrorBookDetailsUnavailableTitle,
    NetworkErrorKind.parseFailure => l10n.networkErrorParseTitle,
    NetworkErrorKind.storageFailure => l10n.networkErrorStorageTitle,
    NetworkErrorKind.generic => switch (error.type) {
        NetworkErrorType.noInternet => l10n.networkErrorNoInternetTitle,
        NetworkErrorType.cloudflareBlock => l10n.networkErrorCloudflareTitle,
        NetworkErrorType.serverUnavailable =>
          l10n.networkErrorServerUnavailableTitle,
        NetworkErrorType.timeout => l10n.networkErrorTimeoutTitle,
        NetworkErrorType.forbidden => l10n.networkErrorForbiddenTitle,
        NetworkErrorType.rateLimited => l10n.networkErrorRateLimitedTitle,
        NetworkErrorType.sslError => l10n.networkErrorSslTitle,
        NetworkErrorType.dnsError => l10n.networkErrorDnsTitle,
        NetworkErrorType.unknown => l10n.networkErrorUnknownTitle,
      },
  };
}

String _networkErrorSolution(AppLocalizations l10n, NetworkError error) {
  return switch (error.kind) {
    NetworkErrorKind.bookNotFound => l10n.networkErrorBookNotFoundSolution,
    NetworkErrorKind.bookDetailsUnavailable =>
      l10n.networkErrorBookDetailsUnavailableSolution,
    NetworkErrorKind.parseFailure => l10n.networkErrorParseSolution,
    NetworkErrorKind.storageFailure => l10n.networkErrorStorageSolution,
    NetworkErrorKind.generic => switch (error.type) {
        NetworkErrorType.noInternet => l10n.networkErrorNoInternetSolution,
        NetworkErrorType.cloudflareBlock => l10n.networkErrorCloudflareSolution,
        NetworkErrorType.serverUnavailable =>
          l10n.networkErrorServerUnavailableSolution,
        NetworkErrorType.timeout => l10n.networkErrorTimeoutSolution,
        NetworkErrorType.forbidden => l10n.networkErrorForbiddenSolution,
        NetworkErrorType.rateLimited => l10n.networkErrorRateLimitedSolution,
        NetworkErrorType.sslError => l10n.networkErrorSslSolution,
        NetworkErrorType.dnsError => l10n.networkErrorDnsSolution,
        NetworkErrorType.unknown => l10n.networkErrorUnknownSolution,
      },
  };
}

class CustomErrorWidget extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;
  final VoidCallback? onRefresh;

  /// Page or action where the failure happened, shown in diagnostics.
  final String? contextLabel;

  /// Technical context such as the search query or failing URL.
  final String? contextDetails;

  CustomErrorWidget({
    super.key,
    required this.error,
    required this.stackTrace,
    this.onRefresh,
    this.contextLabel,
    this.contextDetails,
  }) {
    // Log the error for debugging
    final logger = AppLogger();
    logger.error(
      "Error displayed to user",
      tag: "ErrorWidget",
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Convert error to NetworkError for unified handling
    final networkError = _parseError(error);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            _buildErrorIcon(context, networkError.type),
            const SizedBox(height: 24),
            _buildErrorTitle(context, networkError),
            const SizedBox(height: 16),
            _buildSolutionCard(context, networkError),
            const SizedBox(height: 24),
            if (onRefresh != null) _buildRefreshButton(context),
            const SizedBox(height: 8),
            _buildDiagnosticsButton(context),
            if (networkError.type == NetworkErrorType.cloudflareBlock)
              _buildOpenBrowserButton(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Parse any error into a NetworkError
  NetworkError _parseError(Object error) {
    if (error is NetworkError) {
      return error;
    }

    // Check for legacy socket exception marker
    if (error.toString().contains("socketException")) {
      return NetworkError(
        type: NetworkErrorType.noInternet,
        userMessage: "Unable to access the internet",
        solution:
            "Check your internet connection. Make sure WiFi or mobile data is enabled.",
      );
    }

    // Convert to NetworkError
    return NetworkError.fromException(error);
  }

  // Build appropriate icon based on error type
  Widget _buildErrorIcon(BuildContext context, NetworkErrorType type) {
    String assetPath;
    Color? iconColor;

    switch (type) {
      case NetworkErrorType.noInternet:
      case NetworkErrorType.dnsError:
        assetPath = "assets/no_internet.svg";
        break;
      case NetworkErrorType.cloudflareBlock:
      case NetworkErrorType.forbidden:
        assetPath = "assets/error_fixing_bugs.svg";
        iconColor = Theme.of(context).colorScheme.tertiary;
        break;
      case NetworkErrorType.timeout:
      case NetworkErrorType.serverUnavailable:
        assetPath = "assets/error_fixing_bugs.svg";
        break;
      default:
        assetPath = "assets/error_fixing_bugs.svg";
    }

    return Center(
      child: SvgPicture.asset(
        assetPath,
        width: 180,
        height: 180,
        colorFilter: iconColor != null
            ? ColorFilter.mode(iconColor, BlendMode.srcIn)
            : null,
      ),
    );
  }

  // Build error title with icon indicator
  Widget _buildErrorTitle(BuildContext context, NetworkError networkError) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    IconData iconData;
    Color iconColor;

    switch (networkError.type) {
      case NetworkErrorType.noInternet:
        iconData = Icons.wifi_off_rounded;
        iconColor = scheme.error;
        break;
      case NetworkErrorType.cloudflareBlock:
        iconData = Icons.shield_rounded;
        iconColor = scheme.tertiary;
        break;
      case NetworkErrorType.forbidden:
        iconData = Icons.block_rounded;
        iconColor = scheme.error;
        break;
      case NetworkErrorType.timeout:
        iconData = Icons.timer_off_rounded;
        iconColor = scheme.tertiary;
        break;
      case NetworkErrorType.serverUnavailable:
        iconData = Icons.cloud_off_rounded;
        iconColor = scheme.onSurfaceVariant;
        break;
      case NetworkErrorType.rateLimited:
        iconData = Icons.speed_rounded;
        iconColor = scheme.tertiary;
        break;
      case NetworkErrorType.dnsError:
        iconData = Icons.dns_rounded;
        iconColor = scheme.secondary;
        break;
      case NetworkErrorType.sslError:
        iconData = Icons.lock_open_rounded;
        iconColor = scheme.error;
        break;
      default:
        iconData = Icons.error_outline_rounded;
        iconColor = scheme.error;
    }

    return Column(
      children: [
        Icon(iconData, size: 48, color: iconColor),
        const SizedBox(height: 12),
        Text(
          _networkErrorTitle(l10n, networkError),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }

  // Build solution card with actionable advice
  Widget _buildSolutionCard(BuildContext context, NetworkError networkError) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Card(
      color: scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: scheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.errorWhatToDo,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _networkErrorSolution(l10n, networkError),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
            ),
            // Challenge solving failed invisibly on this device: point at
            // the background-verification toggle in settings.
            if (networkError.type == NetworkErrorType.cloudflareBlock) ...[
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context).backgroundVerificationFix,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.tertiary,
                ),
              ),
            ],
            // Show VPN recommendation prominently for blocked content
            if (networkError.type == NetworkErrorType.cloudflareBlock ||
                networkError.type == NetworkErrorType.dnsError ||
                networkError.type == NetworkErrorType.forbidden) ...[
              const SizedBox(height: 16),
              _buildVpnRecommendation(context),
            ],
          ],
        ),
      ),
    );
  }

  // Build VPN recommendation banner
  Widget _buildVpnRecommendation(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.vpn_key_rounded, color: scheme.onSecondaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).tryUsingVpn,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context).errorVpnDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build refresh button
  Widget _buildRefreshButton(BuildContext context) {
    return Center(
      child: FilledButton.icon(
        onPressed: onRefresh,
        icon: const Icon(Icons.refresh_rounded),
        label: Text(AppLocalizations.of(context).tryAgain),
      ),
    );
  }

  Widget _buildDiagnosticsButton(BuildContext context) {
    return Center(
      child: TextButton.icon(
        key: const ValueKey('error-diagnostics'),
        onPressed: () => _showDiagnostics(context),
        icon: const Icon(Icons.info_outline_rounded, size: 18),
        label: Text(AppLocalizations.of(context).errorDiagnostics),
      ),
    );
  }

  // Build open in browser button for DDoS/Captcha challenges
  Widget _buildOpenBrowserButton(BuildContext context) {
    return Center(
      child: FilledButton.tonalIcon(
        onPressed: () => _openInBrowser(context),
        icon: const Icon(Icons.open_in_browser_rounded),
        label: Text(AppLocalizations.of(context).verifyInBrowser),
      ),
    );
  }

  // Open browser to allow user to manually solve captcha/verification
  void _openInBrowser(BuildContext context) {
    final networkError = _parseError(error);
    final targetUrl = networkError.blockedUrl;
    final l10n = AppLocalizations.of(context);

    // Show dialog with embedded and system browser options
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.security_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(l10n.manualVerificationRequired),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.errorVerificationPrompt,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_rounded,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.errorVerificationReturn,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          if (targetUrl != null)
            OutlinedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                final uri = Uri.parse(targetUrl);
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              icon: const Icon(Icons.language),
              label: Text(AppLocalizations.of(context).systemBrowser),
            ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Trigger webview for verification
              _triggerBrowserVerification(context);
            },
            icon: const Icon(Icons.open_in_browser),
            label: Text(AppLocalizations.of(context).embeddedBrowser),
          ),
        ],
      ),
    );
  }

  // Trigger browser verification. On mobile the in-app solver page loads the
  // blocked URL, waits for the challenge to clear and captures the rendered
  // HTML. On desktop the in-app webview plugin is unavailable, so the system
  // browser is the only manual fallback.
  void _triggerBrowserVerification(BuildContext context) {
    final networkError = _parseError(error);
    final targetUrl = networkError.blockedUrl;

    if (targetUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).unableToOpenVerification),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (PlatformUtils.isMobile) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChallengeSolverPage(url: targetUrl),
        ),
      ).then((solved) {
        if (solved == true && onRefresh != null && context.mounted) {
          onRefresh!();
        }
      });
    } else {
      launchUrl(Uri.parse(targetUrl), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _showDiagnostics(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final networkError = _parseError(error);
    final location = contextLabel == null
        ? null
        : '${l10n.errorLocation(contextLabel!)}'
            '${contextDetails == null ? '' : ' · $contextDetails'}';
    final details = networkError.technicalDetails ?? networkError.userMessage;
    final stack = _formatStackTrace(stackTrace);
    final environment = await _diagnosticsEnvironment();
    final rawBody = networkError.rawResponseBody;

    final report = StringBuffer()
      ..writeln('OpenlibExtended diagnostics')
      ..writeln(environment);
    if (location != null) report.writeln(location);
    report
      ..writeln(l10n.errorLabel(details))
      ..writeln('${l10n.errorStackTrace}:')
      ..writeln(stack.isEmpty ? '-' : stack);
    if (rawBody != null) {
      report
        ..writeln('${l10n.blockedPageContent}:')
        ..writeln(_formatResponseBody(rawBody));
    }
    final reportText = report.toString();

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: Row(
          children: [
            const Icon(Icons.troubleshoot_rounded, size: 24),
            const SizedBox(width: 8),
            Flexible(child: Text(l10n.errorDiagnostics)),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (location != null) ...[
              Text(
                location,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              l10n.errorLabel(details),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                height: 1.429,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.errorStackTrace,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stack.isEmpty ? '-' : stack,
              style: const TextStyle(
                fontFamily: "monospace",
                fontSize: 11,
                height: 1.455,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.errorEnvironment,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(environment, style: const TextStyle(fontSize: 12)),
            if (rawBody != null) ...[
              const SizedBox(height: 12),
              Text(
                l10n.blockedPageContent,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatResponseBody(rawBody),
                style: const TextStyle(
                  fontFamily: "monospace",
                  fontSize: 11,
                  height: 1.455,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _shareLogs(context, l10n),
            icon: const Icon(Icons.ios_share_rounded, size: 18),
            label: Text(l10n.exportLogs),
          ),
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: reportText));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.copiedToClipboard)),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: Text(l10n.errorCopyDiagnostics),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Future<String> _diagnosticsEnvironment() async {
    var version = 'unknown';
    try {
      final info = await PackageInfo.fromPlatform();
      final build = info.buildNumber.isEmpty ? '' : '+${info.buildNumber}';
      version = '${info.version}$build';
    } catch (_) {
      // PackageInfo is unavailable in tests and some unsupported hosts.
    }
    return 'App $version · ${Platform.operatingSystem} '
        '${Platform.operatingSystemVersion} · '
        '${DateTime.now().toIso8601String()}';
  }

  String _formatStackTrace(StackTrace stackTrace) {
    return stackTrace.toString().trim().split('\n').take(12).join('\n');
  }

  Future<void> _shareLogs(BuildContext context, AppLocalizations l10n) async {
    try {
      await AppLogger().exportLogs(
        saveDialogTitle: l10n.exportLogs,
        shareSubject: l10n.appLogsShareSubject,
        shareText:
            l10n.appLogsShareText(AppLogger.logRetentionDuration.inMinutes),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedExportLogs('$e'))),
        );
      }
    }
  }

  // Format response body for display
  String _formatResponseBody(String body) {
    // Limit length for display
    if (body.length > 3000) {
      return "${body.substring(0, 3000)}\n\n... (truncated, ${body.length} total characters)";
    }
    return body;
  }
}

// Simple error snackbar for quick inline errors
class ErrorSnackbar {
  static void show(BuildContext context, Object error,
      {VoidCallback? onRetry}) {
    final networkError =
        error is NetworkError ? error : NetworkError.fromException(error);
    final l10n = AppLocalizations.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _networkErrorTitle(l10n, networkError),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              _networkErrorSolution(l10n, networkError),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        action: onRetry != null
            ? SnackBarAction(
                label: l10n.retry,
                onPressed: onRetry,
              )
            : null,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
