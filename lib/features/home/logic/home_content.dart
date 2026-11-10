import 'package:teamxperience/enums/event_type.dart';
import 'package:teamxperience/features/event_details/logic/enrolment_window.dart';
import 'package:teamxperience/features/home/logic/home_hero.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/memory.dart';
import 'package:teamxperience/model/season_standing.dart';
import 'package:teamxperience/model/stire.dart';

const int _maxEvents = 4;
const int _maxNews = 5;
const Duration _memoryFirstFor = Duration(days: 3);

/// Nothing played yet: Home explains the game instead of showing zeros.
bool isNewPlayer(int games, int xp) => games == 0 && xp == 0;

/// A game just played goes to the top of Home for a few days.
bool memoryGoesFirst(Memory? newest, DateTime now) {
  final date = newest?.date;
  if (date == null || date.isAfter(now)) return false;
  return now.difference(date) <= _memoryFirstFor;
}

/// The banner saying no game is open: not above events that are open.
bool showNothingOpen(HomeHero hero, List<Event> newEvents) => hero is NoHero && newEvents.isEmpty;

/// The open events for "Evenimente noi", without the one already recommended.
List<Event> newEventsToShow(List<Event> open, HomeHero hero) {
  final recommended = hero is RecommendedHero ? hero.event.eventId : null;
  return open.where((e) => e.eventId != recommended).take(_maxEvents).toList();
}

/// The games shown when nothing is open: public ones that are over.
List<Event> pastGamesToShow(List<Event> past, DateTime now) =>
    past.where((e) => e.type == EventType.PUBLIC && isOverAt(e, now)).take(_maxEvents).toList();

/// The news for the carousel: the newest already out, at most [_maxNews]. One
/// with no date counts as the oldest.
List<Stire> latestNews(List<Stire> news, DateTime now) {
  final out = news.where((stire) {
    final date = stire.publicationDate;
    return date == null || !date.isAfter(now);
  }).toList();
  out.sort((a, b) {
    final first = a.publicationDate;
    final second = b.publicationDate;
    if (first == null || second == null) return first == null ? (second == null ? 0 : 1) : -1;
    return second.compareTo(first);
  });
  return out.take(_maxNews).toList();
}

/// The player's best-placed crew in the season's list; null when none is in it.
({int place, SeasonStanding standing})? seasonSpot(List<SeasonStanding> standings, Set<String> myCrewIds) {
  for (var i = 0; i < standings.length; i++) {
    if (myCrewIds.contains(standings[i].crewId)) return (place: i + 1, standing: standings[i]);
  }
  return null;
}
