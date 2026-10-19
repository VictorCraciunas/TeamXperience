import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/model/user.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/ui/components/navigation/shell_controller.dart';

import '../../../constants/routes.dart';
import '../../../model/event.dart';
import '../../../model/stire.dart';
import '../../../state_management/events_state_management.dart';
import '../../../state_management/news_state_management.dart';
import '../../../state_management/user_provider.dart';

class HomeController {
  final BuildContext context;
   HomeController(this.context);
  TeamService teamService = TeamService();

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
    context.read<ShellController>().select(1);
  }
  void navigateToEnterCodeScreen(Event event) {
    Navigator.pushNamed(
      context,
      Routes.enterCodeScreen,
      arguments: event
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
  void navigateToTeamDetails(Event event) {
    AppUser? user = Provider.of<UserProvider>(context, listen: false).currentUser;


    Navigator.pushNamed(
      context,
      Routes.registerTeamDetails,
      arguments: {
        'event': event,
        'user': user
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