import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/dev/events_tab_preview.dart';
import 'package:teamxperience/dev/game_intro_preview.dart';
import 'package:teamxperience/dev/start_code_preview.dart';
import 'package:teamxperience/dev/home_preview.dart';
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

    testWidgets('the Acasă preview renders before and during a game in $name', (tester) async {
      await _pump(tester, const HomePreview(), theme);
      expect(tester.takeException(), isNull);
      expect(find.text('Salut, Victor'), findsOneWidget);
      expect(find.text('Următorul tău joc'), findsOneWidget);
      expect(find.text('Pregătirea echipei Vulpile'), findsOneWidget);
      expect(find.text('Evenimente noi'), findsOneWidget);
      await tester.tap(find.text('În timpul jocului'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('LIVE'), findsOneWidget);
      expect(find.text('Clasament live'), findsOneWidget);
      expect(find.text('Vulpile · voi'), findsOneWidget);
      expect(find.text('3 jucători activi'), findsOneWidget);
      expect(find.text('Ultima misiune rezolvată acum 6 min'), findsOneWidget);
      expect(find.text('În joc'), findsWidgets);
    });

    testWidgets('the start-code preview renders its states in $name', (tester) async {
      await _pump(tester, const StartCodePreview(), theme);
      expect(find.text('Introdu codul de start'), findsOneWidget);
      expect(find.text('3 din 4 sunt aici'), findsOneWidget);
      for (final (state, text) in [
        ('Greșit', 'Codul nu e corect. Verifică literele.'),
        ('Pornit', 'Intră în joc'),
        ('Fără echipă', 'Pornește jocul'),
      ]) {
        await tester.tap(find.text(state));
        await tester.pump();
        expect(find.text(text), findsOneWidget, reason: state);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('the intro preview renders both looks in $name', (tester) async {
      await _pump(tester, const GameIntroPreview(), theme);
      expect(find.text('Sibiu, 14 noiembrie'), findsOneWidget);
      expect(find.text('— Cartograful'), findsOneWidget);
      await tester.tap(find.text('Fără culori'));
      await tester.pump();
      expect(find.text('Spre prima misiune'), findsOneWidget);
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

  testWidgets('the launcher opens the previews', (tester) async {
    await _pump(tester, const Scaffold(body: ShellPreviewsLauncher()), AppTheme.light);
    await tester.tap(find.text('Acasă'));
    await tester.pumpAndSettle();
    expect(find.byType(HomePreview), findsOneWidget);
    Navigator.of(tester.element(find.byType(HomePreview))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cod de start'));
    await tester.pumpAndSettle();
    expect(find.byType(StartCodePreview), findsOneWidget);
    Navigator.of(tester.element(find.byType(StartCodePreview))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scrisoarea'));
    await tester.pumpAndSettle();
    expect(find.byType(GameIntroPreview), findsOneWidget);
    Navigator.of(tester.element(find.byType(GameIntroPreview))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Joacă'));
    await tester.pumpAndSettle();
    expect(find.byType(PlayTabPreview), findsOneWidget);
  });
}
