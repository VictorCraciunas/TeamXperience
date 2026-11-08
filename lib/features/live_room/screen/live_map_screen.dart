import 'package:flutter/material.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/misc/clock_builder.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';

import '../controller/live_room_controller.dart';
import '../widgets/live_map.dart';
import 'live_room_actions.dart';

/// "Hartă mare": the teams on a full-screen map the organiser can move
/// (argument: the `Event`).
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
    final event = ModalRoute.of(context)?.settings.arguments;
    if (event is Event) _controller = LiveRoomController(event: event);
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
                  onTeam: (team) => actions.openTeam(team, now),
                ),
        ),
      ),
    );
  }
}
