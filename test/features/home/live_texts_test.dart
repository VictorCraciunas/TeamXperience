import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/home/logic/live_texts.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/team_member.dart';
import 'package:teamxperience/service/leaderboard.dart';

Team _team(String name, {int progress = 0, List<TeamMember> members = const [], Map<String, DateTime>? presence}) => Team(
      name: name,
      teamMembers: '',
      captainName: '',
      phoneNumber: '',
      captainEmail: '',
      missionProgress: progress,
      members: members,
      presence: presence,
    );

List<RankedTeam> _ranked(int count) => [
      for (var i = 0; i < count; i++) RankedTeam(team: _team('T${i + 1}'), place: i + 1, mission: 1),
    ];

void main() {
  final now = DateTime(2026, 11, 14, 11, 0);

  group('liveClock', () {
    test('hours, minutes and seconds', () {
      expect(liveClock(const Duration(hours: 1, minutes: 17, seconds: 42)), '1:17:42');
      expect(liveClock(const Duration(minutes: 5, seconds: 3)), '0:05:03');
    });

    test('never negative', () {
      expect(liveClock(const Duration(seconds: -5)), '0:00:00');
    });
  });

  group('missionLine', () {
    test('the mission the team is on', () {
      expect(missionLine(_team('Vulpile', progress: 3), 6), 'Echipa Vulpile · misiunea 4 din 6');
    });

    test('capped at the last mission', () {
      expect(missionLine(_team('Vulpile', progress: 6), 6), 'Echipa Vulpile · misiunea 6 din 6');
    });

    test('just the team without missions', () {
      expect(missionLine(_team('Vulpile'), 0), 'Echipa Vulpile');
    });
  });

  group('activeMembers', () {
    const ana = TeamMember(uid: 'a', displayName: 'Ana Pop', initials: 'AP');
    const dan = TeamMember(uid: 'd', displayName: 'Dan Ion', initials: 'DI');
    const ion = TeamMember(uid: 'i', displayName: 'Ion Rus', initials: 'IR');

    test('members seen in the last 2 minutes', () {
      final team = _team('V', members: const [ana, dan, ion], presence: {
        'a': now.subtract(const Duration(minutes: 1)),
        'd': now.subtract(const Duration(minutes: 5)),
        'i': now.add(const Duration(seconds: 20)),
      });
      expect([for (final m in activeMembers(team, now)) m.uid], ['a', 'i']);
    });

    test('a uid that is not a member does not count', () {
      final team = _team('V', members: const [ana], presence: {'x': now});
      expect(activeMembers(team, now), isEmpty);
    });
  });

  test('activeLine', () {
    expect(activeLine(3), '3 jucători activi');
    expect(activeLine(1), '1 jucător activ');
    expect(activeLine(0), 'Niciun jucător activ acum');
  });

  group('lastMissionLine', () {
    test('minutes ago', () {
      expect(lastMissionLine(now.subtract(const Duration(minutes: 6)), now), 'Ultima misiune rezolvată acum 6 min');
    });

    test('under a minute', () {
      expect(lastMissionLine(now.subtract(const Duration(seconds: 30)), now), 'Ultima misiune rezolvată acum câteva secunde');
      expect(lastMissionLine(now.add(const Duration(seconds: 10)), now), 'Ultima misiune rezolvată acum câteva secunde');
    });

    test('an hour or more', () {
      expect(lastMissionLine(now.subtract(const Duration(minutes: 125)), now), 'Ultima misiune rezolvată acum 2 h');
    });

    test('none yet', () {
      expect(lastMissionLine(null, now), 'Nicio misiune rezolvată încă');
    });
  });

  group('leaderboardPreview', () {
    List<int> places(List<RankedTeam> rows) => [for (final r in rows) r.place];

    test('own team in the top three: the top three', () {
      expect(places(leaderboardPreview(_ranked(5), 'T2')), [1, 2, 3]);
    });

    test('own team lower: the top two and the own team', () {
      expect(places(leaderboardPreview(_ranked(5), 'T5')), [1, 2, 5]);
    });

    test('fewer than three teams: all of them', () {
      expect(places(leaderboardPreview(_ranked(2), 'T2')), [1, 2]);
    });

    test('own team absent: the top three', () {
      expect(places(leaderboardPreview(_ranked(5), 'Altă')), [1, 2, 3]);
    });
  });
}
