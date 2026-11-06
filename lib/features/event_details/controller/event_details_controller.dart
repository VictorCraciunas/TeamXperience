import 'package:teamxperience/features/game_intro/logic/game_door.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/features/event_details/logic/event_page_content.dart';
import 'package:teamxperience/features/event_details/logic/event_page_data.dart';
import 'package:teamxperience/features/event_details/logic/signup_bar_state.dart';
import 'package:teamxperience/features/feed/logic/post_text.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/user.dart';
import 'package:teamxperience/service/share_service.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/routes.dart';
import '../../../model/event.dart';
import '../../../state_management/user_provider.dart';

class EventDetailsController extends ChangeNotifier {
  late Event event;
  late AppUser? user;
  late BuildContext context;
  final bool isAdmin;

  EventDetailsController(this.event, this.context, {this.isAdmin = false}) {
    user = Provider.of<UserProvider>(context, listen: false).currentUser;
    _organiserEvents = organiserEventsCount(context.read<EventList>().events, event.organiserName);
    load();
  }

  TeamService service = TeamService();
  List<Team> teams = [];
  Team? _team;

  /// A registered player's team is looked up after the page opens; until then
  /// the bar must not offer sign-up again.
  late bool _teamLoading = !isAdmin && (user?.isRegisterToEvent(event.eventId) ?? false);
  int _organiserEvents = 0;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Everything the page shows besides the event.
  EventPageData get data => EventPageData(
        team: _team,
        teamsCount: teams.length,
        organiserEventsCount: _organiserEvents,
        isAdmin: isAdmin,
        teamLoading: _teamLoading,
      );

  /// Loads the registered teams and the player's own team. A lookup that
  /// fails leaves the player without a team, so the bar falls back to sign-up.
  Future<void> load() async {
    try {
      teams = await service.getTeams(event.eventId);
    } catch (e) {
      debugPrint('Event details: teams failed: $e');
    }
    final uid = user?.uid;
    if (uid != null && !isAdmin) {
      try {
        _team = await service.getUserTeamForEvent(event.eventId, uid);
      } catch (e) {
        debugPrint('Event details: team lookup failed: $e');
      }
    }
    _teamLoading = false;
    if (!_disposed) notifyListeners();
  }

  void onSignupAction(SignupAction action) {
    final team = _team;
    switch (action) {
      case SignupAction.register:
        Navigator.pushNamed(context, Routes.registerTeam, arguments: event);
      case SignupAction.teamDetails:
        Navigator.pushNamed(context, Routes.registerTeamDetails, arguments: {'event': event, 'user': user});
      case SignupAction.enterCode:
        Navigator.pushNamed(context, Routes.enterCodeScreen, arguments: event);
      case SignupAction.continueGame:
      case SignupAction.seeResult:
        if (team != null) GameDoor().open(Navigator.of(context), event, team);
      case SignupAction.none:
        break;
    }
  }

  void share() {
    ShareService().shareText(context, subject: event.name ?? 'Eveniment', text: eventShareText(event));
  }

  /// Opens the start pin in the phone's maps app.
  Future<void> openMap() async {
    final lat = event.startLatitude;
    final lng = event.startLongitude;
    if (lat == null || lng == null) return;
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Event details: map failed: $e');
    }
  }

  /// The team chat, which reaches the organisers; only for a player with a team.
  VoidCallback? get messageOrganiser {
    final team = _team;
    if (team == null) return null;
    return () => Navigator.pushNamed(context, Routes.chatScreen, arguments: {'eventId': event.eventId, 'team': team});
  }

  void navigateToMap() {
    final teams = service.getStreamTeams(event.eventId);
    if (context.mounted) {
      Navigator.pushNamed(context, Routes.map, arguments: {'eventId': event.eventId, 'teams': teams});
    }
  }
}
