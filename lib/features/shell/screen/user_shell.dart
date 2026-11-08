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
import 'package:teamxperience/features/play_tab/screen/play_tab_screen.dart';
import 'package:teamxperience/features/profile/screen/profile_screen.dart';
import 'package:teamxperience/features/shell/logic/player_tabs.dart';
import 'package:teamxperience/features/teams/screen/teams_screen.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/state_management/user_registered_events.dart';
import 'package:teamxperience/ui/components/navigation/app_shell.dart';
import 'package:teamxperience/ui/components/navigation/shell_controller.dart';

/// The player's tab shell of the mockups: Acasă, Evenimente, Joacă (raised,
/// "În joc" while a game is on), Echipe and Profil.
class UserShell extends StatefulWidget {
  const UserShell({super.key});

  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  final ShellController _controller = ShellController(5);
  UserDocWatch? _userWatch;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_userWatch != null) return;
    final users = context.read<UserProvider>();
    final uid = profileDocId(users.firebaseUser?.uid, users.currentUser?.uid ?? '');
    if (uid != null) _userWatch = UserDocWatch(UserRepo().streamUser(uid), users.updateProfile);
  }

  /// The game's end is time-based, so the live flag is re-read every 30 s.
  late final Timer _tick = Timer.periodic(const Duration(seconds: 30), (_) {
    if (mounted) setState(() {});
  });

  @override
  void initState() {
    super.initState();
    _tick;
  }

  @override
  void dispose() {
    _tick.cancel();
    _userWatch?.cancel();
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
    final items = playerNavItems(live: live);
    final screens = <WidgetBuilder>[
      (_) => const Home(),
      (_) => const EventsTabScreen(),
      (_) => const PlayTabScreen(),
      (_) => const TeamsScreen(),
      (_) => const ProfileScreen(),
    ];

    return ChangeNotifierProvider<ShellController>.value(
      value: _controller,
      child: AppShell(
        controller: _controller,
        tabs: [for (var i = 0; i < items.length; i++) AppShellTab(item: items[i], builder: screens[i])],
      ),
    );
  }
}
