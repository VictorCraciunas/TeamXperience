import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/constants/padding.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/widgets/my_appbar.dart';

import 'event_registered_teams_controller.dart';
import 'widgets/team_card_widget.dart';

class EventRegisteredTeams extends StatefulWidget {
  const EventRegisteredTeams({super.key});

  @override
  State<EventRegisteredTeams> createState() => _EventRegisteredTeamsState();
}

class _EventRegisteredTeamsState extends State<EventRegisteredTeams> {
  late EventRegisteredTeamsController controller;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final event = ModalRoute.of(context)?.settings.arguments as Event?;
      if (event == null) return;

      controller = EventRegisteredTeamsController(event);
      _initialized = true;
      _loadTeams();
    }
  }

  Future<void> _loadTeams() async {
    await controller.loadTeams();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: const MyAppBar(appBarText: "Echipe înscrise"),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.teams.isEmpty
              ? const Center(
                  child: Text(
                    "Nicio echipă înscrisă",
                    style: TextStyle(fontSize: 16, color: MyColors.greyText),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MyPaddings.appHorizontalPadding,
                    vertical: 16,
                  ),
                  itemCount: controller.teams.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return TeamCardWidget(team: controller.teams[index]);
                  },
                ),
    );
  }
}
