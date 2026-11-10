import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/dev/play_popup_preview.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('the key opens the pop-up over Acasă, and its X closes it', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: const PlayPopupPreview()));
    await tester.pump();
    expect(find.text('Următorul tău joc'), findsNothing);

    await tester.tap(find.text('Joacă'));
    await _settle(tester);
    expect(find.text('Următorul tău joc'), findsOneWidget);
    expect(find.text('Acasă'), findsWidgets, reason: 'the page underneath is still Acasă');
    expect(find.byIcon(TablerIcons.x), findsOneWidget);

    await tester.tap(find.text('Joacă'));
    await _settle(tester);
    expect(find.text('Următorul tău joc'), findsNothing);
    expect(find.byIcon(TablerIcons.key), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('another tab closes the pop-up', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: const PlayPopupPreview()));
    await tester.pump();
    await tester.tap(find.text('Joacă'));
    await _settle(tester);
    await tester.tap(find.text('Profil'));
    await _settle(tester);
    expect(find.text('Următorul tău joc'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
