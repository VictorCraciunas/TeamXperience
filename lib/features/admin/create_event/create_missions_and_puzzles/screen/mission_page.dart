import 'package:flutter/material.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/controller/add_missions_controller.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_mission/mission_widget.dart';
import 'package:teamxperience/ui/ui.dart';

/// One mission opened from the list, with its puzzles.
class MissionPage extends StatelessWidget {
  const MissionPage({super.key, required this.controller, required this.index});

  final AddMissionsController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.page,
      appBar: AppBar(
        backgroundColor: context.colors.page,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(),
        title: Text('Misiunea ${index + 1}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, 30),
          child: MissionWidget(
            currentMission: controller.event.missions[index],
            mode: 'edit',
            missionDone: (_) {},
            addMissionsController: controller,
          ),
        ),
      ),
    );
  }
}
