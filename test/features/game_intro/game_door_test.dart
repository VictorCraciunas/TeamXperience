import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/game_intro/logic/game_door.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

Team _team(String name) =>
    Team(name: name, teamMembers: '', captainName: '', phoneNumber: '', captainEmail: '');

final _event = Event(eventId: 'e1', name: 'Joc');

/// A page that shows its route name and the team it was given.
Widget _page(BuildContext context, String name) {
  final args = ModalRoute.of(context)?.settings.arguments;
  final team = args is Map ? (args['team'] as Team?)?.name : null;
  return Scaffold(body: Text('$name ${team ?? ''}'.trim()));
}

Future<NavigatorState> _app(WidgetTester tester) async {
  final key = GlobalKey<NavigatorState>();
  await tester.pumpWidget(MaterialApp(
    navigatorKey: key,
    home: const Scaffold(body: Text('home')),
    routes: {
      Routes.gameIntro: (context) => _page(context, 'intro'),
      Routes.eventGame: (context) => _page(context, 'game'),
      Routes.finish: (context) => _page(context, 'finish'),
      '/start': (context) => const Scaffold(body: Text('start')),
    },
  ));
  final nav = key.currentState;
  if (nav == null) throw StateError('no navigator');
  return nav;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('a finished team goes to its finish screen', (tester) async {
    final nav = await _app(tester);
    final team = _team('Vulpile')..hasFinished = true;
    await GameDoor().open(nav, _event, team);
    await tester.pumpAndSettle();
    expect(find.text('finish Vulpile'), findsOneWidget);
  });

  testWidgets('the first time the intro opens, with the event and team', (tester) async {
    final nav = await _app(tester);
    await GameDoor().open(nav, _event, _team('Vulpile'));
    await tester.pumpAndSettle();
    expect(find.text('intro Vulpile'), findsOneWidget);
  });

  testWidgets('leaving the intro replaces it with the game; back goes home', (tester) async {
    final nav = await _app(tester);
    final door = GameDoor();
    await door.open(nav, _event, _team('Vulpile'));
    await tester.pumpAndSettle();
    await door.leaveIntro(nav, _event, _team('Vulpile'));
    await tester.pumpAndSettle();
    expect(find.text('game Vulpile'), findsOneWidget);
    nav.pop();
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('once seen, the game opens directly', (tester) async {
    final nav = await _app(tester);
    final door = GameDoor();
    await door.open(nav, _event, _team('Vulpile'));
    await tester.pumpAndSettle();
    await door.leaveIntro(nav, _event, _team('Vulpile'));
    await tester.pumpAndSettle();
    nav.pop();
    await tester.pumpAndSettle();
    await GameDoor().open(nav, _event, _team('Vulpile'));
    await tester.pumpAndSettle();
    expect(find.text('game Vulpile'), findsOneWidget);
  });

  testWidgets('another team or another event gets the intro again', (tester) async {
    final nav = await _app(tester);
    final door = GameDoor();
    await door.open(nav, _event, _team('Vulpile'));
    await tester.pumpAndSettle();
    await door.leaveIntro(nav, _event, _team('Vulpile'));
    await tester.pumpAndSettle();
    nav.pop();
    await tester.pumpAndSettle();

    await door.open(nav, _event, _team('Lupii'));
    await tester.pumpAndSettle();
    expect(find.text('intro Lupii'), findsOneWidget);
    nav.pop();
    await tester.pumpAndSettle();

    await door.open(nav, Event(eventId: 'e2'), _team('Vulpile'));
    await tester.pumpAndSettle();
    expect(find.text('intro Vulpile'), findsOneWidget);
  });

  testWidgets('replace: the start screen that opened the door goes; back skips it', (tester) async {
    final nav = await _app(tester);
    nav.pushNamed('/start');
    await tester.pumpAndSettle();
    await GameDoor().open(nav, _event, _team('Vulpile'), replace: true);
    await tester.pumpAndSettle();
    nav.pop();
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });
}
