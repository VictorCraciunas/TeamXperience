import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/play_tab/logic/play_popup_texts.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/team_member.dart';

final _now = DateTime(2026, 11, 14, 12);

Team _team({int progress = 0, Map<int, DateTime>? solved, Map<String, DateTime>? presence}) => Team(
      name: 'Vulpile',
      teamMembers: '',
      captainName: 'Ana',
      phoneNumber: '',
      captainEmail: '',
      missionProgress: progress,
      missionCompletedAt: solved,
      presence: presence,
      members: const [
        TeamMember(uid: 'a', displayName: 'Ana', initials: 'AN'),
        TeamMember(uid: 'm', displayName: 'Mihai', initials: 'MI'),
        TeamMember(uid: 'r', displayName: 'Radu', initials: 'RA'),
      ],
    );

final _six = Event(
  eventId: 'e',
  name: 'Harta Pierdută',
  nrMissions: 6,
  teamSizeMax: 4,
  missions: [
    Mission(id: '0', title: 'Scara Pasajului'),
    Mission(id: '1', title: 'Turnul Sfatului'),
    Mission(id: '2', title: 'Podul Minciunilor'),
    Mission(id: '3', title: 'Fântâna cu lei'),
    Mission(id: '4'),
    Mission(id: '5'),
  ],
);

void main() {
  test('clockParts splits and clamps', () {
    expect(
      clockParts(const Duration(days: 20, hours: 2, minutes: 12, seconds: 33)),
      (days: 20, hours: 2, minutes: 12, seconds: 33),
    );
    expect(clockParts(const Duration(seconds: -5)), (days: 0, hours: 0, minutes: 0, seconds: 0));
  });

  test('membersLine counts members of the max size', () {
    expect(membersLine(_team(), _six), '3 din 4 membri');
  });

  test('hereLine counts the members seen in the last two minutes', () {
    final team = _team(presence: {'a': _now, 'm': _now.subtract(const Duration(minutes: 1)), 'r': DateTime(2026)});
    expect(hereLine(team, _six, _now), '2 din 4 sunt aici');
  });

  test('missionTitleLine names the current mission', () {
    expect(missionTitleLine(_six, _team(progress: 3)), 'Misiunea 4 din 6 · Fântâna cu lei');
    expect(missionTitleLine(_six, _team(progress: 4)), 'Misiunea 5 din 6');
  });

  test('hoursMinutes', () {
    expect(hoursMinutes(const Duration(hours: 1, minutes: 12)), '1 h 12 min');
    expect(hoursMinutes(const Duration(minutes: 12)), '12 min');
    expect(hoursMinutes(const Duration(minutes: -3)), '0 min');
  });

  test('lastSolved gives the title and how long ago', () {
    final team = _team(solved: {
      0: _now.subtract(const Duration(minutes: 30)),
      1: _now.subtract(const Duration(minutes: 6)),
    });
    expect(lastSolved(_six, team, _now), (title: 'Turnul Sfatului', ago: 'acum 6 min'));
    expect(lastSolved(_six, _team(), _now), isNull);
    expect(
      lastSolved(_six, _team(solved: {4: _now.subtract(const Duration(seconds: 20))}), _now),
      (title: null, ago: 'acum câteva secunde'),
    );
    expect(lastSolved(_six, _team(solved: {0: _now.subtract(const Duration(hours: 2))}), _now)?.ago, 'acum 2 h');
  });

  test('startPlace is the trimmed meeting place, or null', () {
    expect(startPlace(Event(eventId: 'e', punctDeStart: ' Piața Mare ')), 'Piața Mare');
    expect(startPlace(Event(eventId: 'e', punctDeStart: '  ')), isNull);
    expect(startPlace(Event(eventId: 'e')), isNull);
  });

  test('suggestionWhen', () {
    expect(suggestionWhen(DateTime(2026, 11, 14, 11)), 'Sâm 14 nov · 11:00');
  });
}
