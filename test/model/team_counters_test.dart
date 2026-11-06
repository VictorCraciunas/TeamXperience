import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/model/team.dart';

Map<String, dynamic> _base() => {'name': 'Vulpile'};

void main() {
  test('the puzzle key is mission and puzzle', () {
    expect(Team.puzzleKey(3, 0), '3_0');
  });

  test('attempts read whole numbers and skip anything else', () {
    final team = Team.fromMap({
      ..._base(),
      'attempts': {'3_0': 2, '3_1': 1.0, '2_0': null, '1_0': 'doi'},
    });
    expect(team.attempts, {'3_0': 2, '3_1': 1});
  });

  test('hints used read true values only', () {
    final team = Team.fromMap({
      ..._base(),
      'hintsUsed': {'3_0': true, '3_1': false, '2_0': null},
    });
    expect(team.hintsUsed, {'3_0': true});
  });

  test('locks read times and skip a pending or bad value', () {
    final until = DateTime(2026, 11, 14, 10, 30);
    final team = Team.fromMap({
      ..._base(),
      'lockedUntil': {'3_0': Timestamp.fromDate(until), '3_1': null, '2_0': 'mâine'},
    });
    expect(team.lockedUntil, {'3_0': until});
  });

  test('missing maps read empty', () {
    final team = Team.fromMap(_base());
    expect(team.attempts, isEmpty);
    expect(team.hintsUsed, isEmpty);
    expect(team.lockedUntil, isEmpty);
  });

  test('the counters are never written by toJson', () {
    final team = Team.fromMap({
      ..._base(),
      'attempts': {'3_0': 2},
      'hintsUsed': {'3_0': true},
      'lockedUntil': {'3_0': Timestamp.now()},
    });
    final json = team.toJson();
    expect(json.containsKey('attempts'), isFalse);
    expect(json.containsKey('hintsUsed'), isFalse);
    expect(json.containsKey('lockedUntil'), isFalse);
  });
}
