import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/home/logic/preparation_steps.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

Event _event(DateTime start) => Event(eventId: 'e', name: 'Eveniment', dateEvent: start);

Team _team({
  String name = 'Vulturii',
  String captain = 'Ana',
  String phone = '0712345678',
  String email = 'ana@example.com',
  int members = 4,
}) {
  return Team(
    name: name,
    teamMembers: 'Ana, Dan',
    captainName: captain,
    phoneNumber: phone,
    captainEmail: email,
    numberOfMembers: members,
  );
}

void main() {
  final tomorrow = DateTime(2026, 10, 21, 14);
  final now = DateTime(2026, 10, 20, 12);

  test('a complete team before the event day: two steps done, start code pending', () {
    final steps = preparationSteps(_event(tomorrow), _team(), now);
    expect(steps.map((s) => s.done), [true, true, false]);
    expect(steps.map((s) => s.title), [
      'Înscriere confirmată',
      'Detalii echipă complete',
      'Codul de start',
    ]);
    expect(steps.first.subtitle, 'Vulturii · 4 membri');
  });

  test('without a team nothing is done', () {
    final steps = preparationSteps(_event(tomorrow), null, now);
    expect(steps.map((s) => s.done), [false, false, false]);
  });

  test('missing captain details leave the details step pending', () {
    final steps = preparationSteps(_event(tomorrow), _team(phone: ''), now);
    expect(steps.map((s) => s.done), [true, false, false]);
  });

  test('the start code step is done from the start of the event day', () {
    final sameDay = DateTime(2026, 10, 21, 0, 5);
    final steps = preparationSteps(_event(tomorrow), _team(), sameDay);
    expect(steps.last.done, isTrue);
  });

  test('an event without a date keeps the start code step pending', () {
    final steps = preparationSteps(Event(eventId: 'e'), _team(), now);
    expect(steps.last.done, isFalse);
  });
}
