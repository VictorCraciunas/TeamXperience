import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/service/leaderboard.dart';

Team _team(String name, {int progress = 0, bool finished = false, DateTime? last}) => Team(
      name: name,
      teamMembers: '',
      captainName: '',
      phoneNumber: '',
      captainEmail: '',
      missionProgress: progress,
      hasStarted: true,
      hasFinished: finished,
      missionCompletedAt: last == null ? null : {progress - 1: last},
    );

List<String> _names(List<RankedTeam> ranked) => [for (final r in ranked) r.team.name];

void main() {
  final t = DateTime(2026, 11, 14, 11);

  test('a finished team ranks first even with fewer missions on record', () {
    final ranked = rankTeams([_team('A', progress: 5), _team('B', progress: 4, finished: true)], missionCount: 6);
    expect(_names(ranked), ['B', 'A']);
    expect([for (final r in ranked) r.place], [1, 2]);
  });

  test('more missions rank higher', () {
    final ranked = rankTeams([_team('A', progress: 2), _team('B', progress: 4)], missionCount: 6);
    expect(_names(ranked), ['B', 'A']);
  });

  test('on the same mission, the team that got there earlier ranks higher', () {
    final ranked = rankTeams([
      _team('Later', progress: 3, last: t.add(const Duration(minutes: 5))),
      _team('Earlier', progress: 3, last: t),
    ], missionCount: 6);
    expect(_names(ranked), ['Earlier', 'Later']);
  });

  test('missing mission times rank after present ones, then by name', () {
    final ranked = rankTeams([
      _team('Zebre', progress: 3),
      _team('Albine', progress: 3),
      _team('Cu timp', progress: 3, last: t),
    ], missionCount: 6);
    expect(_names(ranked), ['Cu timp', 'Albine', 'Zebre']);
    expect([for (final r in ranked) r.place], [1, 2, 3]);
  });

  test('the mission shown is the one the team is on; a finished team shows the total', () {
    final ranked = rankTeams([
      _team('Pe 4', progress: 3),
      _team('Gata', progress: 6, finished: true),
      _team('Peste', progress: 9),
    ], missionCount: 6);
    expect({for (final r in ranked) r.team.name: r.mission}, {'Gata': 6, 'Peste': 6, 'Pe 4': 4});
  });

  test('without missions every mission is 0', () {
    final ranked = rankTeams([_team('A', progress: 0), _team('B', finished: true)], missionCount: 0);
    expect([for (final r in ranked) r.mission], [0, 0]);
  });

  test('no teams, no ranks', () {
    expect(rankTeams(const [], missionCount: 6), isEmpty);
  });
}
