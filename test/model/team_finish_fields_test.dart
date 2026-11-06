import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

Map<String, dynamic> _base() => {'name': 'Vulpile'};

void main() {
  group('Team.finishedAt', () {
    test('read from a Timestamp, null while pending or missing', () {
      final at = DateTime(2026, 11, 14, 11, 48);
      expect(Team.fromMap({..._base(), 'finishedAt': Timestamp.fromDate(at)}).finishedAt, at);
      expect(Team.fromMap({..._base(), 'finishedAt': null}).finishedAt, isNull);
      expect(Team.fromMap(_base()).finishedAt, isNull);
    });

    test('never written by toJson', () {
      expect(Team.fromMap({..._base(), 'finishedAt': Timestamp.now()}).toJson().containsKey('finishedAt'), isFalse);
    });
  });

  group('the walk', () {
    test('the team walked as far as its longest walk; odd values skipped', () {
      final team = Team.fromMap({
        ..._base(),
        'walked': {'a': 1200, 'b': 1250.5, 'c': 'x', 'd': null},
      });
      expect(team.walked, {'a': 1200.0, 'b': 1250.5});
      expect(team.distanceMeters, 1250.5);
    });

    test('no walk: 0, and never written by toJson', () {
      expect(Team.fromMap(_base()).distanceMeters, 0);
      expect(Team.fromMap({..._base(), 'walked': {'a': 5}}).toJson().containsKey('walked'), isFalse);
    });
  });

  test('the organiser\'s end texts round-trip', () {
    final event = Event(eventId: 'e1', finishTitle: 'Harta e completă', finishMessage: 'Vulpile au moștenit secretul.');
    final back = Event.fromMap({...event.toJson(), 'dateEvent': null});
    expect(back.finishTitle, 'Harta e completă');
    expect(back.finishMessage, 'Vulpile au moștenit secretul.');
    expect(Event.fromMap({'eventId': 'e1'}).finishTitle, isNull);
  });
}
