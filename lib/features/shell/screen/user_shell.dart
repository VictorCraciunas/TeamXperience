import 'package:teamxperience/backend/repo/user_repo.dart';
import 'package:teamxperience/features/profile/logic/profile_texts.dart';
import 'package:teamxperience/features/shell/logic/user_doc_watch.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/features/events_tab/screen/events_tab_screen.dart';
import 'package:teamxperience/features/home/logic/hero_from_providers.dart';
import 'package:teamxperience/features/home/screen/home.dart';
import 'package:teamxperience/features/play_tab/logic/play_tab_state.dart';
import 'package:teamxperience/features/play_tab/controller/play_popup_controller.dart';
import 'package:teamxperience/features/play_tab/widgets/play_popup.dart';
import 'package:teamxperience/features/shell/logic/play_popup_routes.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/features/profile/screen/profile_screen.dart';
import 'package:teamxperience/features/shell/logic/player_tabs.dart';
import 'package:teamxperience/features/teams/screen/teams_screen.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/state_management/user_registered_events.dart';
import 'package:teamxperience/ui/components/navigation/app_shell.dart';
import 'package:teamxperience/ui/components/navigation/shell_controller.dart';

/// The player's tab shell of the mockups: Acasă, Evenimente, Joacă (raised,
/// "În joc" while a game is on), Echipe and Profil. Joacă is not a page: it
/// opens the Joacă pop-up over the current tab (mockup 10).
class UserShell extends StatefulWidget {
  const UserShell({super.key});

  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  final ShellController _controller = ShellController(5);
  UserDocWatch? _userWatch;
  PlayPopupController? _popup;
  (bool, bool) _popupShown = (false, false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _popup ??= _makePopup();
    if (_userWatch != null) return;
    final users = context.read<UserProvider>();
    final uid = profileDocId(users.firebaseUser?.uid, users.currentUser?.uid ?? '');
    if (uid != null) _userWatch = UserDocWatch(UserRepo().streamUser(uid), users.updateProfile);
  }

  PlayPopupController _makePopup() {
    final teams = TeamService();
    final users = context.read<UserProvider>();
    return PlayPopupController(
      userEvents: context.read<UserEventsProvider>(),
      eventList: context.read<EventList>(),
      teamFor: (event) async {
        final uid = users.currentUser?.uid;
        return uid == null ? null : teams.getUserTeamForEvent(event.eventId, uid);
      },
      teams: teams.getStreamTeams,
      countTeams: teams.countTeams,
    )..addListener(_popupChanged);
  }

  /// The pop-up ticks every second; the shell only rebuilds when it opens,
  /// starts closing or closes.
  void _popupChanged() {
    final popup = _popup;
    if (popup == null || !mounted) return;
    final shown = (popup.isOpen, popup.isClosing);
    if (shown == _popupShown) return;
    setState(() => _popupShown = shown);
  }

  /// The game's end is time-based, so the live flag is re-read every 30 s.
  late final Timer _tick = Timer.periodic(const Duration(seconds: 30), (_) {
    if (mounted) setState(() {});
  });

  @override
  void initState() {
    super.initState();
    _tick;
    _controller.addListener(_tabChanged);
  }

  /// Another tab closes the pop-up.
  void _tabChanged() => _popup?.requestClose();

  @override
  void dispose() {
    _tick.cancel();
    _userWatch?.cancel();
    _popup?.dispose();
    _controller.removeListener(_tabChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final live = isLive(
      playTabState(
        heroFromProviders(
          userEvents: context.watch<UserEventsProvider>(),
          eventList: context.watch<EventList>(),
          now: DateTime.now(),
        ),
      ),
    );
    final popup = _popup;
    if (popup == null) return const SizedBox.shrink();
    final (open, closing) = _popupShown;
    final items = playerNavItems(live: live, open: open && !closing);
    final screens = <WidgetBuilder?>[
      (_) => const Home(),
      (_) => const EventsTabScreen(),
      null,
      (_) => const TeamsScreen(),
      (_) => const ProfileScreen(),
    ];

    return ChangeNotifierProvider<ShellController>.value(
      value: _controller,
      child: AppShell(
        controller: _controller,
        overlay: open
            ? PlayPopup(
                controller: popup,
                actions: playPopupRoutes(
                  navigator: Navigator.of(context),
                  user: () => context.read<UserProvider>().currentUser,
                  browseAll: () => _controller.select(PlayerTab.events),
                ),
              )
            : null,
        onOverlayBack: popup.requestClose,
        tabs: [
          for (var i = 0; i < items.length; i++)
            i == PlayerTab.play
                ? AppShellTab(item: items[i], onTap: popup.toggle)
                : AppShellTab(item: items[i], builder: screens[i]),
        ],
      ),
    );
  }
}
