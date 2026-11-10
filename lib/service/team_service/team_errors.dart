import 'package:cloud_functions/cloud_functions.dart';

/// Why a team callable failed. The first 16 are the `reason` values the
/// functions send; `network` and `unknown` are made on the app side.
enum TeamError {
  notSignedIn,
  eventNotFound,
  enrolmentClosed,
  eventFull,
  nameTaken,
  nameInvalid,
  sizeInvalid,
  alreadyInTeam,
  crewAlreadyRegistered,
  notCaptain,
  codeUnknown,
  teamFull,
  alreadyMember,
  rulesNotAccepted,
  teamNotFound,
  gameStarted,
  network,
  unknown;

  static TeamError fromException(Object e) {
    if (e is! FirebaseFunctionsException) return TeamError.unknown;
    final details = e.details;
    if (details is Map) {
      final reason = details['reason'];
      for (final error in TeamError.values) {
        if (error.name == reason) return error;
      }
    }
    if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
      return TeamError.network;
    }
    return TeamError.unknown;
  }

  /// The team name an `alreadyInTeam` error carries, when it has one.
  static String? teamNameFrom(Object e) {
    if (e is! FirebaseFunctionsException) return null;
    final details = e.details;
    if (details is! Map) return null;
    final name = details['teamName'];
    return name is String ? name : null;
  }
}

String teamErrorText(TeamError e, {String? teamName}) {
  switch (e) {
    case TeamError.nameTaken:
      return 'Numele e luat';
    case TeamError.nameInvalid:
      return 'Numele are 2–30 de litere, fără /';
    case TeamError.sizeInvalid:
      return 'Mărimea echipei nu se potrivește';
    case TeamError.alreadyInTeam:
      return teamName == null
          ? 'Ești deja într-o echipă la acest eveniment'
          : 'Ești deja în echipa $teamName la acest eveniment';
    case TeamError.crewAlreadyRegistered:
      return 'Echipa e deja înscrisă';
    case TeamError.notCaptain:
      return 'Doar căpitanul poate înscrie echipa';
    case TeamError.codeUnknown:
      return 'Codul nu există';
    case TeamError.teamFull:
      return 'Echipa e completă';
    case TeamError.alreadyMember:
      return 'Ești deja în echipă';
    case TeamError.enrolmentClosed:
      return 'Înscrierile s-au închis';
    case TeamError.eventFull:
      return 'Nu mai sunt locuri';
    case TeamError.eventNotFound:
      return 'Evenimentul nu mai există';
    case TeamError.rulesNotAccepted:
      return 'Acceptă regulamentul ca să continui';
    case TeamError.teamNotFound:
      return 'Echipa nu mai există';
    case TeamError.gameStarted:
      return 'Jocul a început, numele nu se mai schimbă';
    case TeamError.notSignedIn:
      return 'Intră în cont din nou';
    case TeamError.network:
      return 'Nu a mers. Verifică internetul.';
    case TeamError.unknown:
      return 'Ceva n-a mers. Încearcă din nou.';
  }
}
