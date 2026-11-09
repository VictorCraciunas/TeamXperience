import 'package:teamxperience/features/game_intro/logic/game_door.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/user.dart';
import 'package:teamxperience/service/share_service.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/features/home/logic/news_seen.dart';
import 'package:teamxperience/features/shell/logic/player_tabs.dart';
import 'package:teamxperience/ui/components/navigation/shell_controller.dart';

import '../../../constants/routes.dart';
import '../../../model/event.dart';
import '../../../model/memory.dart';
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
    context.read<ShellController>().select(PlayerTab.events);
  }

  /// "Clasament": the season's standings are on the Echipe tab.
  void openTeamsTab() {
    context.read<ShellController>().select(PlayerTab.teams);
  }

  void openMemory(Memory memory) {
    Navigator.pushNamed(context, Routes.memory, arguments: {'memory': memory});
  }

  void openAllMemories() {
    Navigator.pushNamed(context, Routes.memories);
  }

  /// The bell: remembers the visit (for the bell's dot), then opens Știri.
  Future<void> openNews(NewsSeenStore store, DateTime now) async {
    navigateToNewsTab();
    await store.markSeen(now);
  }

  /// Știri is not a tab: it opens as a page.
  void navigateToNewsTab() {
    Navigator.pushNamed(context, Routes.newsDashboard, arguments: context.read<NewsList>().stireList);
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

  Future<Team?> teamFor(Event event) async {
    final user = context.read<UserProvider>().currentUser;
    if (user == null) return null;
    return teamService.getUserTeamForEvent(event.eventId, user.uid);
  }

  void navigateToRegisterTeam(Event event) => navigateToEventDetails(event);

  /// The intro letter the first time on this phone, then the game.
  void openGame(Event event, Team team) {
    GameDoor().open(Navigator.of(context), event, team);
  }

  void openChat(Event event, Team team) {
    Navigator.pushNamed(
      context,
      Routes.chatScreen,
      arguments: {'eventId': event.eventId, 'team': team},
    );
  }

  Future<void> shareRegistration(Event event) async {
    final team = await teamFor(event);
    if (team == null || !context.mounted) return;
    await ShareService().shareTeamRegistration(team, event, context);
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