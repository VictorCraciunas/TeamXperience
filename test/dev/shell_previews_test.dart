import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/dev/events_tab_preview.dart';
import 'package:teamxperience/dev/play_tab_preview.dart';
import 'package:teamxperience/dev/shell_previews_launcher.dart';
import 'package:teamxperience/ui/ui.dart';

Future<void> _pump(WidgetTester tester, Widget home, ThemeData theme) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(theme: theme, home: home));
  await tester.pump();
}

void main() {
  for (final theme in [AppTheme.light, AppTheme.dark]) {
    final name = theme.brightness.name;

    testWidgets('the Evenimente preview renders in $name, in list and map mode', (tester) async {
      await _pump(tester, const EventsTabPreview(showTiles: false), theme);
      expect(tester.takeException(), isNull);
      expect(find.text('Protocolul Cerber'), findsOneWidget);
      expect(find.text('Joacă'), findsOneWidget);
      await tester.tap(find.text('Hartă'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('the Joacă preview renders its four states in $name', (tester) async {
      await _pump(tester, const PlayTabPreview(), theme);
      expect(find.text('Continuă jocul'), findsOneWidget);
      expect(find.text('În joc'), findsWidgets);
      for (final (tab, text) in [('Cod', 'Introdu codul'), ('Următorul', 'Vezi evenimentul'), ('Nimic', 'Vezi evenimentele')]) {
        await tester.tap(find.text(tab));
        await tester.pump();
        expect(find.text(text), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the launcher opens both previews', (tester) async {
    await _pump(tester, const Scaffold(body: ShellPreviewsLauncher()), AppTheme.light);
    await tester.tap(find.text('Joacă'));
    await tester.pumpAndSettle();
    expect(find.byType(PlayTabPreview), findsOneWidget);
  });
}
