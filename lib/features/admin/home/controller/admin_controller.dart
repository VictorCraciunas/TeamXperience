import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/state_management/news_state_management.dart';

import '../../../../backend/authentication/AuthenticationRepository.dart';
import '../../../../backend/repo/teamRepo.dart';
import '../../../../constants/routes.dart';
import '../../../../model/event.dart';
import '../../../../model/stire.dart';
import '../../../../state_management/events_state_management.dart';

class AdminHomeController extends ChangeNotifier {
  final BuildContext context;
  final AuthenticationRepository _authRepo = AuthenticationRepository();
  final TeamRepo _teamRepo = TeamRepo();

  // Event statistics (eventId -> {nrTeams, nrPerson})
  Map<String, Map<String, int>> _eventStats = {};

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

  void navigateToEventDetails(Event event) {
    Navigator.pushNamed(
      context,
      Routes.eventDetails,
      arguments: {
        'event': event,
        'isAdmin': true,
      },
    );
  }

  void navigateToStireDetails(Stire stire) {
    Navigator.pushNamed(
      context,
      Routes.newsDetails,
      arguments: {
        'stire': stire,
        'isAdmin': true,
      },
    );
  }

  void navigateToChats() {
    final eventList = context.read<EventList>();

    if (eventList.upcomingEvents.isNotEmpty) {
      final firstEvent = eventList.upcomingEvents.first;
      Navigator.pushNamed(
        context,
        Routes.teamConversations, // Assuming this is the correct route for team chats
        arguments: firstEvent,
      );
    }
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
    Navigator.pushNamed(
      context,
      Routes.sendNotification,
    );
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
    final eventList = context.read<EventList>();
    await loadEventStats(eventList.upcomingEvents);
  }

  Future<void> refreshData() async {
    await Future.wait([
      context.read<EventList>().refresh(),
      context.read<NewsList>().refresh(),
    ]);

    // Reload event stats
    final eventList = context.read<EventList>();
    await loadEventStats(eventList.upcomingEvents);
  }

  /// Load team statistics for events
  Future<void> loadEventStats(List<Event> events) async {
    for (final event in events) {
      try {
        final teams = await _teamRepo.getAllTeamsForEvent(event.eventId);
        final nrTeams = teams.length;
        final nrPerson = teams.fold<int>(0, (sum, team) => sum + team.userIds.length);

        _eventStats[event.eventId] = {
          'nrTeams': nrTeams,
          'nrPerson': nrPerson,
        };
      } catch (e) {
        // If error fetching teams, default to 0
        _eventStats[event.eventId] = {'nrTeams': 0, 'nrPerson': 0};
      }
    }
    notifyListeners();
  }
}