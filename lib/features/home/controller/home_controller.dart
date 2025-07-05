import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../backend/authentication/AuthenticationRepository.dart';
import '../../../constants/routes.dart';
import '../../../model/event.dart';
import '../../../model/stire.dart';
import '../../../state_management/events_state_management.dart';
import '../../../state_management/news_state_management.dart';

class HomeController {
  final BuildContext context;
  final AuthenticationRepository _authRepo = AuthenticationRepository();
   HomeController(this.context);

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


  void navigateToEventDetails(Event event) {
    Navigator.pushNamed(
      context,
      Routes.eventDetails,
      arguments: {
        'event': event,
        'isAdmin': false,
      },
    );
  }

  void navigateToEventDashboard() {
    final eventList = context.read<EventList>();
    Navigator.pushNamed(
      context,
      Routes.eventDashboardUser,
      arguments: eventList.upcomingEvents,
    );
  }
  void navigateToStireDetails(Stire stire) {
    Navigator.pushNamed(
      context,
      Routes.newsDetails,
      arguments: {
        'stire': stire,
        'isAdmin': false,
      },
    );
  }

  void loadInitialData() {
    context.read<EventList>().loadEvents();
    context.read<NewsList>().loadStire();
  }

  Future<void> refreshData() async {
    await Future.wait([
      context.read<EventList>().refresh(),
      context.read<NewsList>().refresh(),
    ]);
  }
}