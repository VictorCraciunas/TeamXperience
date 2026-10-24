import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/state_management/news_state_management.dart';

import '../../../../backend/authentication/AuthenticationRepository.dart';
import '../../../../backend/repo/teamRepo.dart';
import '../../../../constants/routes.dart';
import '../../../../model/event.dart';
import '../../../../model/stire.dart';
import '../../../../state_management/events_state_management.dart';
import '../../../../service/team_service/team_service.dart';
import '../logic/admin_event_stats.dart';

class AdminHomeController extends ChangeNotifier {
  final BuildContext context;
  final AuthenticationRepository _authRepo = AuthenticationRepository();
  final TeamRepo _teamRepo = TeamRepo();

  // Event statistics (eventId -> {nrTeams, nrPerson})
  Map<String, Map<String, int>> _eventStats = {};
  final Map<String, AdminEventStats> _stats = {};

  Map<String, Map<String, int>> get eventStats => _eventStats;

  AdminHomeController(this.context);

  void logout() {
    context.read<EventList>().clear();
    context.read<NewsList>().clear(); // Clear news as well
    _authRepo.logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.splash,
      (Route<dynamic> route) => false,
    );
  }

  void navigateToCreateEvent({Event? event}) {
    Navigator.pushNamed(
      context,
      Routes.createEvent,
      arguments: {'event': event, 'isBlueprint': true},
    );
  }

  /// Opens a draft in the event form to carry on where it was left.
  void navigateToDraft(Event draft) {
    Navigator.pushNamed(
      context,
      Routes.createEvent,
      arguments: {'event': draft, 'isDraft': true},
    );
  }

  void navigateToEventDetails(Event event) {
    Navigator.pushNamed(
      context,
      Routes.eventDetails,
      arguments: {'event': event, 'isAdmin': true},
    );
  }

  void navigateToStireDetails(Stire stire) {
    Navigator.pushNamed(
      context,
      Routes.newsDetails,
      arguments: {'stire': stire, 'isAdmin': true},
    );
  }

  void navigateToCreateNews() {
    Navigator.pushNamed(context, Routes.createNews);
  }

  void navigateToEventDashboard() {
    final eventList = context.read<EventList>();
    Navigator.pushNamed(
      context,
      Routes.eventDashboard,
      arguments: eventList.events,
    );
  }

  void navigateToNotification() {
    Navigator.pushNamed(context, Routes.sendNotification);
  }

  void navigateToEventManagement(Event event) {
    Navigator.pushNamed(context, Routes.eventManagement, arguments: event);
  }

  void navigateToMap(Event event) {
    Navigator.pushNamed(
      context,
      Routes.map,
      arguments: {
        'eventId': event.eventId,
        'teams': TeamService().getStreamTeams(event.eventId),
      },
    );
  }

  void navigateToChats(Event event) {
    Navigator.pushNamed(context, Routes.teamConversations, arguments: event);
  }

  void navigateToRegisteredTeams(Event event) {
    Navigator.pushNamed(context, Routes.eventRegisteredTeams, arguments: event);
  }

  void navigateToNotificationFor(Event event) {
    Navigator.pushNamed(context, Routes.sendNotification, arguments: event);
  }

  void navigateToStiriDashboard() {
    final newsList = context.read<NewsList>();
    Navigator.pushNamed(
      context,
      Routes.newsDashboard,
      arguments: newsList.stireList, // Pass the actual news list
    );
  }

  Future<void> loadInitialData() async {
    await context.read<EventList>().loadEvents();
    await context.read<NewsList>().loadStire();

    // Load event stats
    await reloadStats();
  }

  Future<void> refreshData() async {
    await Future.wait([
      context.read<EventList>().refresh(),
      context.read<NewsList>().refresh(),
    ]);

    // Reload event stats
    await reloadStats();
  }

  /// Load team statistics for events
  Future<void> loadEventStats(List<Event> events) async {
    for (final event in events) {
      try {
        final teams = await _teamRepo.getAllTeamsForEvent(event.eventId);
        final stats = AdminEventStats.fromTeams(teams);
        _stats[event.eventId] = stats;
        _eventStats[event.eventId] = {
          'nrTeams': stats.teams,
          'nrPerson': stats.persons,
        };
      } catch (e) {
        // If error fetching teams, default to 0
        _stats[event.eventId] = const AdminEventStats();
        _eventStats[event.eventId] = {'nrTeams': 0, 'nrPerson': 0};
      }
    }
    notifyListeners();
  }

  /// Refreshes the events the Home shows (live, soon and upcoming).
  Future<void> reloadStats() async {
    final eventList = context.read<EventList>();
    final now = DateTime.now();
    final events =
        eventList.events.where((e) {
          final start = e.dateEvent;
          return start != null &&
              !(e.isStopped || now.isAfter(start.add(Event.maxDuration)));
        }).toList();
    await loadEventStats(events);
  }

  AdminEventStats statsFor(Event? event) {
    if (event == null) return const AdminEventStats();
    return _stats[event.eventId] ?? const AdminEventStats();
  }
}
