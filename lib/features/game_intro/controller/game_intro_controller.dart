import 'package:flutter/widgets.dart';
import 'package:teamxperience/features/game_intro/logic/game_door.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

/// The intro letter screen: "Spre prima misiune" leaves the letter for the
/// game, once.
class GameIntroController {
  GameIntroController({required this.event, required this.team, GameDoor? door}) : _door = door ?? GameDoor();

  final Event event;
  final Team team;
  final GameDoor _door;
  bool _leaving = false;

  Future<void> start(NavigatorState navigator) async {
    if (_leaving) return;
    _leaving = true;
    await _door.leaveIntro(navigator, event, team);
  }
}
