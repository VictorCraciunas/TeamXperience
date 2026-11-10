import 'package:flutter/foundation.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/model/team.dart';

import 'puzzle_rules.dart' as rules;

/// What a wrong answer did.
enum WrongResult {
  /// Counted; the puzzle still takes answers.
  counted,

  /// That was the last attempt: the puzzle is locked for [rules.puzzleLock].
  outOfAttempts,

  /// The puzzle is locked; the answer was not counted.
  locked,
}

/// Keeps a team's attempts, locks and hints for the open puzzle: counts here
/// at once (so the frame updates without waiting for the network) and sends
/// each change to the team doc, where teammates' phones add up. Writes that
/// fail are dropped; the local count stays.
class PuzzleRulesKeeper {
  PuzzleRulesKeeper({
    required this.team,
    required this.addWrongAttempt,
    required this.lockPuzzle,
    required this.markHintUsed,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final Team team;
  final Future<void> Function(String key) addWrongAttempt;
  final Future<void> Function(String key, DateTime until) lockPuzzle;
  final Future<void> Function(String key) markHintUsed;
  final DateTime Function() _clock;

  /// Ticks on every change of the counts, locks or hints.
  final ValueNotifier<int> changes = ValueNotifier(0);

  void _changed() => changes.value++;

  static void _send(Future<void> Function() write) {
    try {
      write().catchError((Object _) {});
    } catch (_) {}
  }

  Duration? lockLeft(String key) => rules.lockLeft(team, key, _clock());

  bool isLocked(String key) => lockLeft(key) != null;

  /// Counts a wrong answer on [puzzle] ([key] = `Team.puzzleKey`).
  WrongResult wrong(Puzzle puzzle, String key) {
    if (isLocked(key)) return WrongResult.locked;
    final used = (team.attempts[key] ?? 0) + 1;
    team.attempts[key] = used;
    _send(() => addWrongAttempt(key));

    final max = puzzle.maxAttempts;
    if (max != null && used >= max) {
      _lock(key);
      _changed();
      return WrongResult.outOfAttempts;
    }
    _changed();
    return WrongResult.counted;
  }

  /// Locks [key] for a minute here and on the team doc; its count starts over.
  void _lock(String key) {
    final until = _clock().add(rules.puzzleLock);
    team.lockedUntil[key] = until;
    team.attempts[key] = 0;
    _send(() => lockPuzzle(key, until));
  }

  /// Notes that the team opened the hint of [key]; only the first time is sent.
  Future<void> useHint(String key) async {
    if (team.hintsUsed[key] == true) return;
    team.hintsUsed[key] = true;
    _changed();
    try {
      await markHintUsed(key);
    } catch (_) {}
  }

  /// Takes the counts, locks and hints of a fresh copy of the team doc. For
  /// the open [puzzle] ([key]): when teammates' answers used its last attempt
  /// (two phones counting at once), it is locked here too. Returns true when
  /// the open puzzle has just become locked, by this or by a teammate.
  bool absorb(Team fresh, {Puzzle? puzzle, String? key}) {
    final wasLocked = key != null && isLocked(key);
    team.attempts
      ..clear()
      ..addAll(fresh.attempts);
    team.lockedUntil
      ..clear()
      ..addAll(fresh.lockedUntil);
    team.hintsUsed
      ..clear()
      ..addAll(fresh.hintsUsed);
    var justLocked = false;
    if (key != null && puzzle != null) {
      final max = puzzle.maxAttempts;
      if (isLocked(key)) {
        justLocked = !wasLocked;
      } else if (max != null && (team.attempts[key] ?? 0) >= max) {
        _lock(key);
        justLocked = true;
      }
    }
    _changed();
    return justLocked;
  }

  void dispose() => changes.dispose();
}
