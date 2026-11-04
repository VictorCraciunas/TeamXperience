import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/join_team/controller/join_team_controller.dart';
import 'package:teamxperience/features/join_team/logic/join_state.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team_member.dart';
import 'package:teamxperience/service/event_service/event_service.dart';
import 'package:teamxperience/service/team_service/invite_preview.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

class _FakeTeams extends Fake implements TeamService {
  List<String> eventIds = ['e1'];
  Object? joinFailure;

  @override
  Future<InvitePreview> previewInvite(String code) async => const InvitePreview(
    crewId: 'c1',
    crewName: 'Vulpile',
    captainName: 'Victor',
    members: [TeamMember(uid: 'u1', displayName: 'Victor C', initials: 'VC')],
    alreadyMember: false,
  );

  @override
  Future<List<String>> joinTeam(String code) async {
    final error = joinFailure;
    if (error != null) throw error;
    return eventIds;
  }
}

class _FakeEvents extends Fake implements EventService {
  _FakeEvents(this.events);

  final List<Event> events;

  @override
  Future<List<Event>> getAllEvents() async => events;
}

class _RecordingUser extends UserProvider {
  final added = <String>[];

  @override
  void addRegisteredEvent(String eventId) => added.add(eventId);
}

class _Routes extends NavigatorObserver {
  final names = <String>[];
  Object? lastArguments;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    names.add('push ${route.settings.name}');
    lastArguments = route.settings.arguments;
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    names.add(
      'replace ${oldRoute?.settings.name} with ${newRoute?.settings.name}',
    );
    lastArguments = newRoute?.settings.arguments;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      names.add('pop ${route.settings.name}');
}

class _Harness {
  _Harness(this.tester, {List<Event> events = const []})
    : eventList = EventList(_FakeEvents(events));

  final WidgetTester tester;
  final teams = _FakeTeams();
  final user = _RecordingUser();
  final EventList eventList;
  final observer = _Routes();
  late JoinTeamController controller;

  Future<void> pump() async {
    await eventList.loadEvents(forceRefresh: true);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>.value(value: user),
          ChangeNotifierProvider<EventList>.value(value: eventList),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          navigatorObservers: [observer],
          onGenerateRoute:
              (settings) => MaterialPageRoute<void>(
                settings: settings,
                builder: (context) {
                  if (settings.name == 'join') {
                    controller = JoinTeamController(
                      context: context,
                      teamService: teams,
                    );
                  }
                  return const Scaffold(body: SizedBox());
                },
              ),
          initialRoute: '/',
        ),
      ),
    );
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('join');
    await tester.pumpAndSettle();
  }

  Future<void> joinWithCode() async {
    controller.codeChanged('VLP482');
    await tester.pump();
    await controller.confirm();
    await tester.pumpAndSettle();
  }
}

Event _event(String id) =>
    Event(eventId: id, name: 'Eveniment $id', dateEvent: DateTime(2030, 1, 1));

void main() {
  testWidgets(
    'joining adds the events and opens the first one known, in place of the screen',
    (tester) async {
      final h = _Harness(tester, events: [_event('e2'), _event('e3')]);
      h.teams.eventIds = ['missing', 'e2', 'e3'];
      await h.pump();
      await h.joinWithCode();

      expect(h.user.added, ['missing', 'e2', 'e3']);
      expect(h.observer.names.last, 'replace join with ${Routes.eventDetails}');
      final arguments = h.observer.lastArguments;
      expect(arguments, isA<Map<String, Object?>>());
      if (arguments is Map<String, Object?>) {
        expect((arguments['event'] as Event).eventId, 'e2');
        expect(arguments['isAdmin'], false);
      }
    },
  );

  testWidgets('with no events the screen closes', (tester) async {
    final h = _Harness(tester);
    h.teams.eventIds = [];
    await h.pump();
    await h.joinWithCode();

    expect(h.user.added, isEmpty);
    expect(h.observer.names.last, 'pop join');
  });

  testWidgets('a refused join stays on the screen with the error text', (
    tester,
  ) async {
    final h = _Harness(tester, events: [_event('e1')]);
    h.teams.joinFailure = FirebaseFunctionsException(
      message: 'x',
      code: 'failed-precondition',
      details: {'reason': 'teamFull'},
    );
    await h.pump();
    await h.joinWithCode();

    final state = h.controller.state;
    expect(state is Problem ? state.text : null, 'Echipa e completă');
    expect(h.user.added, isEmpty);
    expect(h.observer.names.last, 'push join');
  });
}
