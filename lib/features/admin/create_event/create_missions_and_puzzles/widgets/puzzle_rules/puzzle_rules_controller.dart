import 'package:flutter/material.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/model/puzzle.dart';

/// Holds the "Reguli" form of one puzzle: the answer, the hint, how many
/// attempts players get and what they are told when they are wrong.
class PuzzleRulesController {
  PuzzleRulesController(this.puzzle) {
    answerController.text = puzzle.code ?? '';
    latitudeController.text = puzzle.latitude?.toString() ?? '';
    longitudeController.text = puzzle.longitude?.toString() ?? '';
    hintController.text = puzzle.indiciu ?? '';
    messageController.text = puzzle.wrongAnswerMessage ?? '';
    maxAttempts = puzzle.maxAttempts;
  }

  final Puzzle puzzle;

  final answerController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final hintController = TextEditingController();
  final messageController = TextEditingController();

  /// Null means unlimited.
  int? maxAttempts;

  /// The attempts offered; null is "Nelimitat".
  static const attemptChoices = <int?>[3, 5, null];

  String? _text(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  double? _number(TextEditingController controller) {
    final value = _text(controller);
    return value == null ? null : double.tryParse(value.replaceAll(',', '.'));
  }

  String? _coordinateError(TextEditingController controller, double limit, String name) {
    if (_text(controller) == null) return null;

    final value = _number(controller);
    if (value == null) return 'Introdu un număr';
    if (value < -limit || value > limit) {
      return '$name trebuie să fie între -${limit.toInt()} și ${limit.toInt()}';
    }
    return null;
  }

  String? get latitudeError => _coordinateError(latitudeController, 90, 'Latitudinea');
  String? get longitudeError => _coordinateError(longitudeController, 180, 'Longitudinea');

  /// Writes the form onto the puzzle.
  void apply() {
    final type = puzzle.type;

    puzzle.code = type == PuzzleType.code ? _text(answerController) : null;
    puzzle.wrongAnswerMessage = _text(messageController);
    puzzle.indiciu = _text(hintController);
    puzzle.maxAttempts = maxAttempts;

    if (type == PuzzleType.geolocation) {
      puzzle.latitude = latitudeError == null ? _number(latitudeController) : null;
      puzzle.longitude = longitudeError == null ? _number(longitudeController) : null;
    }
  }

  void dispose() {
    answerController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    hintController.dispose();
    messageController.dispose();
  }
}
