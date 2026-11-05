import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/home/logic/preparation_steps.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/team_member.dart';

Event _event(DateTime start) => Event(eventId: 'e', name: 'Eveniment', dateEvent: start);

Team _team({required int size, required int members}) => Team(
      name: 'Vulpile',
      teamMembers: '',
      captainName: 'Victor',
      phoneNumber: '',
      captainEmail: '',
      numberOfMembers: size,
      members: [
        for (var i = 0; i < members; i++) TeamMember(uid: 'u$i', displayName: 'Membru $i', initials: 'M$i'),
      ],
    );

void main() {
  final start = DateTime(2026, 11, 14, 10);
  final threeDaysBefore = DateTime(2026, 11, 11, 18);
  final eventMorning = DateTime(2026, 11, 14, 8);

  test('the labels', () {
    expect(preparationLabels, ['Înscriși', 'Echipă completă', 'Cod de start']);
  });

  test('registered, team not full, days before: one step', () {
    final trail = preparationTrail(_event(start), _team(size: 4, members: 3), threeDaysBefore);
    expect((trail.teamName, trail.done), ('Vulpile', 1));
  });

  test('a full team days before: two steps', () {
    expect(preparationTrail(_event(start), _team(size: 4, members: 4), threeDaysBefore).done, 2);
  });

  test('a full team on the event day: all three', () {
    expect(preparationTrail(_event(start), _team(size: 4, members: 4), eventMorning).done, 3);
  });

  test('not full on the event day: still one, a later step never shows before an earlier one', () {
    expect(preparationTrail(_event(start), _team(size: 4, members: 3), eventMorning).done, 1);
  });

  test('a team without a size is never complete', () {
    expect(preparationTrail(_event(start), _team(size: 0, members: 2), threeDaysBefore).done, 1);
  });
}
