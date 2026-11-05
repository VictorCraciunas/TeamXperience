import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/service/team_service/team_errors.dart';

FirebaseFunctionsException _failed(String reason) => FirebaseFunctionsException(
      message: 'x',
      code: 'failed-precondition',
      details: {'reason': reason},
    );

void main() {
  group('teamErrorText', () {
    const expected = {
      TeamError.nameTaken: 'Numele e luat',
      TeamError.nameInvalid: 'Numele are 2–30 de litere, fără /',
      TeamError.sizeInvalid: 'Mărimea echipei nu se potrivește',
      TeamError.alreadyInTeam: 'Ești deja într-o echipă la acest eveniment',
      TeamError.crewAlreadyRegistered: 'Echipa e deja înscrisă',
      TeamError.notCaptain: 'Doar căpitanul poate înscrie echipa',
      TeamError.codeUnknown: 'Codul nu există',
      TeamError.teamFull: 'Echipa e completă',
      TeamError.alreadyMember: 'Ești deja în echipă',
      TeamError.enrolmentClosed: 'Înscrierile s-au închis',
      TeamError.eventFull: 'Nu mai sunt locuri',
      TeamError.eventNotFound: 'Evenimentul nu mai există',
      TeamError.rulesNotAccepted: 'Acceptă regulamentul ca să continui',
      TeamError.notSignedIn: 'Intră în cont din nou',
      TeamError.network: 'Nu a mers. Verifică internetul.',
      TeamError.unknown: 'Ceva n-a mers. Încearcă din nou.',
    };

    test('covers every error', () {
      expect(expected.keys.toSet(), TeamError.values.toSet());
    });

    for (final entry in expected.entries) {
      test(entry.key.name, () {
        expect(teamErrorText(entry.key), entry.value);
      });
    }

    test('alreadyInTeam names the team when known', () {
      expect(
        teamErrorText(TeamError.alreadyInTeam, teamName: 'Lupii'),
        'Ești deja în echipa Lupii la acest eveniment',
      );
    });
  });

  group('TeamError.fromException', () {
    test('reads the reason from the details', () {
      expect(TeamError.fromException(_failed('teamFull')), TeamError.teamFull);
    });

    test('an unrecognised reason is unknown', () {
      expect(TeamError.fromException(_failed('somethingNew')), TeamError.unknown);
    });

    test('unavailable and deadline-exceeded are network', () {
      expect(
        TeamError.fromException(
            FirebaseFunctionsException(message: 'x', code: 'unavailable')),
        TeamError.network,
      );
      expect(
        TeamError.fromException(
            FirebaseFunctionsException(message: 'x', code: 'deadline-exceeded')),
        TeamError.network,
      );
    });

    test('a function error without a reason is unknown', () {
      expect(
        TeamError.fromException(
            FirebaseFunctionsException(message: 'x', code: 'internal')),
        TeamError.unknown,
      );
    });

    test('a plain exception is unknown', () {
      expect(TeamError.fromException(Exception('boom')), TeamError.unknown);
    });
  });

  group('TeamError.teamNameFrom', () {
    test('reads details.teamName', () {
      final e = FirebaseFunctionsException(
        message: 'x',
        code: 'failed-precondition',
        details: {'reason': 'alreadyInTeam', 'teamName': 'Lupii'},
      );
      expect(TeamError.teamNameFrom(e), 'Lupii');
    });

    test('is null without it', () {
      expect(TeamError.teamNameFrom(_failed('alreadyInTeam')), isNull);
      expect(TeamError.teamNameFrom(Exception('x')), isNull);
    });
  });
}
