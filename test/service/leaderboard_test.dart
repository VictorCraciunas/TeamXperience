import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/service/leaderboard.dart';

Team _team(String name, {int progress = 0, bool finished = false, DateTime? last, DateTime? finishedAt}) => Team(
      name: name,
      teamMembers: '',
      captainName: '',
      phoneNumber: '',
      captainEmail: '',
      missionProgress: progress,
      hasStarted: true,
      hasFinished: finished,
      missionCompletedAt: last == null ? null : {progress - 1: last},
      finishedAt: finishedAt,
    );

List<String> _names(List<RankedTeam> ranked) => [for (final r in ranked) r.team.name];

void main() {
  final t = DateTime(2026, 11, 14, 11);

  test('a team that solved every mission ranks first', () {
    final ranked = rankTeams([_team('A', progress: 5), _team('B', progress: 6, finished: true)], missionCount: 6);
    expect(_names(ranked), ['B', 'A']);
    expect([for (final r in ranked) r.place], [1, 2]);
    expect(ranked.first.mission, 6);
  });

  test('a team stopped early does not outrank one with more missions', () {
    final ranked = rankTeams([_team('B', progress: 4, finished: true), _team('A', progress: 5)], missionCount: 6);
    expect(_names(ranked), ['A', 'B']);
    expect(ranked.last.mission, 5);
  });

  test('after an early stop every team is "finished": they rank by missions solved', () {
    final ranked = rankTeams([
      _team('Patru', progress: 4, finished: true),
      _team('Doi', progress: 2, finished: true),
      _team('Cinci', progress: 5, finished: true),
    ], missionCount: 6);
    expect(_names(ranked), ['Cinci', 'Patru', 'Doi']);
    expect(ranked.first.mission, 6, reason: 'on its sixth mission, not done');
  });

  test('two complete routes rank by when they finished; one without a time comes after', () {
    final ranked = rankTeams([
      _team('Târziu', progress: 6, finished: true, finishedAt: t.add(const Duration(minutes: 9))),
      _team('Fără oră', progress: 6, finished: true),
      _team('Devreme', progress: 6, finished: true, finishedAt: t),
    ], missionCount: 6);
    expect(_names(ranked), ['Devreme', 'Târziu', 'Fără oră']);
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
