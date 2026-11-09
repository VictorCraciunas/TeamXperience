import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/state_management/user_registered_events.dart';

import 'home_hero.dart';

/// The Home hero for the current providers at [now]. Home, the Joacă tab and
/// the bottom bar's "În joc" all use it, so they agree. Only Home says a team
/// finished ([includeFinished]): the Joacă tab looks for what can still be played.
HomeHero heroFromProviders({
  required UserEventsProvider userEvents,
  required EventList eventList,
  required DateTime now,
  bool includeFinished = true,
}) {
  final registered = userEvents.registeredEvents;
  return resolveHomeHero(
    now: now,
    activeEvent: userEvents.activeEvent,
    activeTeam: userEvents.activeTeam,
    startedRecently: userEvents.recentlyStartedEvent,
    startedRecentlyTeam: null,
    finishedEvent: includeFinished ? userEvents.finishedEvent : null,
    finishedTeam: includeFinished ? userEvents.finishedTeam : null,
    registeredUpcoming: userEvents.upcomingRegisteredEvents,
    allEvents: eventList.events,
    registeredIds: registered.map((e) => e.eventId).toSet(),
  );
}
