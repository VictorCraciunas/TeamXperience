import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/clock_builder.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';

import '../controller/live_room_controller.dart';
import '../logic/live_map_focus.dart';
import '../widgets/live_map.dart';
import 'live_room_actions.dart';

/// "Hartă mare": the teams on a full-screen map the organiser can move
/// (argument: the `Event`, or [LiveMapArgs] to open it centred on one team).
/// A team sheet's "Hartă" opened here centres this map on the team.
class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  LiveRoomController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final args = liveMapArgsOf(ModalRoute.of(context)?.settings.arguments);
    if (args != null) _controller = LiveRoomController(event: args.event, focusTeam: args.focusTeam);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return const Scaffold();
    final actions = LiveRoomActions(context, controller);
    return Scaffold(
      appBar: const MyAppBar(appBarText: 'Harta evenimentului'),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => ClockBuilder(
          interval: const Duration(seconds: 30),
          // After the first teams arrive, so the map opens on them: the
          // organiser moves it from then on.
          builder: (context, now) => controller.loading
              ? const Center(child: CircularProgressIndicator())
              : LiveMap(
                  event: controller.event,
                  teams: controller.teams,
                  now: now,
                  interactive: true,
                  focus: controller.focus,
                  onTeam: (team) => actions.openTeam(team, now, showOnMap: controller.focusOn),
                ),
        ),
      ),
    );
  }
}
