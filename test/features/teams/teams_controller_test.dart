import 'package:teamxperience/model/season_standing.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/teams/controller/teams_controller.dart';
import 'package:teamxperience/model/crew.dart';
import 'package:teamxperience/model/user.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

class _FakeTeams extends Fake implements TeamService {
  final crews = StreamController<List<Crew>>.broadcast();
  final made = <String>[];
  String? streamedFor;
  int streams = 0;

  @override
  Stream<List<Crew>> streamUserCrews(String uid) {
    streamedFor = uid;
    streams++;
    return crews.stream;
  }

  final standings = StreamController<List<SeasonStanding>>.broadcast();
  String? seasonAsked;

  @override
  Stream<List<SeasonStanding>> streamStandings(String seasonId) {
    seasonAsked = seasonId;
    return standings.stream;
  }

  @override
  Future<({String crewId, String inviteCode})> createCrew(String name) async {
    made.add(name);
    return (crewId: 'c1', inviteCode: 'VLP482');
  }
}

class _SignedIn extends UserProvider {
  _SignedIn(this._user);

  final AppUser? _user;

  @override
  AppUser? get currentUser => _user;
}

AppUser _user() => AppUser(
  email: 'v@example.com',
  firstName: 'Victor',
  lastName: 'C',
  uid: 'u1',
  fcmToken: '',
);

Future<TeamsController> _pump(
  WidgetTester tester,
  _FakeTeams teams, {
  AppUser? user,
  List<String>? pushed,
}) async {
  late TeamsController controller;
  await tester.pumpWidget(
    ChangeNotifierProvider<UserProvider>.value(
      value: _SignedIn(user),
      child: MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute:
            (settings) => MaterialPageRoute<void>(
              settings: settings,
              builder: (context) {
                if (settings.name == '/') {
                  controller = TeamsController(
                    context: context,
                    teamService: teams,
                  );
                } else {
                  pushed?.add(settings.name ?? '');
                }
                return const Scaffold(body: SizedBox());
              },
            ),
      ),
    ),
  );
  return controller;
}

void main() {
  testWidgets('follows the crews of the signed-in player', (tester) async {
    final teams = _FakeTeams();
    final controller = await _pump(tester, teams, user: _user());
    expect(teams.streamedFor, 'u1');
    expect(controller.loading, isTrue);

    teams.crews.add([
      const Crew(
        id: 'c1',
        name: 'Vulpile',
        captainUid: 'u1',
        memberUids: ['u1'],
        members: [],
        inviteCode: 'VLP482',
      ),
    ]);
    await tester.pump();
    expect(controller.loading, isFalse);
    expect(controller.crews?.single.name, 'Vulpile');
  });

  testWidgets('follows this season\'s standings; a failed read leaves them empty', (tester) async {
    final teams = _FakeTeams();
    final controller = await _pump(tester, teams);
    expect(teams.seasonAsked, seasonOf(DateTime.now()).id);
    teams.standings.add(const [SeasonStanding(crewId: 'c1', crewName: 'Vulpile', points: 100)]);
    await tester.pump();
    expect(controller.standings.single.points, 100);
    teams.standings.addError(Exception('offline'));
    await tester.pump();
    expect(controller.standings.single.points, 100);
    expect(controller.error, isNull);
  });

  testWidgets('a stream error is kept for the screen', (tester) async {
    final teams = _FakeTeams();
    final controller = await _pump(tester, teams, user: _user());
    teams.crews.addError('boom');
    await tester.pump();
    expect(controller.error, 'boom');
    expect(controller.loading, isFalse);
  });

  testWidgets('retry clears the error and follows the crews again', (
    tester,
  ) async {
    final teams = _FakeTeams();
    final controller = await _pump(tester, teams, user: _user());
    teams.crews.addError('boom');
    await tester.pump();
    controller.retry();
    expect(controller.error, isNull);
    expect(controller.loading, isTrue);
    expect(teams.streams, 2);
    teams.crews.add(const []);
    await tester.pump();
    expect(controller.crews, isEmpty);
    expect(controller.loading, isFalse);
  });

  testWidgets('without a signed-in player there are no crews and no stream', (
    tester,
  ) async {
    final teams = _FakeTeams();
    final controller = await _pump(tester, teams);
    expect(teams.streamedFor, isNull);
    expect(controller.crews, isEmpty);
  });

  testWidgets('createCrew returns the new code as shown', (tester) async {
    final teams = _FakeTeams();
    final controller = await _pump(tester, teams, user: _user());
    expect(await controller.createCrew('Vulpile'), 'VLP-482');
    expect(teams.made, ['Vulpile']);
  });

  testWidgets('openJoin opens the join screen', (tester) async {
    final pushed = <String>[];
    final controller = await _pump(
      tester,
      _FakeTeams(),
      user: _user(),
      pushed: pushed,
    );
    controller.openJoin();
    await tester.pumpAndSettle();
    expect(pushed, [Routes.joinTeam]);
  });
}
