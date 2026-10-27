import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/l10n/app_localizations.dart';
import 'package:openlib/ui/components/settings_row.dart';
import 'package:openlib/ui/themes.dart';

void main() {
  testWidgets('settings row is at least 64 high', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: SettingsRow(
          icon: Icons.language,
          title: '语言',
          subtitle: '界面文字，立即生效',
          trailing: Text('中文'),
        ),
      ),
    ));

    expect(
      tester.getSize(find.byType(SettingsRow)).height,
      greaterThanOrEqualTo(64),
    );
  });
}
