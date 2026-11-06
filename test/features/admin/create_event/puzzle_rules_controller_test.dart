import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/puzzle_rules/puzzle_rules_controller.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/puzzle.dart';

PuzzleRulesController _controller(Puzzle puzzle) => PuzzleRulesController(puzzle);

void main() {
  changeTypeTests();
  group('loading', () {
    test('the fields start from the puzzle', () {
      final c = _controller(
        Puzzle(
          id: '0',
          type: PuzzleType.code,
          code: 'XTREME',
          indiciu: 'Uită-te în sus',
        ),
      );
      expect(c.answerController.text, 'XTREME');
      expect(c.hintController.text, 'Uită-te în sus');
    });

    test('an empty puzzle gives empty fields', () {
      final c = _controller(Puzzle(id: '0', type: PuzzleType.code));
      expect(c.answerController.text, '');
      expect(c.latitudeController.text, '');
    });
  });

  group('apply', () {
    test('writes the answer and hint trimmed', () {
      final puzzle = Puzzle(id: '0', type: PuzzleType.code);
      final c = _controller(puzzle)
        ..answerController.text = '  ABC  '
        ..hintController.text = '  sus  ';
      c.apply();
      expect(puzzle.code, 'ABC');
      expect(puzzle.indiciu, 'sus');
    });

    test('empty text clears the field instead of keeping an empty string', () {
      final puzzle = Puzzle(id: '0', type: PuzzleType.code, code: 'A', indiciu: 'x');
      final c = _controller(puzzle)
        ..answerController.text = '  '
        ..hintController.text = '';
      c.apply();
      expect(puzzle.code, isNull);
      expect(puzzle.indiciu, isNull);
    });

    test('the answer is only kept for a code puzzle', () {
      final puzzle = Puzzle(id: '0', type: PuzzleType.imageToUpload);
      final c = _controller(puzzle)..answerController.text = 'ABC';
      c.apply();
      expect(puzzle.code, isNull);
    });

    test('a location puzzle takes the coordinates, with a comma or a dot', () {
      final puzzle = Puzzle(id: '0', type: PuzzleType.geolocation);
      final c = _controller(puzzle)
        ..latitudeController.text = '45,7833'
        ..longitudeController.text = ' 24.15 ';
      c.apply();
      expect(puzzle.latitude, 45.7833);
      expect(puzzle.longitude, 24.15);
    });

    test('coordinates that are not numbers are left empty', () {
      final puzzle = Puzzle(id: '0', type: PuzzleType.geolocation, latitude: 1, longitude: 2);
      final c = _controller(puzzle)
        ..latitudeController.text = 'abc'
        ..longitudeController.text = '';
      c.apply();
      expect(puzzle.latitude, isNull);
      expect(puzzle.longitude, isNull);
    });

  });

  group('attempts and the wrong-answer line', () {
    test('load from the puzzle', () {
      final c = _controller(Puzzle(id: '0', type: PuzzleType.code, maxAttempts: 3, wrongAnswerMessage: 'Nu e anul ăsta.'));
      expect(c.maxAttemptsController.text, '3');
      expect(c.wrongAnswerController.text, 'Nu e anul ăsta.');
    });

    test('are written onto a code puzzle', () {
      final puzzle = Puzzle(id: '0', type: PuzzleType.code);
      _controller(puzzle)
        ..maxAttemptsController.text = ' 3 '
        ..wrongAnswerController.text = ' Mai sus pe ușă. '
        ..apply();
      expect(puzzle.maxAttempts, 3);
      expect(puzzle.wrongAnswerMessage, 'Mai sus pe ușă.');
    });

    test('empty means unlimited and the default line', () {
      final puzzle = Puzzle(id: '0', type: PuzzleType.code, maxAttempts: 3, wrongAnswerMessage: 'x');
      _controller(puzzle)
        ..maxAttemptsController.text = ''
        ..wrongAnswerController.text = '  '
        ..apply();
      expect(puzzle.maxAttempts, isNull);
      expect(puzzle.wrongAnswerMessage, isNull);
    });

    test('a limit outside 1 to 20 is an error and is not kept', () {
      final puzzle = Puzzle(id: '0', type: PuzzleType.code);
      final c = _controller(puzzle);
      for (final text in ['0', '21', 'trei', '2.5']) {
        c.maxAttemptsController.text = text;
        expect(c.maxAttemptsError, isNotNull, reason: text);
        c.apply();
        expect(puzzle.maxAttempts, isNull, reason: text);
      }
      c.maxAttemptsController.text = '';
      expect(c.maxAttemptsError, isNull);
    });

    test('only a code puzzle keeps them', () {
      final puzzle = Puzzle(id: '0', type: PuzzleType.imageToUpload);
      _controller(puzzle)
        ..maxAttemptsController.text = '3'
        ..wrongAnswerController.text = 'x'
        ..apply();
      expect(puzzle.maxAttempts, isNull);
      expect(puzzle.wrongAnswerMessage, isNull);
    });
  });

  group('coordinate checks', () {
    test('nothing typed is not an error yet', () {
      final c = _controller(Puzzle(id: '0', type: PuzzleType.geolocation));
      expect(c.latitudeError, isNull);
      expect(c.longitudeError, isNull);
    });

    test('text that is not a number is an error', () {
      final c = _controller(Puzzle(id: '0', type: PuzzleType.geolocation))
        ..latitudeController.text = 'abc';
      expect(c.latitudeError, isNotNull);
    });

    test('latitude is limited to 90 and longitude to 180', () {
      final c = _controller(Puzzle(id: '0', type: PuzzleType.geolocation))
        ..latitudeController.text = '91'
        ..longitudeController.text = '181';
      expect(c.latitudeError, isNotNull);
      expect(c.longitudeError, isNotNull);

      c
        ..latitudeController.text = '-90'
        ..longitudeController.text = '-180';
      expect(c.latitudeError, isNull);
      expect(c.longitudeError, isNull);
    });
  });
}

