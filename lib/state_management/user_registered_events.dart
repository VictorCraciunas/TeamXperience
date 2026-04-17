import 'package:flutter/foundation.dart';
import '../model/event.dart';
import '../model/team.dart';
import '../service/event_service/event_service.dart';
import '../service/team_service/team_service.dart';
import 'user_provider.dart';
import 'events_state_management.dart';

class UserEventsProvider extends ChangeNotifier {
  final UserProvider _userProvider;
  final EventList _eventList;
  final EventService _eventService;
  final TeamService _teamService;

  Event? _activeEvent;
  Team? _activeTeam;

  Event? get activeEvent => _activeEvent;
  Team? get activeTeam => _activeTeam;

  UserEventsProvider(this._userProvider, this._eventList, this._eventService, this._teamService) {
    _userProvider.addListener(_onDataChanged);
    _eventList.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    notifyListeners();
    loadActiveEvent();
  }

  List<Event> get registeredEvents {
    if (_userProvider.currentUser == null) return [];

    return _eventService.registeredEventsFromUser(
        _eventList.events,
        _userProvider.currentUser!
    );
  }

  List<Event> get upcomingRegisteredEvents {
    final now = DateTime.now();
    return registeredEvents.where((event) =>
    event.dateEvent?.isAfter(now) ?? false
    ).toList()..sort((a, b) => a.dateEvent!.compareTo(b.dateEvent!));
  }

  Event? get nextEventWithinHour {
    if (_activeEvent != null) return _activeEvent;

    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));

    // Find events that started within the last hour (user can enter code up to 1h after start)
    final recentEvents = registeredEvents.where((event) =>
      event.dateEvent != null &&
      event.dateEvent!.isBefore(now) &&
      event.dateEvent!.isAfter(oneHourAgo)
    ).toList()..sort((a, b) => a.dateEvent!.compareTo(b.dateEvent!));

    return recentEvents.isNotEmpty ? recentEvents.first : null;
  }

  Future<void> loadActiveEvent() async {
    final user = _userProvider.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final pastEvents = registeredEvents.where((event) =>
      event.dateEvent != null && event.dateEvent!.isBefore(now)
    ).toList();

    for (final event in pastEvents) {
      final team = await _teamService.getUserTeamForEvent(event.eventId, user.uid);
      if (team != null && team.hasStarted && !team.hasFinished) {
        _activeEvent = event;
        _activeTeam = team;
        notifyListeners();
        return;
      }
    }

    if (_activeEvent != null) {
      _activeEvent = null;
      _activeTeam = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _userProvider.removeListener(_onDataChanged);
    _eventList.removeListener(_onDataChanged);
    super.dispose();
  }
}