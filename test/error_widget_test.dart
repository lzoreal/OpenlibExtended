// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/ui/components/error_widget.dart';

Widget _app(Widget child) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

Future<void> _pumpError(
  WidgetTester tester, {
  required Object error,
  String? contextLabel,
  String? contextDetails,
  VoidCallback? onRefresh,
}) async {
  await tester.pumpWidget(_app(CustomErrorWidget(
    error: error,
    stackTrace: StackTrace.current,
    contextLabel: contextLabel,
    contextDetails: contextDetails,
    onRefresh: onRefresh,
  )));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/package_info'),
      (call) async {
        if (call.method == 'getAll') {
          return <String, dynamic>{
            'appName': 'OpenlibExtended',
            'packageName': 'org.openlib',
            'version': '1.7.2',
            'buildNumber': '1',
          };
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/package_info'),
      null,
    );
  });

  testWidgets('unknown errors expose diagnostics without a restart hint',
      (tester) async {
    await _pumpError(
      tester,
      error: Exception('boom'),
      contextLabel: 'Search results',
      contextDetails: 'query=three body',
    );

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.textContaining('restart', findRichText: true), findsNothing);
    expect(find.text('Diagnostics'), findsOneWidget);
  });

  testWidgets('diagnostics dialog shows location, error type and stack',
      (tester) async {
    await _pumpError(
      tester,
      error: Exception('boom'),
      contextLabel: 'Search results',
      contextDetails: 'query=three body',
    );

    await tester.tap(find.text('Diagnostics'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Location: Search results'), findsOneWidget);
    expect(find.textContaining('query=three body'), findsWidgets);
    expect(find.textContaining('Exception: boom'), findsWidgets);
    expect(find.text('Stack trace'), findsOneWidget);
    expect(find.text('Environment'), findsOneWidget);
    expect(find.text('Copy diagnostics'), findsOneWidget);
    expect(find.text('Export Logs'), findsOneWidget);
  });

  testWidgets('copying diagnostics includes context, exception and stack',
      (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied = (call.arguments as Map)['text'] as String?;
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    await _pumpError(
      tester,
      error: Exception('boom'),
      contextLabel: 'Search results',
      contextDetails: 'query=three body',
    );

    await tester.tap(find.text('Diagnostics'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy diagnostics'));
    await tester.pump();

    expect(copied, isNotNull);
    expect(copied, contains('Search results'));
    expect(copied, contains('query=three body'));
    expect(copied, contains('Exception: boom'));
    expect(copied, contains('Stack trace'));
  });

  testWidgets('parse and storage failures get their own titles',
      (tester) async {
    await _pumpError(
        tester, error: const FormatException('Unexpected end of input'));
    expect(find.text('Could not read the book source data'), findsOneWidget);

    await _pumpError(
        tester, error: const FileSystemException('Cannot write file'));
    expect(find.text('Local storage operation failed'), findsOneWidget);
  });

  testWidgets('retry button calls onRefresh', (tester) async {
    var refreshes = 0;
    await _pumpError(
      tester,
      error: Exception('boom'),
      onRefresh: () => refreshes++,
    );

    await tester.tap(find.text('Try Again'));
    expect(refreshes, 1);
  });
}
