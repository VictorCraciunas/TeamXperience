import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

/// Where the Joacă pop-up's buttons go; the shell wires them to routes.
class PlayPopupActions {
  const PlayPopupActions({
    required this.openEvent,
    required this.openTeam,
    required this.enterCode,
    required this.continueGame,
    required this.openChat,
    required this.browseAll,
  });

  /// "Vezi evenimentul".
  final void Function(Event event) openEvent;

  /// "Echipa mea".
  final void Function(Event event) openTeam;

  /// "Introdu codul de start".
  final void Function(Event event) enterCode;

  /// "Continuă jocul".
  final void Function(Event event, Team team) continueGame;

  /// "Scrie organizatorului".
  final void Function(Event event, Team team) openChat;

  /// "Toate evenimentele": the Evenimente tab.
  final void Function() browseAll;
}
