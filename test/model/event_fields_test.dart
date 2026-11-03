import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/difficulty.dart';
import 'package:teamxperience/model/event.dart';

void main() {
  group('new fields', () {
    test('an old document reads as the defaults', () {
      final e = Event.fromMap({'eventId': 'e1'});
      expect(e.teamSizeMin, 2);
      expect(e.teamSizeMax, 6);
      expect(e.arriveMinutesBefore, 15);
      expect(e.whatToBring, isEmpty);
      expect(e.area, isNull);
      expect(e.finishPoint, isNull);
      expect(e.routeLengthKm, isNull);
      expect(e.durationMinutes, isNull);
      expect(e.difficulty, isNull);
      expect(e.maxTeams, isNull);
      expect(e.startLatitude, isNull);
      expect(e.startLongitude, isNull);
      expect(e.meetingPointNote, isNull);
      expect(e.story, isNull);
      expect(e.organiserName, isNull);
    });

    test('every new field survives toJson and fromMap', () {
      final e = Event(
        eventId: 'e1',
        area: 'Orașul de Sus',
        finishPoint: 'Turnul Sfatului',
        routeLengthKm: 4.5,
        durationMinutes: 120,
        difficulty: Difficulty.medium,
        teamSizeMin: 3,
        teamSizeMax: 5,
        maxTeams: 14,
        startLatitude: 45.7971,
        startLongitude: 24.152,
        meetingPointNote: 'Piața Mare, lângă fântână',
        arriveMinutesBefore: 20,
        whatToBring: ['Telefon încărcat', 'încălțări comode'],
        story: 'Un cartograf a lăsat o hartă.',
        organiserName: 'TeamXperience',
      );
      final back = Event.fromMap(e.toJson());
      expect(back.area, 'Orașul de Sus');
      expect(back.finishPoint, 'Turnul Sfatului');
      expect(back.routeLengthKm, 4.5);
      expect(back.durationMinutes, 120);
      expect(back.difficulty, Difficulty.medium);
      expect(back.teamSizeMin, 3);
      expect(back.teamSizeMax, 5);
      expect(back.maxTeams, 14);
      expect(back.startLatitude, 45.7971);
      expect(back.startLongitude, 24.152);
      expect(back.meetingPointNote, 'Piața Mare, lângă fântână');
      expect(back.arriveMinutesBefore, 20);
      expect(back.whatToBring, ['Telefon încărcat', 'încălțări comode']);
      expect(back.story, 'Un cartograf a lăsat o hartă.');
      expect(back.organiserName, 'TeamXperience');
    });

    test('whole numbers stored as doubles and the other way round still read', () {
      final e = Event.fromMap({'eventId': 'e1', 'routeLengthKm': 4, 'durationMinutes': 120.0, 'startLatitude': 45});
      expect(e.routeLengthKm, 4.0);
      expect(e.durationMinutes, 120);
      expect(e.startLatitude, 45.0);
    });
  });

  group('fallbacks to the old text fields', () {
    test('route length', () {
      expect(Event(eventId: 'e', routeLengthKm: 3, lungimeTraseu: '9 km').effectiveRouteKm, 3);
      expect(Event(eventId: 'e', lungimeTraseu: '4,5 km').effectiveRouteKm, 4.5);
      expect(Event(eventId: 'e', lungimeTraseu: '3.2').effectiveRouteKm, 3.2);
      expect(Event(eventId: 'e', lungimeTraseu: 'ușor').effectiveRouteKm, isNull);
      expect(Event(eventId: 'e').effectiveRouteKm, isNull);
    });

    test('duration', () {
      expect(Event(eventId: 'e', durationMinutes: 75, durata: '2 h').effectiveDurationMinutes, 75);
      for (final text in ['2 h', '2 ore', '2h']) {
        expect(Event(eventId: 'e', durata: text).effectiveDurationMinutes, 120, reason: text);
      }
      for (final text in ['1 h 30', '1h30', '1 oră 30 min', '90 min']) {
        expect(Event(eventId: 'e', durata: text).effectiveDurationMinutes, 90, reason: text);
      }
      expect(Event(eventId: 'e', durata: 'o după-amiază').effectiveDurationMinutes, isNull);
      expect(Event(eventId: 'e').effectiveDurationMinutes, isNull);
    });

    test('difficulty', () {
      expect(Event(eventId: 'e', difficulty: Difficulty.hard, dificultate: 'Ușoară').effectiveDifficulty, Difficulty.hard);
      expect(Event(eventId: 'e', dificultate: 'Ușoară').effectiveDifficulty, Difficulty.easy);
      expect(Event(eventId: 'e', dificultate: 'usor').effectiveDifficulty, Difficulty.easy);
      expect(Event(eventId: 'e', dificultate: 'Medie').effectiveDifficulty, Difficulty.medium);
      expect(Event(eventId: 'e', dificultate: 'Grea').effectiveDifficulty, Difficulty.hard);
      expect(Event(eventId: 'e', dificultate: 'Dificilă').effectiveDifficulty, Difficulty.hard);
      expect(Event(eventId: 'e', dificultate: '?').effectiveDifficulty, isNull);
    });

    test('story falls back to the description', () {
      expect(Event(eventId: 'e', story: 'Poveste', description: 'Scurt').storyText, 'Poveste');
      expect(Event(eventId: 'e', story: '  ', description: 'Scurt').storyText, 'Scurt');
      expect(Event(eventId: 'e').storyText, '');
    });

    test('a start pin needs both coordinates', () {
      expect(Event(eventId: 'e', startLatitude: 45, startLongitude: 24).hasStartPin, isTrue);
      expect(Event(eventId: 'e', startLatitude: 45).hasStartPin, isFalse);
    });
  });

  test('an unknown difficulty name reads as null', () {
    expect(Difficulty.fromName('nope'), isNull);
    expect(Difficulty.fromName(null), isNull);
    expect(Difficulty.fromName('medium'), Difficulty.medium);
  });
}
