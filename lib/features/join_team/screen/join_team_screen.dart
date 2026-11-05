import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/join_team/controller/join_team_controller.dart';
import 'package:teamxperience/features/join_team/widgets/join_team_body.dart';
import 'package:teamxperience/ui/components/navigation/screen_bar.dart';

class JoinTeamScreen extends StatefulWidget {
  const JoinTeamScreen({super.key});

  @override
  State<JoinTeamScreen> createState() => _JoinTeamScreenState();
}

class _JoinTeamScreenState extends State<JoinTeamScreen> {
  JoinTeamController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= JoinTeamController(context: context);
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

    return Scaffold(
      body: Column(
        children: [
          ScreenBar(
            leadingIcon: TablerIcons.arrow_left,
            onLeading: controller.back,
            title: 'Intră într-o echipă',
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: ListenableBuilder(
                listenable: controller,
                builder:
                    (context, _) => JoinTeamBody(
                      state: controller.state,
                      onCodeChanged: controller.codeChanged,
                      onJoin: controller.confirm,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
