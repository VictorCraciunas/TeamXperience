import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/event_game/logic/puzzle_rules.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/model/team.dart';

Team _team({Map<String, int>? attempts, Map<String, bool>? hints, Map<String, DateTime>? locks}) => Team(
      name: 'Vulpile',
      teamMembers: '',
      captainName: '',
      phoneNumber: '',
      captainEmail: '',
      attempts: attempts,
      hintsUsed: hints,
      lockedUntil: locks,
    );

Puzzle _puzzle({int? max, String? hint = 'Uită-te în sus', String? wrong}) =>
    Puzzle(id: '0', type: PuzzleType.code, maxAttempts: max, indiciu: hint, wrongAnswerMessage: wrong);

void main() {
  group('attemptsLeft', () {
    test('the limit minus the wrong answers so far', () {
      expect(attemptsLeft(_puzzle(max: 3), _team(attempts: {'3_0': 1}), '3_0'), 2);
      expect(attemptsLeft(_puzzle(max: 3), _team(), '3_0'), 3);
    });

    test('never below zero', () {
      expect(attemptsLeft(_puzzle(max: 3), _team(attempts: {'3_0': 7}), '3_0'), 0);
    });

    test('no limit: null', () {
      expect(attemptsLeft(_puzzle(), _team(attempts: {'3_0': 5}), '3_0'), isNull);
    });
  });

  group('lockLeft', () {
    final now = DateTime(2026, 11, 14, 10, 30);

    test('the time until the lock ends', () {
      final team = _team(locks: {'3_0': now.add(const Duration(seconds: 45))});
      expect(lockLeft(team, '3_0', now), const Duration(seconds: 45));
    });

    test('null once it ended, and for another puzzle', () {
      final team = _team(locks: {'3_0': now.subtract(const Duration(seconds: 1))});
      expect(lockLeft(team, '3_0', now), isNull);
      expect(lockLeft(team, '3_1', now), isNull);
      expect(lockLeft(_team(locks: {'3_0': now}), '3_0', now), isNull);
    });
  });

  group('hintAvailable', () {
    final event = Event(eventId: 'e1', hintsPerMission: 1);

    test('a puzzle with a hint, none used in the mission', () {
      expect(hintAvailable(event, _puzzle(), _team(), 3, 0), isTrue);
    });

    test('no hint text: never', () {
      expect(hintAvailable(event, _puzzle(hint: null), _team(), 3, 0), isFalse);
      expect(hintAvailable(event, _puzzle(hint: '  '), _team(), 3, 0), isFalse);
    });

    test('the mission\'s one hint was used on another puzzle', () {
      expect(hintAvailable(event, _puzzle(), _team(hints: {'3_1': true}), 3, 0), isFalse);
    });

    test('a hint used in another mission does not count', () {
      expect(hintAvailable(event, _puzzle(), _team(hints: {'2_0': true, '13_0': true}), 3, 0), isTrue);
    });

    test('re-opening this puzzle\'s own hint is free', () {
      expect(hintAvailable(event, _puzzle(), _team(hints: {'3_0': true}), 3, 0), isTrue);
    });

    test('no hints in this event', () {
      expect(hintAvailable(Event(eventId: 'e1', hintsPerMission: 0), _puzzle(), _team(), 3, 0), isFalse);
    });
  });

  test('the wrong-answer line', () {
    expect(wrongLine(_puzzle()), 'Nu e corect. Mai încearcă.');
    expect(wrongLine(_puzzle(wrong: '  ')), 'Nu e corect. Mai încearcă.');
    expect(wrongLine(_puzzle(wrong: 'Nu e anul ăsta.')), 'Nu e anul ăsta.');
  });

  test('the lock lasts a minute', () {
    expect(puzzleLock, const Duration(seconds: 60));
  });

  test('"Mai încercați în 0:45"', () {
    expect(lockLine(const Duration(seconds: 45)), 'Mai încercați în 0:45');
    expect(lockLine(const Duration(milliseconds: 59100)), 'Mai încercați în 1:00');
  });
}
