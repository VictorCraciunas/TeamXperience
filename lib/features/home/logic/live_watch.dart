import 'package:teamxperience/features/home/logic/home_hero.dart';
import 'package:teamxperience/model/event.dart';

/// The live game whose teams Home should stream: only while a game is on
/// and Home is actually on screen (its tab is the current one and no page is
/// pushed over the shell), so the stream does not run through a whole game
/// played on another screen.
Event? liveEventToWatch(HomeHero hero, {required bool visible}) {
  if (!visible || hero is! LiveHero) return null;
  return hero.event;
}
