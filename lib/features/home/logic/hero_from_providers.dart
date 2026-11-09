import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/state_management/user_registered_events.dart';

import 'home_hero.dart';

/// The Home hero for the current providers at [now]. Home, the Joacă tab and
/// the bottom bar's "În joc" all use it, so they agree.
HomeHero heroFromProviders({
  required UserEventsProvider userEvents,
  required EventList eventList,
  required DateTime now,
}) {
  final registered = userEvents.registeredEvents;
  return resolveHomeHero(
    now: now,
    activeEvent: userEvents.activeEvent,
    activeTeam: userEvents.activeTeam,
    startedRecently: userEvents.recentlyStartedEvent,
    startedRecentlyTeam: null,
    finishedEvent: userEvents.finishedEvent,
    finishedTeam: userEvents.finishedTeam,
    registeredUpcoming: userEvents.upcomingRegisteredEvents,
    allEvents: eventList.events,
    registeredIds: registered.map((e) => e.eventId).toSet(),
  );
}
