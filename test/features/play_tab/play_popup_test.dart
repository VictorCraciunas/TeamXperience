import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/event_type.dart';
import 'package:teamxperience/features/play_tab/controller/play_popup_controller.dart';
import 'package:teamxperience/features/play_tab/widgets/play_popup.dart';
import 'package:teamxperience/features/play_tab/widgets/play_popup_actions.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/team_member.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/state_management/user_registered_events.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

class _Events extends Fake with ChangeNotifier implements EventList {
  List<Event> list = const [];
  @override
  List<Event> get events => list;
}

class _UserEvents extends Fake with ChangeNotifier implements UserEventsProvider {
  List<Event> upcoming = const [];
  Event? active;
  Team? team;
  Event? started;
  @override
  List<Event> get upcomingRegisteredEvents => upcoming;
  @override
  List<Event> get registeredEvents => [...upcoming, if (active case final a?) a, if (started case final s?) s];
  @override
  Event? get activeEvent => active;
  @override
  Team? get activeTeam => team;
  @override
  Event? get recentlyStartedEvent => started;
  @override
  Event? get finishedEvent => null;
  @override
  Team? get finishedTeam => null;
}

final _team = Team(
  name: 'Vulpile',
  teamMembers: '',
  captainName: 'Ana',
  phoneNumber: '',
  captainEmail: '',
  hasStarted: true,
  missionProgress: 3,
  members: const [
    TeamMember(uid: 'a', displayName: 'Ana', initials: 'AN'),
    TeamMember(uid: 'm', displayName: 'Mihai', initials: 'MI'),
    TeamMember(uid: 'r', displayName: 'Radu', initials: 'RA'),
  ],
);

Event _game(DateTime start) => Event(
      eventId: 'harta',
      name: 'Harta Pierdută',
      dateEvent: start,
      punctDeStart: 'Piața Mare',
      meetingPointNote: 'lângă fântână',
      teamSizeMax: 4,
      nrMissions: 6,
      missions: [for (var i = 0; i < 6; i++) Mission(id: '$i', title: i == 3 ? 'Fântâna cu lei' : 'M$i')],
    );

Event _public(String id, String name, int days) => Event(
      eventId: id,
      name: name,
      type: EventType.PUBLIC,
      dateEvent: DateTime.now().add(Duration(days: days)),
    );

class _Rig {
  _Rig({Team? fetched, this.size = const Size(400, 800), this.textScale = 1, this.reduced = false})
      : _fetched = fetched;

  final events = _Events();
  final userEvents = _UserEvents();
  final Team? _fetched;
  final Size size;
  final double textScale;
  final bool reduced;
  final taps = <String>[];
  late final controller = PlayPopupController(
    userEvents: userEvents,
    eventList: events,
    teamFor: (_) async => _fetched,
    teams: (_) => Stream.value([_team]),
    countTeams: (_) async => 9,
    random: Random(2),
  );

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    controller.open();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: MediaQuery(
        data: MediaQueryData(size: size, textScaler: TextScaler.linear(textScale), disableAnimations: reduced),
        child: Scaffold(
          body: PlayPopup(
            controller: controller,
            actions: PlayPopupActions(
              openEvent: (_) => taps.add('event'),
              openTeam: (_) => taps.add('team'),
              enterCode: (_) => taps.add('code'),
              continueGame: (_, _) => taps.add('game'),
              openChat: (_, _) => taps.add('chat'),
              browseAll: () => taps.add('all'),
            ),
          ),
        ),
      ),
    ));
    // Frame by frame, so each animation that starts after another also runs.
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> done(WidgetTester tester) async {
    controller.closed();
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  }
}

