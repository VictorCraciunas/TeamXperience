import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/clock_builder.dart';

import '../controller/live_room_controller.dart';
import '../widgets/board_view.dart';
import 'live_room_actions.dart';

/// Every team's progress (argument: the room's [LiveRoomController], which the
/// room's screen keeps and disposes).
class LiveBoardScreen extends StatelessWidget {
  const LiveBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ModalRoute.of(context)?.settings.arguments;
    if (controller is! LiveRoomController) return const Scaffold();
    final actions = LiveRoomActions(context, controller);
    return Scaffold(
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => ClockBuilder(
          interval: const Duration(seconds: 30),
          builder: (context, now) => BoardView(
            teamCount: controller.teams.length,
            missionCount: controller.missionCount,
            rows: controller.rows(now),
            filter: controller.filter,
            now: now,
            canStop: controller.canStop,
            announcing: controller.announcing,
            onFilter: controller.setFilter,
            onTeam: (team) => actions.openTeam(team, now),
            onCall: actions.call,
            onAnnounce: actions.announce,
            onStop: actions.stop,
          ),
        ),
      ),
    );
  }
}
