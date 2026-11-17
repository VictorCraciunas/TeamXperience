import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/event_see_registered_teams/event_registered_teams_controller.dart';
import 'package:teamxperience/features/event_see_registered_teams/event_registered_teams_screen.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/team_member.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

final _event = Event(
  eventId: 'e',
  name: 'Moștenirea Cartografului, ediția de iarnă cu un nume foarte lung',
  dateEvent: DateTime(2026, 11, 21, 10),
);

final _teams = [
  Team(
    name: 'Vulpile Argintii de pe Dealul Cetății',
    teamMembers: '',
    captainName: 'Ana Pop',
    captainUid: 'u2',
    phoneNumber: '0722 123 456',
    captainEmail: 'ana.pop.cu.o.adresa.foarte.lunga@email.ro',
    userIds: ['u0', 'u1', 'u2', 'u3', 'u4'],
    numberOfMembers: 5,
    members: const [
      TeamMember(uid: 'u0', displayName: 'Mihai Ionescu', initials: 'MI'),
      TeamMember(uid: 'u1', displayName: 'Ioana Radu', initials: 'IR'),
      TeamMember(uid: 'u2', displayName: 'Ana Pop', initials: 'AP'),
      TeamMember(uid: 'u3', displayName: 'Dan Pop', initials: 'DP'),
      TeamMember(uid: 'u4', displayName: 'Elena Dobre', initials: 'ED'),
    ],
  ),
  Team(
    name: 'Cometele',
    teamMembers: 'Ion Popescu, Radu Marin',
    captainName: 'Radu Marin',
    phoneNumber: '',
    captainEmail: 'radu@email.ro',
    userIds: ['x'],
    numberOfMembers: 4,
  ),
];

Future<void> _pump(WidgetTester tester, {Size size = const Size(390, 844), double textScale = 1}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      builder: (context, app) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: app ?? const SizedBox.shrink(),
      ),
      onGenerateRoute: (settings) => MaterialPageRoute<void>(
        settings: RouteSettings(arguments: _event),
        builder: (_) => EventRegisteredTeams(
          createController: (event) => EventRegisteredTeamsController(
            event,
            load: (_) async => _teams,
            delete: (_, __) async {},
            openPhone: (_) async => true,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('stats, closed cards, then one card open with its captain first', (tester) async {
    await _pump(tester);
    expect(find.text('Echipe înscrise'), findsOneWidget);
    expect(find.textContaining('· Sâm 21 nov'), findsOneWidget);
    expect(find.text('6'), findsOneWidget); // jucători
    expect(find.text('5 din 5 jucători · Căpitan: Ana P.'), findsOneWidget);
    expect(find.text('1 din 4 jucători · incompletă'), findsOneWidget);
    expect(find.text('Mihai Ionescu'), findsNothing);

    await tester.tap(find.text('Vulpile Argintii de pe Dealul Cetății'));
    await tester.pumpAndSettle();
    expect(find.text('5 din 5 jucători'), findsOneWidget);
    expect(find.text('căpitan'), findsOneWidget);
    expect(find.text('Ana Pop'), findsOneWidget);
    expect(find.text('Dan Pop'), findsNothing);
    expect(find.text('+ 2 jucători · 0722 123 456 · ana.pop.cu.o.adresa.foarte.lunga@email.ro'), findsOneWidget);

    // An old team lists the names typed at registration; opening it closes the first.
    await tester.tap(find.text('Cometele'));
    await tester.pumpAndSettle();
    expect(find.text('Mihai Ionescu'), findsNothing);
    expect(find.text('Ion Popescu'), findsOneWidget);
    expect(find.text('radu@email.ro'), findsOneWidget);
  });

  testWidgets('the search finds a player and ignores diacritics', (tester) async {
    await _pump(tester);
    await tester.enterText(find.byType(TextField), 'cetatii');
    await tester.pump();
    expect(find.text('Cometele'), findsNothing);
    await tester.enterText(find.byType(TextField), 'popescu');
    await tester.pump();
    expect(find.text('Cometele'), findsOneWidget);
    expect(find.text('Vulpile Argintii de pe Dealul Cetății'), findsNothing);
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(find.text('Nicio echipă găsită.'), findsOneWidget);
  });

  testWidgets('fits a small phone at text scale 2 with a card open', (tester) async {
    await _pump(tester, size: const Size(320, 640), textScale: 2);
    await tester.tap(find.text('Vulpile Argintii de pe Dealul Cetății'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