void main() {
  testWidgets('registered: the ticket with the countdown, the team and the place', (tester) async {
    final rig = _Rig(fetched: _team);
    rig.userEvents.upcoming = [_game(DateTime.now().add(const Duration(days: 20)))];
    await rig.pump(tester);
    expect(find.text('Următorul tău joc'), findsOneWidget);
    expect(find.text('Harta Pierdută'), findsOneWidget);
    for (final unit in ['zile', 'ore', 'min', 'sec']) {
      expect(find.text(unit), findsOneWidget);
    }
    expect(find.text('Echipa Vulpile'), findsOneWidget);
    expect(find.text('3 din 4 membri'), findsOneWidget);
    expect(find.textContaining('Piața Mare', findRichText: true), findsOneWidget);
    expect(find.textContaining('lângă fântână', findRichText: true), findsOneWidget);
    await tester.tap(find.text('Echipa mea'));
    await tester.tap(find.text('Vezi evenimentul'));
    expect(rig.taps, ['team', 'event']);
    await rig.done(tester);
  });

  testWidgets('registered without a team yet: no team row', (tester) async {
    final rig = _Rig();
    rig.userEvents.upcoming = [_game(DateTime.now().add(const Duration(days: 2)))];
    await rig.pump(tester);
    expect(find.text('Următorul tău joc'), findsOneWidget);
    expect(find.textContaining('membri'), findsNothing);
    await rig.done(tester);
  });

  testWidgets('start window: minutes left and the start code', (tester) async {
    final rig = _Rig(fetched: _team);
    rig.userEvents.started = _game(DateTime.now().subtract(const Duration(minutes: 18)));
    await rig.pump(tester);
    expect(find.text('A început'), findsOneWidget);
    expect(find.text('Mai ai timp să intri în joc'), findsOneWidget);
    expect(find.textContaining('Codul îl primești de la organizator la', findRichText: true), findsOneWidget);
    await tester.tap(find.text('Introdu codul de start'));
    expect(rig.taps, ['code']);
    await rig.done(tester);
  });

  testWidgets('playing: mission, time left, place, continue', (tester) async {
    final rig = _Rig();
    rig.userEvents
      ..active = _game(DateTime.now().subtract(const Duration(minutes: 40)))
      ..team = _team;
    await rig.pump(tester);
    expect(find.text('În joc'), findsOneWidget);
    expect(find.text('Misiunea 4 din 6 · Fântâna cu lei'), findsOneWidget);
    expect(find.text('rămase'), findsOneWidget);
    expect(find.text('Locul 1'), findsOneWidget);
    expect(find.text('din 1 echipe'), findsOneWidget);
    await tester.tap(find.text('Continuă jocul'));
    await tester.tap(find.text('Scrie organizatorului'));
    expect(rig.taps, ['game', 'chat']);
    await rig.done(tester);
  });

  testWidgets('not registered: a suggestion, then another at random', (tester) async {
    final rig = _Rig();
    rig.events.list = [_public('a', 'Moștenirea Cartografului', 4), _public('b', 'Protocolul Cerber', 10)];
    await rig.pump(tester);
    expect(find.text('Nu ești înscris la niciun joc'), findsOneWidget);
    expect(find.text('Ce zici de acesta?'), findsOneWidget);
    expect(find.text('Recomandat pentru tine'), findsOneWidget);
    expect(find.text('Moștenirea Cartografului'), findsOneWidget);
    expect(find.text('9 echipe'), findsOneWidget);
    await tester.tap(find.text('Alt joc'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('La întâmplare'), findsOneWidget);
    expect(find.text('Protocolul Cerber'), findsOneWidget);
    await tester.tap(find.text('Toate evenimentele'));
    expect(rig.taps, ['all']);
    await rig.done(tester);
  });

  testWidgets('one suggestion: no "Alt joc"', (tester) async {
    final rig = _Rig();
    rig.events.list = [_public('a', 'Moștenirea Cartografului', 4)];
    await rig.pump(tester);
    expect(find.text('Alt joc'), findsNothing);
    await rig.done(tester);
  });

  testWidgets('nothing open: only "Toate evenimentele"', (tester) async {
    final rig = _Rig();
    await rig.pump(tester);
    expect(find.text('Nu ești înscris la niciun joc'), findsOneWidget);
    expect(find.text('Nu e niciun joc deschis acum.'), findsOneWidget);
    expect(find.text('Vezi evenimentul'), findsNothing);
    expect(find.text('Toate evenimentele'), findsOneWidget);
    await rig.done(tester);
  });

  testWidgets('tapping the dimmed area asks to close, then the exit closes it', (tester) async {
    final rig = _Rig();
    await rig.pump(tester);
    await tester.tapAt(const Offset(200, 30));
    expect(rig.controller.isClosing, isTrue);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(rig.controller.isOpen, isFalse);
    await tester.pumpWidget(const SizedBox());
    rig.controller.dispose();
  });

  testWidgets('reduced motion: the card is there after a short fade', (tester) async {
    final rig = _Rig(reduced: true);
    rig.events.list = [_public('a', 'Moștenirea Cartografului', 4), _public('b', 'Protocolul Cerber', 10)];
    rig.controller.open();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: MediaQuery(
        data: const MediaQueryData(size: Size(400, 800), disableAnimations: true),
        child: Scaffold(
          body: PlayPopup(
            controller: rig.controller,
            actions: PlayPopupActions(
              openEvent: (_) {},
              openTeam: (_) {},
              enterCode: (_) {},
              continueGame: (_, _) {},
              openChat: (_, _) {},
              browseAll: () {},
            ),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 220));
    final card = tester.widget<Opacity>(
      find.ancestor(of: find.text('Moștenirea Cartografului'), matching: find.byType(Opacity)).first,
    );
    expect(card.opacity, 1);
    await rig.done(tester);
  });

  testWidgets('a small phone with large text: no overflow in any card', (tester) async {
    Future<void> check(void Function(_Rig) setup) async {
      final rig = _Rig(fetched: _team, size: const Size(320, 640), textScale: 1.3);
      setup(rig);
      await rig.pump(tester);
      expect(tester.takeException(), isNull);
      await rig.done(tester);
    }

    await check((r) => r.userEvents.upcoming = [_game(DateTime.now().add(const Duration(days: 20)))]);
    await check((r) => r.userEvents.started = _game(DateTime.now().subtract(const Duration(minutes: 18))));
    await check((r) => r.userEvents
      ..active = _game(DateTime.now().subtract(const Duration(minutes: 40)))
      ..team = _team);
    await check((r) => r.events.list = [_public('a', 'Moștenirea Cartografului', 4), _public('b', 'Protocolul Cerber', 10)]);
  });
}
