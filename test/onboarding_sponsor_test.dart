// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Project imports:
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/ui/onboarding/onboarding_page.dart';

import 'helpers/fake_path_provider.dart';

final _paths = FakePathProvider('onboarding');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      PathProviderPlatform.instance = _paths;
      await Directory(_paths.base).create(recursive: true);
    }
  });

  testWidgets('sponsor button opens the fork maintainer sponsor page',
      (tester) async {
    const channel = MethodChannel('plugins.flutter.io/url_launcher');
    String? launchedUrl;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
        (call) async {
      if (call.method == 'launch') {
        launchedUrl = (call.arguments as Map)['url'] as String?;
      }
      return true;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));

    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const OnboardingPage(),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 200));

    // 0 welcome, 1 storage, 2 update, 3 donation, 4 sponsor.
    tester.widget<PageView>(find.byType(PageView)).controller!.jumpToPage(4);
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('Sponsor on GitHub'));
    await tester.pump();

    expect(launchedUrl, 'https://github.com/sponsors/lzoreal');
  });
}
