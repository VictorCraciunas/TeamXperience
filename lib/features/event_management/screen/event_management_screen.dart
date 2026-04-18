import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/constants/padding.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/widgets/my_appbar.dart';

import '../../../model/team.dart';
import '../widgets/management_button.dart';

class EventManagementScreen extends StatelessWidget {
  const EventManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final event = ModalRoute.of(context)!.settings.arguments as Event;
    final bool hasStarted = event.dateEvent != null &&
        event.dateEvent!.isBefore(DateTime.now());

    return Scaffold(
      appBar: const MyAppBar(appBarText: "Gestionare eveniment"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MyPaddings.appHorizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Text(
                event.name ?? "",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: MyColors.blackColor,
                ),
              ),
              const SizedBox(height: 30),
              if (!hasStarted) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MyColors.transparentYellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFFB8860B)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Evenimentul nu a început încă. Harta și chat-ul vor fi disponibile după ce evenimentul începe.",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF5C4A00),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
              ManagementButton(
                text: "Trimite notificare",
                icon: 'assets/images/notification2.svg',
                enabled: true,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    Routes.sendNotification,
                    arguments: event,
                  );
                },
              ),
              const SizedBox(height: 15),
              ManagementButton(
                text: "Hartă",
                icon: 'assets/images/location_map.svg',
                enabled: hasStarted,
                onTap: () {
                  final TeamService service = TeamService();
                  Stream<List<Team>> teams =
                      service.getStreamTeams(event.eventId);
                  Navigator.pushNamed(
                    context,
                    Routes.map,
                    arguments: {
                      'eventId': event.eventId,
                      'teams': teams,
                    },
                  );
                },
              ),
              const SizedBox(height: 15),
              ManagementButton(
                text: "Chat",
                icon: 'assets/images/incepe_jocul.svg',
                enabled: hasStarted,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    Routes.teamConversations,
                    arguments: event,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
