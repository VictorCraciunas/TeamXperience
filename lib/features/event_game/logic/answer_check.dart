import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/puzzle.dart';

/// Whether what the player typed is the answer. Capitals and spaces around it
/// do not matter.
bool isCorrectAnswer(String input, String? answer) {
  return input.trim().toLowerCase() == (answer ?? '').trim().toLowerCase();
}

/// Whether the code input of [puzzle] reacts to an answer (a shake when wrong,
/// a pop when right). It does unless every code input has it switched off.
bool feedbackEnabled(Puzzle puzzle) {
  return puzzle.components.where((c) => c.type == ComponentType.code).any((c) => c.answerFeedback != false);
}

/// How long to wait after a right answer before going on, so the pop can be
/// seen. No wait when the reaction is off, so the game is as quick as before.
Duration pauseAfterCorrectAnswer(Puzzle puzzle) {
  return feedbackEnabled(puzzle) ? const Duration(milliseconds: 600) : Duration.zero;
}
