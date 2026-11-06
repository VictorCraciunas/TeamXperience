import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';

void main() {
  test('a mission keeps its place', () {
    final mission = Mission(id: '0', title: 'Podul Minciunilor', latitude: 45.7983, longitude: 24.1522);
    final back = Mission.fromMap(mission.toJson());
    expect(back.latitude, 45.7983);
    expect(back.longitude, 24.1522);
  });

  test('a mission without a place writes none and reads none', () {
    final json = Mission(id: '0').toJson();
    expect(json.containsKey('latitude'), isFalse);
    expect(json.containsKey('longitude'), isFalse);
    expect(Mission.fromMap({'id': '0', 'latitude': 45}).latitude, 45.0);
    expect(Mission.fromMap({'id': '0'}).latitude, isNull);
  });

  test('withId keeps the place', () {
    final mission = Mission(id: '0', latitude: 1, longitude: 2).withId('3');
    expect((mission.latitude, mission.longitude), (1.0, 2.0));
  });

  test('a puzzle keeps its attempt limit and wrong-answer line', () {
    final puzzle = Puzzle(
      id: '0',
      type: PuzzleType.code,
      maxAttempts: 3,
      wrongAnswerMessage: 'Nu e anul ăsta.',
    );
    final back = Puzzle.fromMap(puzzle.toJson());
    expect(back.maxAttempts, 3);
    expect(back.wrongAnswerMessage, 'Nu e anul ăsta.');
    expect(puzzle.withId('1').maxAttempts, 3);
    expect(puzzle.withId('1').wrongAnswerMessage, 'Nu e anul ăsta.');
  });

  test('no limit and no line by default, and nothing is written for them', () {
    final puzzle = Puzzle(id: '0');
    expect(puzzle.maxAttempts, isNull);
    expect(puzzle.wrongAnswerMessage, isNull);
    final json = puzzle.toJson();
    expect(json.containsKey('maxAttempts'), isFalse);
    expect(json.containsKey('wrongAnswerMessage'), isFalse);
  });

  test('a limit below one reads as no limit', () {
    expect(Puzzle.fromMap({'id': '0', 'maxAttempts': 0}).maxAttempts, isNull);
    expect(Puzzle.fromMap({'id': '0', 'maxAttempts': -2}).maxAttempts, isNull);
    expect(Puzzle.fromMap({'id': '0', 'maxAttempts': 'trei'}).maxAttempts, isNull);
  });
}
