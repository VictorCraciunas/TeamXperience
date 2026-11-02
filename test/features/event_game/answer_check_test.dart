import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/event_game/logic/answer_check.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/puzzle.dart';

Puzzle _puzzle(List<Component> components) => Puzzle(id: '0', type: PuzzleType.code, code: 'ZERODAY', components: components);

void main() {
  group('is the answer right', () {
    test('the same text is right', () {
      expect(isCorrectAnswer('ZERODAY', 'ZERODAY'), isTrue);
    });

    test('capitals do not matter', () {
      expect(isCorrectAnswer('zeroday', 'ZERODAY'), isTrue);
      expect(isCorrectAnswer('ZeroDay', 'zeroDAY'), isTrue);
    });

    test('spaces around it do not matter', () {
      expect(isCorrectAnswer('  zeroday ', 'ZERODAY'), isTrue);
      expect(isCorrectAnswer('ZERODAY', ' ZERODAY  '), isTrue);
    });

    test('another text is wrong', () {
      expect(isCorrectAnswer('ZERODA', 'ZERODAY'), isFalse);
      expect(isCorrectAnswer('ZERO DAY', 'ZERODAY'), isFalse);
      expect(isCorrectAnswer('', 'ZERODAY'), isFalse);
    });

    test('a puzzle without an answer takes an empty input, as it always did', () {
      expect(isCorrectAnswer('', null), isTrue);
      expect(isCorrectAnswer('x', null), isFalse);
    });
  });

  group('the answer feedback of a puzzle', () {
    test('is on when the code input says nothing about it', () {
      expect(feedbackEnabled(_puzzle([Component(type: ComponentType.code)])), isTrue);
    });

    test('is on when asked for', () {
      expect(feedbackEnabled(_puzzle([Component(type: ComponentType.code, answerFeedback: true)])), isTrue);
    });

    test('is off when every code input has it off', () {
      expect(feedbackEnabled(_puzzle([Component(type: ComponentType.code, answerFeedback: false)])), isFalse);
    });

    test('is on if one of two code inputs has it on', () {
      final puzzle = _puzzle([
        Component(type: ComponentType.code, answerFeedback: false),
        Component(type: ComponentType.code),
      ]);
      expect(feedbackEnabled(puzzle), isTrue);
    });

    test('is off for a puzzle with no code input', () {
      expect(feedbackEnabled(_puzzle([Component(type: ComponentType.text)])), isFalse);
      expect(feedbackEnabled(_puzzle([])), isFalse);
    });

    test('other components do not count', () {
      final puzzle = _puzzle([
        Component(type: ComponentType.button, answerFeedback: true),
        Component(type: ComponentType.code, answerFeedback: false),
      ]);
      expect(feedbackEnabled(puzzle), isFalse);
    });
  });

  group('the pause after a right answer', () {
    test('lets the green pop be seen when the feedback is on', () {
      final pause = pauseAfterCorrectAnswer(_puzzle([Component(type: ComponentType.code)]));
      expect(pause.inMilliseconds, inInclusiveRange(400, 900));
    });

    test('is none when the feedback is off, so the game is as quick as before', () {
      expect(pauseAfterCorrectAnswer(_puzzle([Component(type: ComponentType.code, answerFeedback: false)])), Duration.zero);
    });
  });
}
