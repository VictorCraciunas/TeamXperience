import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/enter_code/controller/start_code_controller.dart';
import 'package:teamxperience/features/enter_code/logic/start_texts.dart';
import 'package:teamxperience/features/enter_code/widgets/start_code_view.dart';
import 'package:teamxperience/features/event_game/widgets/keeps_presence.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/ui/components/misc/clock_builder.dart';
import 'package:teamxperience/ui/ui.dart';

/// The start-code screen (mockup 05). The route takes the [Event].
class EnterCode extends StatefulWidget {
  const EnterCode({super.key});

  @override
  State<EnterCode> createState() => _EnterCodeState();
}

class _EnterCodeState extends State<EnterCode> {
  final TeamService _teams = TeamService();
  StartCodeController? _controller;
  String? _uid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final event = ModalRoute.of(context)?.settings.arguments;
    if (event is! Event) return;
    final uid = context.read<UserProvider>().currentUser?.uid;
    _uid = uid;
    _controller = StartCodeController(
      event: event,
      findTeam: () async => uid == null ? null : _teams.getUserTeamForEvent(event.eventId, uid),
      watchTeam: (name) => _teams.getStreamTeam(event.eventId, name),
      startTeam: (team) => _teams.startTeam(event.eventId, team.name),
      onEnter: _enter,
    )..load();
  }

  Future<void> _enter(Event event, Team team) async {
    if (!mounted) return;
    await Navigator.of(context).pushReplacementNamed(Routes.eventGame, arguments: {'event': event, 'team': team});
  }

  void _openChat(Event event, Team team) {
    Navigator.pushNamed(context, Routes.chatScreen, arguments: {'eventId': event.eventId, 'team': team});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return Scaffold(backgroundColor: context.colors.navy);
    return Scaffold(
      backgroundColor: context.colors.navy,
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final event = controller.event;
          final team = controller.team;
          final uid = _uid;
          final view = ClockBuilder(
            interval: const Duration(seconds: 30),
            builder: (context, now) => StartCodeView(
              event: event,
              now: now,
              team: team,
              codeLength: codeLength(event),
              code: controller.code,
              result: controller.result,
              started: controller.started,
              busy: controller.busy,
              onCode: controller.setCode,
              onSubmit: controller.submit,
              onClose: () => Navigator.of(context).maybePop(),
              onChat: team == null ? null : () => _openChat(event, team),
            ),
          );
          // Always wrapped, so the boxes keep their typing when the team arrives.
          return KeepsPresence(
            markPresent: () async {
              final current = controller.team;
              if (current == null || uid == null) return;
              await _teams.markPresent(event.eventId, current.name, uid);
            },
            child: view,
          );
        },
      ),
    );
  }
}
