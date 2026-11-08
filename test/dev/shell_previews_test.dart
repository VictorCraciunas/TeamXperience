import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/dev/events_tab_preview.dart';
import 'package:teamxperience/dev/game_intro_preview.dart';
import 'package:teamxperience/dev/start_code_preview.dart';
import 'package:teamxperience/dev/home_preview.dart';
import 'package:teamxperience/dev/finish_preview.dart';
import 'package:teamxperience/dev/location_puzzle_preview.dart';
import 'package:teamxperience/dev/photo_puzzle_preview.dart';
import 'package:teamxperience/dev/play_tab_preview.dart';
import 'package:teamxperience/dev/profile_preview.dart';
import 'package:teamxperience/dev/puzzle_frame_preview.dart';
import 'package:teamxperience/dev/route_preview.dart';
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

    testWidgets('the route preview renders in parchment and in neon in $name', (tester) async {
      await _pump(tester, const RoutePreview(), theme);
      expect(find.text('Moștenirea Cartografului'), findsOneWidget);
      expect(find.text('1 · Scara Pasajului'), findsOneWidget);
      expect(find.text('Misiunea 4 · acum'), findsOneWidget);
      expect(find.text('Vulpile · locul 2 din 12'), findsOneWidget);
      await tester.tap(find.text('Neon'));
      await tester.pump();
      expect(find.text('Misiunea 4 · acum'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the puzzle frame preview renders a wrong answer and a lock, in both looks, in $name', (tester) async {
      await _pump(tester, const PuzzleFramePreview(), theme);
      expect(find.text('Misiunea 4 din 6'), findsOneWidget);
      expect(find.text('Casa cu ochi'), findsOneWidget);
      expect(find.text('Nu e anul ăsta. Uită-te mai sus pe ușă.'), findsOneWidget);
      expect(find.text('2 încercări rămase'), findsOneWidget);
      expect(find.text('Indiciu'), findsOneWidget);
      await tester.tap(find.text('Blocat'));
      await tester.pump();
      expect(find.text('Mai încercați în 0:45'), findsOneWidget);
      await tester.tap(find.text('Neon'));
      await tester.pump();
      expect(find.text('Introdu codul de acces.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the location puzzle preview renders its states in both looks in $name', (tester) async {
      await _pump(tester, const LocationPuzzlePreview(), theme);
      expect(find.text('Misiunea 5 din 6'), findsOneWidget);
      expect(find.text('Unde dorm clopotele'), findsOneWidget);
      expect(find.text('140 m'), findsOneWidget);
      expect(find.text('mai aproape'), findsOneWidget);
      await tester.tap(find.text('În cerc'));
      await tester.pump();
      expect(find.text('Ești în cerc'), findsOneWidget);
      await tester.tap(find.text('Fără acces'));
      await tester.pump();
      expect(find.text('Deschide setările'), findsOneWidget);
      await tester.tap(find.text('Neon'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('the photo puzzle preview renders its states in both looks in $name', (tester) async {
      await _pump(tester, const PhotoPuzzlePreview(), theme);
      expect(find.text('Misiunea 3 din 6'), findsOneWidget);
      expect(find.text('Turnul Sfatului'), findsOneWidget);
      expect(find.text('Organizatorul se uită la poză'), findsOneWidget);
      await tester.tap(find.text('Aprobată'));
      await tester.pump();
      expect(find.text('Aprobată. Bravo!'), findsOneWidget);
      await tester.tap(find.text('Respinsă'));
      await tester.pump();
      expect(find.text('Respinsă: „Nu se vede ceasul”'), findsOneWidget);
      await tester.tap(find.text('Neon'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('the finish preview renders complete and partial, in both looks, in $name', (tester) async {
      await _pump(tester, const FinishPreview(), theme);
      expect(find.text('Harta e completă'), findsOneWidget);
      expect(find.text('1:48'), findsOneWidget);
      expect(find.text('4,7'), findsOneWidget);
      expect(find.text('Cea mai rapidă: misiunea 2 (6 min)'), findsOneWidget);
      expect(find.text('+4'), findsOneWidget);
      await tester.tap(find.text('Oprit mai devreme'));
      await tester.pump();
      expect(find.text('Jocul s-a încheiat'), findsOneWidget);
      await tester.tap(find.text('Neon'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('the Profil preview renders new, mockup, top and admin in $name', (tester) async {
      await _pump(tester, const ProfilePreview(), theme);
      expect(find.text('Explorator · 640 / 1000 XP'), findsOneWidget);
      expect(find.text('4 din 12'), findsOneWidget);
      expect(find.text('Moștenirea Cartografului'), findsOneWidget);
      await tester.tap(find.text('Nou'));
      await tester.pump();
      expect(find.text('Începător · 0 / 500 XP'), findsOneWidget);
      expect(find.text('0 din 12'), findsOneWidget);
      await tester.tap(find.text('Legendă'));
      await tester.pump();
      expect(find.text('Nivel maxim'), findsOneWidget);
      await tester.tap(find.text('Admin'));
      await tester.pump();
      expect(find.text('Insigne'), findsNothing);
      expect(find.text('Deconectare'), findsOneWidget);
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
    await tester.tap(find.text('Traseu'));
    await tester.pumpAndSettle();
    expect(find.byType(RoutePreview), findsOneWidget);
    Navigator.of(tester.element(find.byType(RoutePreview))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Puzzle'));
    await tester.pumpAndSettle();
    expect(find.byType(PuzzleFramePreview), findsOneWidget);
    Navigator.of(tester.element(find.byType(PuzzleFramePreview))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Locație'));
    await tester.pumpAndSettle();
    expect(find.byType(LocationPuzzlePreview), findsOneWidget);
    Navigator.of(tester.element(find.byType(LocationPuzzlePreview))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Poză'));
    await tester.pumpAndSettle();
    expect(find.byType(PhotoPuzzlePreview), findsOneWidget);
    Navigator.of(tester.element(find.byType(PhotoPuzzlePreview))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Final'));
    await tester.pumpAndSettle();
    expect(find.byType(FinishPreview), findsOneWidget);
    Navigator.of(tester.element(find.byType(FinishPreview))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfilePreview), findsOneWidget);
    Navigator.of(tester.element(find.byType(ProfilePreview))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Joacă'));
    await tester.pumpAndSettle();
    expect(find.byType(PlayTabPreview), findsOneWidget);
  });
}
