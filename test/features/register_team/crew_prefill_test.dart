import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/register_team/logic/crew_prefill.dart';
import 'package:teamxperience/model/crew.dart';
import 'package:teamxperience/model/crew_team.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/team_member.dart';

Crew _crew({int players = 2, List<CrewTeam> teams = const []}) => Crew(
  id: 'c1',
  name: 'Vulpile',
  captainUid: 'u0',
  memberUids: [for (var i = 0; i < players; i++) 'u$i'],
  members: [for (var i = 0; i < players; i++) TeamMember(uid: 'u$i', displayName: 'P $i', initials: 'P')],
  inviteCode: 'VLP482',
  teams: teams,
);

Event _event({int min = 2, int max = 6}) => Event(eventId: 'e2', teamSizeMin: min, teamSizeMax: max);

Team _last({int size = 5, String phone = ' 0722 123 456 '}) => Team.fromMap({
  'name': 'Vulpile',
  'numberOfMembers': size,
  'phoneNumber': phone,
});

void main() {
  test('takes the name, and the size and phone of the last sign-up', () {
    final values = crewPrefill(crew: _crew(), event: _event(), fallback: 4, last: _last());
    expect(values, (name: 'Vulpile', size: 5, phone: '0722 123 456'));
  });

  test('without a last sign-up: the fallback size and no phone', () {
    expect(crewPrefill(crew: _crew(), event: _event(), fallback: 4), (name: 'Vulpile', size: 4, phone: ''));
  });

  test('never fewer than the players, nor the event minimum', () {
    expect(crewPrefill(crew: _crew(players: 4), event: _event(), fallback: 2, last: _last(size: 3)).size, 4);
    expect(crewPrefill(crew: _crew(players: 1), event: _event(min: 3), fallback: 2, last: _last(size: 2)).size, 3);
  });

  test('never more than the event maximum', () {
    expect(crewPrefill(crew: _crew(), event: _event(max: 4), fallback: 4, last: _last(size: 6)).size, 4);
  });

  group('lastTeamExcept', () {
    const a = CrewTeam(eventId: 'e1', teamName: 'Vulpile');
    const b = CrewTeam(eventId: 'e2', teamName: 'Bufnițele');

    test('the newest link for another event', () {
      expect(_crew(teams: [a, b]).lastTeamExcept('e9'), b);
      expect(_crew(teams: [a, b]).lastTeamExcept('e2'), a);
      expect(_crew().lastTeamExcept('e1'), isNull);
    });

    test('reads the links, skipping broken ones', () {
      final crew = Crew.fromMap('c1', {
        'name': 'Vulpile',
        'teams': [
          {'eventId': 'e1', 'teamName': 'Vulpile'},
          {'eventId': '', 'teamName': 'X'},
          'junk',
        ],
      });
      expect(crew.teams.single.eventId, 'e1');
      expect(crew.teams.single.teamName, 'Vulpile');
    });
  });
}
