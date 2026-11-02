import 'dart:math' as math;

import 'package:flutter/material.dart';

/// What the player's answer turned out to be.
enum AnswerResult { wrong, correct }

/// Tells a code input that an answer was checked, so it can react. The game
/// calls [wrong] or [correct]; the input listens.
class AnswerFeedback extends ChangeNotifier {
  AnswerResult? _last;
  int _count = 0;

  /// The last answer, or null before the first one.
  AnswerResult? get last => _last;

  /// How many answers were checked, so the same result twice can be told apart.
  int get count => _count;

  void wrong() => _tell(AnswerResult.wrong);

  void correct() => _tell(AnswerResult.correct);

  void _tell(AnswerResult result) {
    _last = result;
    _count++;
    notifyListeners();
  }
}

/// How a code input is drawn at one moment of its reaction: moved sideways,
/// made bigger, and tinted ([flash] from 0 to 1).
class AnswerFrame {
  const AnswerFrame({this.dx = 0, this.scale = 1, this.flash = 0});

  final double dx;
  final double scale;
  final double flash;
}

/// How long the reaction to [result] lasts.
Duration answerDuration(AnswerResult result) {
  return switch (result) {
    AnswerResult.wrong => const Duration(milliseconds: 700),
    AnswerResult.correct => const Duration(milliseconds: 600),
  };
}

/// The colour the input is tinted with.
Color answerFrameColor(AnswerResult result) {
  return switch (result) {
    AnswerResult.wrong => const Color(0xFFFF4D4D),
    AnswerResult.correct => const Color(0xFF33FF66),
  };
}

/// The frame of the reaction to [result] at [progress] (0 = just checked,
/// 1 = over). It starts and ends neutral: in place, full size, no tint.
AnswerFrame answerFrame(AnswerResult result, double progress) {
  final t = progress.clamp(0.0, 1.0);
  // Exactly 0 at both ends, not a tiny number left over from the sine.
  final flash = (t == 0 || t == 1) ? 0.0 : math.sin(math.pi * t);

  return switch (result) {
    // A shake that dies down, three times left and right.
    AnswerResult.wrong => AnswerFrame(dx: 9 * (1 - t) * math.sin(2 * math.pi * 3 * t), flash: flash),
    // A pop: a little bigger and back.
    AnswerResult.correct => AnswerFrame(scale: 1 + 0.12 * math.sin(math.pi * t), flash: flash),
  };
}
