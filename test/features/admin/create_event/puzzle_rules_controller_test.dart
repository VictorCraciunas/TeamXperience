import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/puzzle_rules/puzzle_rules_controller.dart';
import 'package:teamxperience/model/puzzle.dart';

PuzzleRulesController _controller(Puzzle puzzle) => PuzzleRulesController(puzzle);

void main() {
  group('loading', () {
    test('the fields start from the puzzle', () {
      final c = _controller(
        Puzzle(
          id: '0',
          type: PuzzleType.code,
          code: 'XTREME',
          indiciu: 'Uită-te în sus',
          wrongAnswerMessage: 'Aproape',
        ),
      );
      expect(c.answerController.text, 'XTREME');
      expect(c.hintController.text, 'Uită-te în sus');
      expect(c.messageController.text, 'Aproape');
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
      final puzzle = Puzzle(id: '0', type: PuzzleType.code, code: 'A', indiciu: 'x', wrongAnswerMessage: 'y');
      final c = _controller(puzzle)
        ..answerController.text = '  '
        ..hintController.text = ''
        ..messageController.text = ' ';
      c.apply();
      expect(puzzle.code, isNull);
      expect(puzzle.indiciu, isNull);
      expect(puzzle.wrongAnswerMessage, isNull);
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
