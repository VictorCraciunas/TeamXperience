import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/model/puzzle.dart';

void main() {
  test('a puzzle without rules has none and writes none', () {
    final puzzle = Puzzle(id: '0', type: PuzzleType.code, code: 'A');
    expect(puzzle.maxAttempts, isNull);
    expect(puzzle.wrongAnswerMessage, isNull);

    final json = puzzle.toJson();
    expect(json.containsKey('maxAttempts'), isFalse);
    expect(json.containsKey('wrongAnswerMessage'), isFalse);
  });

  test('rules are written and read back', () {
    final puzzle = Puzzle(
      id: '0',
      type: PuzzleType.code,
      maxAttempts: 5,
      wrongAnswerMessage: 'Mai încearcă',
    );
    final back = Puzzle.fromMap(puzzle.toJson());
    expect(back.maxAttempts, 5);
    expect(back.wrongAnswerMessage, 'Mai încearcă');
  });

  test('old puzzles saved before the rules existed still load', () {
    final puzzle = Puzzle.fromMap({'id': '3', 'type': 'code', 'code': 'A'});
    expect(puzzle.maxAttempts, isNull);
  });

  test('numbers saved as doubles are read as whole numbers', () {
    final puzzle = Puzzle.fromMap({'id': '0', 'maxAttempts': 3.0});
    expect(puzzle.maxAttempts, 3);
  });

  test('renumbering a puzzle keeps its rules', () {
    final puzzle = Puzzle(id: '0', maxAttempts: 3, wrongAnswerMessage: 'x');
    final moved = puzzle.withId('4');
    expect(moved.id, '4');
    expect(moved.maxAttempts, 3);
    expect(moved.wrongAnswerMessage, 'x');
  });
}
