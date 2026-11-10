import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/game_intro/logic/intro_texts.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/utils/event_formats.dart';

void main() {
  Event event({String? city = 'Sibiu', bool date = true, int missions = 6, int? minutes = 120, int hints = 1}) => Event(
        eventId: 'e1',
        location: city,
        dateEvent: date ? DateTime(2026, 11, 14, 10) : null,
        nrMissions: missions,
        durationMinutes: minutes,
        hintsPerMission: hints,
      );

  group('introDateLine', () {
    test('city, day and long month', () {
      expect(introDateLine(event()), 'Sibiu, 14 noiembrie');
    });

    test('without a city', () {
      expect(introDateLine(event(city: null)), '14 noiembrie');
      expect(introDateLine(event(city: ' ')), '14 noiembrie');
    });

    test('without a date', () {
      expect(introDateLine(event(date: false)), '');
    });
  });

  group('introFacts', () {
    test('mockup 05: 6 misiuni, 2 ore, 1 indiciu / misiune', () {
      expect(introFacts(event()), [
        (TablerIcons.map_pin, '6 misiuni'),
        (TablerIcons.hourglass, '2 ore'),
        (TablerIcons.bulb, '1 indiciu / misiune'),
      ]);
    });

    test('one mission, one hour, two hints', () {
      expect([for (final f in introFacts(event(missions: 1, minutes: 60, hints: 2))) f.$2],
          ['1 misiune', '1 oră', '2 indicii / misiune']);
    });

    test('90 and 45 minutes', () {
      expect(introFacts(event(minutes: 90))[1].$2, '1 h 30');
      expect(introFacts(event(minutes: 45))[1].$2, '45 min');
    });

    test('no hints', () {
      expect(introFacts(event(hints: 0)).last.$2, 'Fără indicii');
    });

    test('unknown duration and no missions are left out', () {
      expect([for (final f in introFacts(event(missions: 0, minutes: null))) f.$2], ['1 indiciu / misiune']);
    });
  });

  test('longMonth', () {
    expect(longMonth(11), 'noiembrie');
    expect(longMonth(1), 'ianuarie');
    expect(longMonth(12), 'decembrie');
  });
}
