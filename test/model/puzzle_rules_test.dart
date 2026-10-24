import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/model/puzzle.dart';

void main() {
  test('a puzzle without a wrong answer message has none and writes none', () {
    final puzzle = Puzzle(id: '0', type: PuzzleType.code, code: 'A');
    expect(puzzle.wrongAnswerMessage, isNull);
    expect(puzzle.toJson().containsKey('wrongAnswerMessage'), isFalse);
  });

  test('the wrong answer message is written and read back', () {
    final puzzle = Puzzle(id: '0', type: PuzzleType.code, wrongAnswerMessage: 'Mai încearcă');
    expect(Puzzle.fromMap(puzzle.toJson()).wrongAnswerMessage, 'Mai încearcă');
  });

  test('old puzzles saved before it existed still load', () {
    final puzzle = Puzzle.fromMap({'id': '3', 'type': 'code', 'code': 'A'});
    expect(puzzle.wrongAnswerMessage, isNull);
  });

  test('renumbering a puzzle keeps its message', () {
    final moved = Puzzle(id: '0', wrongAnswerMessage: 'x').withId('4');
    expect(moved.id, '4');
    expect(moved.wrongAnswerMessage, 'x');
  });
}
