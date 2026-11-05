import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/model/team.dart';

Map<String, dynamic> _base() => {
      'name': 'Vulpile',
      'teamMembers': '',
      'captainName': 'Victor',
      'phoneNumber': '',
      'captainEmail': '',
    };

void main() {
  final t = DateTime(2026, 11, 14, 11, 5);
  final a = DateTime(2026, 11, 14, 10, 20);
  final b = DateTime(2026, 11, 14, 10, 50);

  test('reads presence and mission times from Timestamps', () {
    final team = Team.fromMap({
      ..._base(),
      'presence': {'u1': Timestamp.fromDate(t)},
      'missionCompletedAt': {'0': Timestamp.fromDate(a), '2': Timestamp.fromDate(b)},
    });
    expect(team.presence, {'u1': t});
    expect(team.missionCompletedAt, {0: a, 2: b});
    expect(team.lastMissionAt, b);
  });

  test('skips pending and malformed values', () {
    final team = Team.fromMap({
      ..._base(),
      'presence': {'u1': null, 'u2': 'x'},
      'missionCompletedAt': {'x': Timestamp.now(), '1': null},
    });
    expect(team.presence, isEmpty);
    expect(team.missionCompletedAt, isEmpty);
    expect(team.lastMissionAt, isNull);
  });

  test('old documents load with empty maps', () {
    final team = Team.fromMap(_base());
    expect(team.presence, isEmpty);
    expect(team.missionCompletedAt, isEmpty);
    expect(team.lastMissionAt, isNull);
  });

  test('toJson does not write presence or mission times', () {
    final json = Team.fromMap({
      ..._base(),
      'presence': {'u1': Timestamp.fromDate(t)},
      'missionCompletedAt': {'0': Timestamp.fromDate(a)},
    }).toJson();
    expect(json.containsKey('presence'), isFalse);
    expect(json.containsKey('missionCompletedAt'), isFalse);
  });
}
