import 'package:flutter/material.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/misc/clock_builder.dart';

import '../controller/live_room_controller.dart';
import '../widgets/live_map.dart';
import '../widgets/live_room_view.dart';
import 'live_room_actions.dart';

/// The organiser's live room for one event (argument: the `Event`).
class LiveRoomScreen extends StatefulWidget {
  const LiveRoomScreen({super.key});

  @override
  State<LiveRoomScreen> createState() => _LiveRoomScreenState();
}

class _LiveRoomScreenState extends State<LiveRoomScreen> {
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
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => ClockBuilder(
          interval: const Duration(seconds: 30),
          builder: (context, now) => LiveRoomView(
            event: controller.event,
            stats: controller.stats(now),
            announcing: controller.announcing,
            items: controller.attention(now),
            loading: controller.loading,
            failed: controller.error != null,
            map: LiveMap(
              event: controller.event,
              teams: controller.teams,
              now: now,
              onTeam: (team) => actions.openTeam(team, now),
              onBigMap: actions.openBigMap,
            ),
            isDeciding: controller.isDeciding,
            onBoard: actions.openBoard,
            onAnnounce: actions.announce,
            onViewPhoto: actions.viewPhoto,
            onReject: actions.reject,
            onApprove: actions.approve,
            onTeam: (team) => actions.openTeam(team, now),
            onChat: actions.openChat,
          ),
        ),
      ),
    );
  }
}
