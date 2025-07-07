import 'package:flutter/foundation.dart';
import '../model/event.dart';
import '../service/event_service/event_service.dart';
import 'user_provider.dart';
import 'events_state_management.dart';

class UserEventsProvider extends ChangeNotifier {
  final UserProvider _userProvider;
  final EventList _eventList;
  final EventService _eventService;

  UserEventsProvider(this._userProvider, this._eventList, this._eventService) {
    // Listen to both providers to update when user or events change
    _userProvider.addListener(notifyListeners);
    _eventList.addListener(notifyListeners);
  }

  // Get registered events using the EventService method
  List<Event> get registeredEvents {
    if (_userProvider.currentUser == null) return [];

    return _eventService.registeredEventsFromUser(
        _eventList.events,
        _userProvider.currentUser!
    );
  }

  // Get upcoming registered events
  List<Event> get upcomingRegisteredEvents {
    final now = DateTime.now();
    return registeredEvents.where((event) =>
    event.dateEvent?.isAfter(now) ?? false
    ).toList()..sort((a, b) => a.dateEvent!.compareTo(b.dateEvent!));
  }

  Event? get nextEventWithinHour {
    final now = DateTime.now();
    final oneHourFromNow = now.add(const Duration(hours: 1));

    final nextEvent = upcomingRegisteredEvents.isNotEmpty ? upcomingRegisteredEvents.first : null;

    if (nextEvent?.dateEvent != null &&
        nextEvent!.dateEvent!.isBefore(oneHourFromNow)) {
      return nextEvent;
    }

    return null;
  }

  @override
  void dispose() {
    _userProvider.removeListener(notifyListeners);
    _eventList.removeListener(notifyListeners);
    super.dispose();
  }
}