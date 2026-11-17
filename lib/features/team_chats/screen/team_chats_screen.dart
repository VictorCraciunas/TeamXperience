import 'package:flutter/material.dart';
import 'package:teamxperience/features/team_chats/controller/team_chats_controller.dart';
import 'package:teamxperience/features/team_chats/logic/chat_texts.dart';
import 'package:teamxperience/features/team_chats/widgets/team_chats_view.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/components/misc/clock_builder.dart';

import '../../../constants/routes.dart';
import '../../../model/event.dart';

/// The organiser's conversations with the teams of one event (argument: the
/// [Event]); the chats with something to read come first.
class TeamChatsScreen extends StatefulWidget {
  const TeamChatsScreen({super.key});

  @override
  State<TeamChatsScreen> createState() => _TeamChatsScreenState();
}

class _TeamChatsScreenState extends State<TeamChatsScreen> {
  TeamChatsController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final event = ModalRoute.of(context)?.settings.arguments;
    if (event is Event) _controller = TeamChatsController(event: event)..start();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _openChat(Event event, Team team) {
    Navigator.pushNamed(context, Routes.chatScreen, arguments: {'eventId': event.eventId, 'team': team});
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return const Scaffold();
    return Scaffold(
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => ClockBuilder(
          interval: const Duration(seconds: 30),
          builder: (context, now) => TeamChatsView(
            subtitle: chatsHeaderLine(controller.event.name, controller.teamCount),
            loading: controller.isLoading,
            failed: controller.failed,
            teamCount: controller.teamCount,
            unreadCount: controller.unreadCount,
            filter: controller.filter,
            sections: controller.sections,
            now: now,
            onBack: () => Navigator.maybePop(context),
            onFilter: controller.setFilter,
            onOpen: (team) => _openChat(controller.event, team),
            onRetry: controller.retry,
          ),
        ),
      ),
    );
  }
}
