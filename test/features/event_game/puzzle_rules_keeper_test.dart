import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/event_game/logic/puzzle_rules_keeper.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/model/team.dart';

Team _team() => Team(name: 'Vulpile', teamMembers: '', captainName: '', phoneNumber: '', captainEmail: '');

class _Writes {
  final wrong = <String>[];
  final locks = <(String, DateTime)>[];
  final hints = <String>[];
  bool fail = false;

  Future<void> addWrong(String key) async {
    wrong.add(key);
    if (fail) throw Exception('offline');
  }

  Future<void> lock(String key, DateTime until) async {
    locks.add((key, until));
    if (fail) throw Exception('offline');
  }

  Future<void> markHint(String key) async {
    hints.add(key);
    if (fail) throw Exception('offline');
  }
}

void main() {
  final now = DateTime(2026, 11, 14, 10, 30);
  final puzzle = Puzzle(id: '0', type: PuzzleType.code, maxAttempts: 3);

  late _Writes writes;
  late PuzzleRulesKeeper keeper;
  late int changes;

  setUp(() {
    writes = _Writes();
    changes = 0;
    keeper = PuzzleRulesKeeper(
      team: _team(),
      addWrongAttempt: writes.addWrong,
      lockPuzzle: writes.lock,
      markHintUsed: writes.markHint,
      clock: () => now,
    )..changes.addListener(() => changes++);
  });

  test('a wrong answer is counted here at once and sent as an increment', () {
    expect(keeper.wrong(puzzle, '3_0'), WrongResult.counted);
    expect(keeper.team.attempts['3_0'], 1);
    expect(writes.wrong, ['3_0']);
    expect(changes, 1);
  });

  test('the last attempt locks the puzzle for a minute and starts the count over', () {
    keeper.wrong(puzzle, '3_0');
    keeper.wrong(puzzle, '3_0');
    expect(keeper.wrong(puzzle, '3_0'), WrongResult.outOfAttempts);
    expect(writes.locks, [('3_0', now.add(const Duration(seconds: 60)))]);
    expect(keeper.team.lockedUntil['3_0'], now.add(const Duration(seconds: 60)));
    expect(keeper.team.attempts['3_0'], 0);
  });

  test('while locked, an answer is refused and not counted', () {
    for (var i = 0; i < 3; i++) {
      keeper.wrong(puzzle, '3_0');
    }
    writes.wrong.clear();
    expect(keeper.isLocked('3_0'), isTrue);
    expect(keeper.wrong(puzzle, '3_0'), WrongResult.locked);
    expect(writes.wrong, isEmpty);
  });

  test('no limit: counted, never locked', () {
    final open = Puzzle(id: '0', type: PuzzleType.code);
    for (var i = 0; i < 10; i++) {
      expect(keeper.wrong(open, '3_0'), WrongResult.counted);
    }
    expect(writes.locks, isEmpty);
  });

  test('the counts from teammates\' phones come in through the stream', () {
    final fresh = Team.fromMap({
      'name': 'Vulpile',
      'attempts': {'3_0': 2},
      'hintsUsed': {'3_1': true},
    });
    keeper.absorb(fresh);
    expect(keeper.team.attempts['3_0'], 2);
    expect(keeper.team.hintsUsed['3_1'], isTrue);
    expect(changes, 1);
    expect(keeper.wrong(puzzle, '3_0'), WrongResult.outOfAttempts);
  });

  test('a lock set by a teammate holds here too', () {
    keeper.absorb(_team()..lockedUntil['3_0'] = now.add(const Duration(seconds: 30)));
    expect(keeper.wrong(puzzle, '3_0'), WrongResult.locked);
  });

  test('a lock survives closing and reopening the puzzle (a new keeper on the same team)', () {
    for (var i = 0; i < 3; i++) {
      keeper.wrong(puzzle, '3_0');
    }
    final reopened = PuzzleRulesKeeper(
      team: keeper.team,
      addWrongAttempt: writes.addWrong,
      lockPuzzle: writes.lock,
      markHintUsed: writes.markHint,
      clock: () => now.add(const Duration(seconds: 20)),
    );
    expect(reopened.isLocked('3_0'), isTrue);
    expect(reopened.lockLeft('3_0'), const Duration(seconds: 40));
  });

  test('teammates\' answers that used the last attempt lock the puzzle here too', () {
    final fresh = Team.fromMap({'name': 'Vulpile', 'attempts': {'3_0': 3}});
    expect(keeper.absorb(fresh, puzzle: puzzle, key: '3_0'), isTrue);
    expect(writes.locks, [('3_0', now.add(const Duration(seconds: 60)))]);
    expect(keeper.isLocked('3_0'), isTrue);
    expect(keeper.wrong(puzzle, '3_0'), WrongResult.locked);
  });

  test('a lock that arrives from a teammate is reported once', () {
    final locked = _team()..lockedUntil['3_0'] = now.add(const Duration(seconds: 30));
    expect(keeper.absorb(locked, puzzle: puzzle, key: '3_0'), isTrue);
    expect(writes.locks, isEmpty, reason: 'already locked: nothing to write');
    final again = _team()..lockedUntil['3_0'] = now.add(const Duration(seconds: 30));
    expect(keeper.absorb(again, puzzle: puzzle, key: '3_0'), isFalse);
  });

  test('counts below the limit change nothing', () {
    final fresh = Team.fromMap({'name': 'Vulpile', 'attempts': {'3_0': 2}});
    expect(keeper.absorb(fresh, puzzle: puzzle, key: '3_0'), isFalse);
    expect(writes.locks, isEmpty);
  });

  test('opening a hint is remembered once', () async {
    await keeper.useHint('3_0');
    await keeper.useHint('3_0');
    expect(writes.hints, ['3_0']);
    expect(keeper.team.hintsUsed['3_0'], isTrue);
  });

  test('failed writes do not throw and the local count stays', () async {
    writes.fail = true;
    expect(keeper.wrong(puzzle, '3_0'), WrongResult.counted);
    await keeper.useHint('3_0');
    await Future<void>.delayed(Duration.zero);
    expect(keeper.team.attempts['3_0'], 1);
  });
}
