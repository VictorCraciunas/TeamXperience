import 'package:teamxperience/features/play_tab/logic/play_suggestions.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

sealed class HomeHero {
  const HomeHero();

  /// Which kind of hero this is and for which event. The page layout (which
  /// panels follow the hero) only depends on this, not on the countdown.
  String get signature;
}

class LiveHero extends HomeHero {
  const LiveHero(this.event, this.team);

  final Event event;
  final Team team;

  @override
  String get signature => 'live:${event.eventId}';
}

/// The team is done but the event still runs: results come when it ends.
class FinishedHero extends HomeHero {
  const FinishedHero(this.event, this.team);

  final Event event;
  final Team team;

  @override
  String get signature => 'finished:${event.eventId}';
}

class StartingSoonHero extends HomeHero {
  const StartingSoonHero(this.event, this.minutesLeftToEnter);

  final Event event;
  final int minutesLeftToEnter;

  @override
  String get signature => 'soon:${event.eventId}';
}

class UpcomingHero extends HomeHero {
  const UpcomingHero(this.event, this.untilStart);

  final Event event;
  final Duration untilStart;

  @override
  String get signature => 'upcoming:${event.eventId}';
}

class RecommendedHero extends HomeHero {
  const RecommendedHero(this.event);

  final Event event;

  @override
  String get signature => 'recommended:${event.eventId}';
}

class NoHero extends HomeHero {
  const NoHero();

  @override
  String get signature => 'none';
}

/// Picks what the top card of the player Home shows, in priority order:
/// live game, start code still open, team finished, next registered event,
/// recommendation.
HomeHero resolveHomeHero({
  required DateTime now,
  required Event? activeEvent,
  required Team? activeTeam,
  required Event? startedRecently,
  required Team? startedRecentlyTeam,
  Event? finishedEvent,
  Team? finishedTeam,
  required List<Event> registeredUpcoming,
  required List<Event> allEvents,
  required Set<String> registeredIds,
}) {
  final live = _live(now, activeEvent, activeTeam);
  if (live != null) return live;

  // Another event's start code comes first, so the player does not miss it.
  final finished = _finished(now, finishedEvent, finishedTeam);
  final sameEvent = finished != null && startedRecently?.eventId == finishedEvent?.eventId;
  final soon = sameEvent ? null : _startingSoon(now, startedRecently, startedRecentlyTeam);
  if (soon != null) return soon;
  if (finished != null) return finished;

  final upcoming = _upcoming(now, registeredUpcoming);
  if (upcoming != null) return upcoming;

  final recommended = _recommended(now, allEvents, registeredIds);
  if (recommended != null) return recommended;

  return const NoHero();
}

/// Like [Event.isOver] but against the given clock, so it can be tested.
bool _isOver(Event event, DateTime now) {
  final start = event.dateEvent;
  if (start == null) return true;
  return event.isStopped || now.isAfter(start.add(event.playTime));
}

HomeHero? _live(DateTime now, Event? event, Team? team) {
  if (event == null || team == null) return null;
  if (_isOver(event, now)) return null;
  if (!team.hasStarted || team.hasFinished) return null;
  return LiveHero(event, team);
}

HomeHero? _finished(DateTime now, Event? event, Team? team) {
  if (event == null || team == null) return null;
  if (_isOver(event, now) || !team.hasFinished) return null;
  return FinishedHero(event, team);
}

HomeHero? _startingSoon(DateTime now, Event? event, Team? team) {
  if (event == null) return null;
  final start = event.dateEvent;
  if (start == null || _isOver(event, now)) return null;
  if (team != null && team.hasStarted) return null;
  final sinceStart = now.difference(start);
  if (sinceStart.isNegative || sinceStart > event.enterWindow) return null;
  final minutesLeft = (event.enterWindow - sinceStart).inMinutes;
  return StartingSoonHero(event, minutesLeft < 0 ? 0 : minutesLeft);
}

HomeHero? _upcoming(DateTime now, List<Event> registeredUpcoming) {
  Event? nearest;
  for (final event in registeredUpcoming) {
    final start = event.dateEvent;
    if (start == null || !start.isAfter(now)) continue;
    final current = nearest?.dateEvent;
    if (current == null || start.isBefore(current)) nearest = event;
  }
  final chosen = nearest;
  final start = chosen?.dateEvent;
  if (chosen == null || start == null) return null;
  return UpcomingHero(chosen, start.difference(now));
}

HomeHero? _recommended(DateTime now, List<Event> allEvents, Set<String> registeredIds) {
  Event? earliest;
  for (final event in allEvents) {
    final start = event.dateEvent;
    if (start == null || !isOpenSuggestion(event, registeredIds, now)) continue;
    final current = earliest?.dateEvent;
    if (current == null || start.isBefore(current)) earliest = event;
  }
  final chosen = earliest;
  return chosen == null ? null : RecommendedHero(chosen);
}

/// The registered event that started within its [Event.enterWindow] and is not over,
/// oldest first, so the player can still enter its start code. [except] is an
/// event the player's team has already finished.
Event? recentlyStartedEvent(List<Event> registered, DateTime now, {String? except}) {
  Event? chosen;
  for (final event in registered) {
    if (event.eventId == except) continue;
    final start = event.dateEvent;
    if (start == null || _isOver(event, now)) continue;
    final since = now.difference(start);
    if (since.isNegative || since > event.enterWindow) continue;
    final current = chosen?.dateEvent;
    if (current == null || start.isBefore(current)) chosen = event;
  }
  return chosen;
}
