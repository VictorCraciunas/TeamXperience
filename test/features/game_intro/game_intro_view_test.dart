import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/game_intro/controller/game_intro_controller.dart';
import 'package:teamxperience/features/game_intro/logic/game_door.dart';
import 'package:teamxperience/features/game_intro/widgets/game_intro_view.dart';
import 'package:teamxperience/features/game_intro/widgets/intro_letter_card.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';
import 'package:teamxperience/ui/theme/event_palette.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

const _letter =
    'Dragi exploratori, harta mea a rămas neterminată. Am ascuns bucățile ei în șase locuri pe care doar un ochi atent le găsește. Prima vă așteaptă unde treptele nu se termină niciodată.';

Event _event({String? letter = _letter, String? city = 'Sibiu', int? minutes = 120}) => Event(
      eventId: 'e1',
      name: 'Moștenirea Cartografului',
      location: city,
      dateEvent: DateTime(2026, 11, 14, 10),
      nrMissions: 6,
      durationMinutes: minutes,
      introLetter: letter,
      introSignature: 'Cartograful',
    );

Future<List<String>> _pump(
  WidgetTester tester,
  Event event, {
  double width = 390,
  double textScale = 1,
  ThemeData? theme,
  bool parchment = true,
}) async {
  final calls = <String>[];
  tester.view.physicalSize = Size(width * 3, 760 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final appTheme = theme ?? AppTheme.light;
  final colors = appTheme.extension<AppColors>() ?? AppColors.light;
  await tester.pumpWidget(MaterialApp(
    theme: appTheme,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child ?? const SizedBox.shrink(),
    ),
    home: EventThemeScope(
      palette: parchment ? EventPalette.parchment : EventPalette.fromApp(colors),
      child: Scaffold(body: GameIntroView(event: event, onStart: () => calls.add('start'))),
    ),
  ));
  return calls;
}

class _Door extends GameDoor {
  int leaves = 0;

  @override
  Future<void> leaveIntro(NavigatorState navigator, Event event, Team team) async {
    leaves++;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  testWidgets('mockup 05: the seal, the date, the name, the letter, the facts and the button', (tester) async {
    final calls = await _pump(tester, _event());
    expect(find.text('Sibiu, 14 noiembrie'), findsOneWidget);
    expect(find.text('Moștenirea Cartografului'), findsOneWidget);
    expect(find.text(_letter), findsOneWidget);
    expect(find.text('— Cartograful'), findsOneWidget);
    for (final t in ['6 misiuni', '2 ore', '1 indiciu / misiune']) {
      expect(find.text(t), findsOneWidget);
    }
    expect(find.text('Cronometrul pornește acum pentru toată echipa.'), findsOneWidget);
    expect(tester.getSize(find.byKey(const ValueKey('intro-seal'))), const Size(76, 76));
    expect(find.byIcon(TablerIcons.compass), findsOneWidget);
    await tester.tap(find.text('Spre prima misiune'));
    expect(calls, ['start']);
  });

  testWidgets('drawn in parchment', (tester) async {
    await _pump(tester, _event());
    final page = tester.widget<ColoredBox>(find.byKey(const ValueKey('intro-page')));
    expect(page.color, EventPalette.parchment.background);
    final title = tester.widget<Text>(find.text('Moștenirea Cartografului')).style;
    expect((title?.fontFamily, title?.fontSize, title?.height), (AppFonts.voice, 22, 1.25));
  });

  testWidgets('no letter: no letter card', (tester) async {
    await _pump(tester, _event(letter: null));
    expect(find.byType(IntroLetterCard), findsNothing);
    expect(find.text('Spre prima misiune'), findsOneWidget);
  });

  testWidgets('no city: just the day; unknown duration: no hourglass', (tester) async {
    await _pump(tester, _event(city: null, minutes: null));
    expect(find.text('14 noiembrie'), findsOneWidget);
    expect(find.byIcon(TablerIcons.hourglass), findsNothing);
  });

  testWidgets('a long letter scrolls', (tester) async {
    await _pump(tester, _event(letter: List.filled(40, _letter).join(' ')));
    expect(tester.takeException(), isNull);
    expect(find.text('Spre prima misiune'), findsOneWidget);
  });

  for (final parchment in [true, false]) {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      testWidgets('fits 320 px at 1.3x text (${parchment ? 'parchment' : 'app'}, ${theme.brightness.name})', (tester) async {
        await _pump(tester, _event(), width: 320, textScale: 1.3, theme: theme, parchment: parchment);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('the controller leaves the intro once, even with a double tap', (tester) async {
    final door = _Door();
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(navigatorKey: key, home: const SizedBox()));
    final nav = key.currentState;
    if (nav == null) throw StateError('no navigator');
    final controller = GameIntroController(
      event: _event(),
      team: Team(name: 'Vulpile', teamMembers: '', captainName: '', phoneNumber: '', captainEmail: ''),
      door: door,
    );
    await tester.runAsync(() => Future.wait([controller.start(nav), controller.start(nav)]));
    expect(door.leaves, 1);
  });
}
