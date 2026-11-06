import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/finish/logic/finish_recap.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/team.dart';

final _start = DateTime(2026, 11, 14, 10);

Event _event({String? title, String? message}) => Event(
      eventId: 'e1',
      name: 'Moștenirea Cartografului',
      dateEvent: _start,
      finishTitle: title,
      finishMessage: message,
      missions: [for (var i = 0; i < 6; i++) Mission(id: '$i')],
    );

Team _team({
  int progress = 6,
  DateTime? startedAt,
  DateTime? finishedAt,
  Map<int, DateTime>? completed,
  Map<String, bool>? hints,
  Map<String, dynamic>? photos,
}) =>
    Team.fromMap({
      'name': 'Vulpile',
      'missionProgress': progress,
      if (startedAt != null) 'startedAt': Timestamp.fromDate(startedAt),
      if (finishedAt != null) 'finishedAt': Timestamp.fromDate(finishedAt),
      if (completed != null) 'missionCompletedAt': {for (final e in completed.entries) '${e.key}': Timestamp.fromDate(e.value)},
      if (hints != null) 'hintsUsed': hints,
      if (photos != null) 'photoApprovals': photos,
    });

void main() {
  group('finishTexts', () {
    test('a complete route without the organiser\'s words', () {
      final texts = finishTexts(_event(), _team());
      expect(texts.title, 'Ați terminat traseul!');
      expect(texts.message, 'Vulpile a rezolvat toate cele 6 misiuni.');
    });

    test('the event ended first', () {
      final texts = finishTexts(_event(title: 'Harta e completă'), _team(progress: 3));
      expect(texts.title, 'Jocul s-a încheiat');
      expect(texts.message, 'Vulpile a rezolvat 3 din 6 misiuni.');
    });

    test('the organiser may name the team with {team}', () {
      final texts = finishTexts(_event(message: '{team} au moștenit secretul.'), _team());
      expect(texts.message, 'Vulpile au moștenit secretul.');
    });

    test('the organiser\'s words win for a complete route; blank ones do not', () {
      final texts = finishTexts(_event(title: ' Harta e completă ', message: 'Ați moștenit secretul.'), _team());
      expect((texts.title, texts.message), ('Harta e completă', 'Ați moștenit secretul.'));
      expect(finishTexts(_event(title: '  ', message: ''), _team()).title, 'Ați terminat traseul!');
    });

    test('a route is complete only with every mission solved', () {
      expect(routeCompleted(_event(), _team()), isTrue);
      expect(routeCompleted(_event(), _team(progress: 5)), isFalse);
      expect(routeCompleted(Event(eventId: 'e'), _team(progress: 0)), isFalse);
    });
  });

  test('the place label', () {
    expect(placeLabel(12), 'din 12 echipe');
    expect(placeLabel(1), 'din 1 echipă');
  });

  group('playedTime', () {
    test('from the team\'s start to its finish', () {
      final team = _team(startedAt: _start.add(const Duration(minutes: 2)), finishedAt: _start.add(const Duration(minutes: 110)));
      expect(hoursMinutes(playedTime(_event(), team, _start.add(const Duration(hours: 5)))), '1:48');
    });

    test('a partial result runs to now, but never past the three hours', () {
      final team = _team(progress: 3, startedAt: _start);
      expect(playedTime(_event(), team, _start.add(const Duration(minutes: 75))), const Duration(minutes: 75));
      expect(playedTime(_event(), team, _start.add(const Duration(hours: 5))), const Duration(hours: 3));
    });

    test('a complete route without its finish time ends at its last mission', () {
      final team = _team(startedAt: _start, completed: {5: _start.add(const Duration(minutes: 108))});
      expect(playedTime(_event(), team, _start.add(const Duration(hours: 5))), const Duration(minutes: 108));
    });

    test('no start at all, or a finish before the start: zero', () {
      expect(playedTime(Event(eventId: 'e'), _team(progress: 3), _start), Duration.zero);
      expect(hoursMinutes(const Duration(minutes: -5)), '0:00');
    });
  });

  test('km with one decimal and a comma', () {
    expect(kmLabel(4712), '4,7');
    expect(kmLabel(0), '0,0');
  });

  group('fastestMission', () {
    test('each mission from the previous one, the first from the start', () {
      final team = _team(startedAt: _start, completed: {
        0: _start.add(const Duration(minutes: 20)),
        1: _start.add(const Duration(minutes: 26)),
        2: _start.add(const Duration(minutes: 40)),
      });
      final fastest = fastestMission(team);
      expect(fastest, (mission: 2, minutes: 6));
      expect(fastestLine((mission: 2, minutes: 6)), 'Cea mai rapidă: misiunea 2 (6 min)');
    });

    test('nothing to measure: none', () {
      expect(fastestMission(_team()), isNull);
      expect(fastestMission(_team(completed: {1: _start})), isNull, reason: 'no start, no earlier mission');
    });

    test('under a minute reads as 1 min', () {
      final team = _team(startedAt: _start, completed: {0: _start.add(const Duration(seconds: 20))});
      expect(fastestMission(team), (mission: 1, minutes: 1));
    });
  });

  test('the hints label', () {
    expect(hintsLabel(_team(hints: {'0_0': true, '2_1': true})), '2 indicii');
    expect(hintsLabel(_team(hints: {'0_0': true})), '1 indiciu');
    expect(hintsLabel(_team()), 'fără indicii');
  });

  test('approved photos with a picture, in mission order', () {
    final team = _team(photos: {
      '3_0_1': {'status': 'approved', 'url': 'https://x/3.jpg'},
      '1_0_5': {'status': 'approved', 'url': 'https://x/1.jpg'},
      '1_0_2': {'status': 'denied', 'url': 'https://x/bad.jpg'},
      '2_0_1': {'status': 'pending', 'url': 'https://x/wait.jpg'},
      '4_0_1': 'approved',
    });
    expect(approvedPhotos(team), ['https://x/1.jpg', 'https://x/3.jpg']);
  });

  test('the share line', () {
    expect(
      shareLine(_event(), _team(), (place: 2, teams: 12), const Duration(minutes: 108), 4712),
      'Vulpile a terminat „Moștenirea Cartografului” pe locul 2 din 12, în 1:48 și 4,7 km. #TeamXperience',
    );
    expect(
      shareLine(_event(), _team(), null, const Duration(minutes: 108), 4712),
      'Vulpile a terminat „Moștenirea Cartografului” în 1:48 și 4,7 km. #TeamXperience',
    );
  });
}
