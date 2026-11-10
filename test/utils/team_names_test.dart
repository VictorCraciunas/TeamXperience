import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/utils/team_names.dart';

/// The same examples as `functions/src/test/names.test.ts`.
void main() {
  test('cleanTeamName trims and collapses inner spaces', () {
    expect(cleanTeamName('  Lupii   de  Cetate '), 'Lupii de Cetate');
  });

  test('teamNameProblem flags short names', () {
    expect(teamNameProblem('A'), TeamNameProblem.short);
    expect(teamNameProblem(''), TeamNameProblem.short);
  });

  test('teamNameProblem flags long names', () {
    expect(teamNameProblem('a' * 31), TeamNameProblem.long);
    expect(teamNameProblem('a' * 30), isNull);
  });

  test('teamNameProblem flags characters Firestore ids cannot take', () {
    expect(teamNameProblem('A/B'), TeamNameProblem.characters);
    expect(teamNameProblem('..'), TeamNameProblem.characters);
    expect(teamNameProblem('.ab'), TeamNameProblem.characters);
    expect(teamNameProblem('ab.'), TeamNameProblem.characters);
    expect(teamNameProblem('a__b'), TeamNameProblem.characters);
  });

  test('teamNameProblem accepts a normal name', () {
    expect(teamNameProblem('Vulpile'), isNull);
  });
}