void changeTypeTests() {
  group('changing the type', () {
    Puzzle filled() => Puzzle(
          id: '0',
          type: PuzzleType.code,
          code: 'ABC',
          latitude: 45,
          longitude: 24,
          indiciu: 'sus',
        )..components.add(Component());

    test('the new type is set and the answer, place and hint are cleared', () {
      final puzzle = filled();
      final c = _controller(puzzle);
      c.changeType(PuzzleType.geolocation);
      expect(puzzle.type, PuzzleType.geolocation);
      expect(puzzle.code, isNull);
      expect(puzzle.latitude, isNull);
      expect(puzzle.longitude, isNull);
      expect(puzzle.indiciu, isNull);
    });

    test('the attempt limit and wrong-answer line are cleared too', () {
      final puzzle = filled()
        ..maxAttempts = 3
        ..wrongAnswerMessage = 'x';
      final c = _controller(puzzle)..changeType(PuzzleType.geolocation);
      expect(puzzle.maxAttempts, isNull);
      expect(puzzle.wrongAnswerMessage, isNull);
      expect(c.maxAttemptsController.text, '');
      expect(c.wrongAnswerController.text, '');
    });

    test('the form fields are emptied too', () {
      final c = _controller(filled());
      c.changeType(PuzzleType.imageToUpload);
      expect(c.answerController.text, '');
      expect(c.latitudeController.text, '');
      expect(c.longitudeController.text, '');
      expect(c.hintController.text, '');
    });

    test('what is on the puzzle screen is kept', () {
      final puzzle = filled();
      _controller(puzzle).changeType(PuzzleType.redirect);
      expect(puzzle.components, hasLength(1));
    });

    test('choosing the same type changes nothing', () {
      final puzzle = filled();
      _controller(puzzle).changeType(PuzzleType.code);
      expect(puzzle.code, 'ABC');
      expect(puzzle.indiciu, 'sus');
    });

    test('applying after a change does not bring the old answer back', () {
      final puzzle = filled();
      final c = _controller(puzzle)..changeType(PuzzleType.geolocation);
      c.apply();
      expect(puzzle.code, isNull);
      expect(puzzle.indiciu, isNull);
    });

    test('it knows when a change would lose something', () {
      expect(_controller(filled()).hasDataToLose, isTrue);
      expect(_controller(Puzzle(id: '0', type: PuzzleType.code)).hasDataToLose, isFalse);
      expect(_controller(Puzzle(id: '0', type: PuzzleType.code, indiciu: 'x')).hasDataToLose, isTrue);
      expect(_controller(Puzzle(id: '0', type: PuzzleType.code)..latitude = 1).hasDataToLose, isTrue);
    });

    test('a puzzle with no type can get one without losing anything', () {
      final puzzle = Puzzle(id: '0');
      final c = _controller(puzzle);
      expect(c.hasDataToLose, isFalse);
      c.changeType(PuzzleType.code);
      expect(puzzle.type, PuzzleType.code);
    });
  });
}
