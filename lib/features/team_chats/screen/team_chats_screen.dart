import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/features/team_chats/controller/team_chats_controller.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';

import '../../../constants/routes.dart';
import '../../../model/event.dart';

class TeamChatsScreen extends StatefulWidget {
  const TeamChatsScreen({super.key});

  @override
  State<TeamChatsScreen> createState() => _TeamChatsScreenState();
}

class _TeamChatsScreenState extends State<TeamChatsScreen> {
  late TeamChatsController controller;
  bool isLoading = true;
  late Event event;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      event = ModalRoute
          .of(context)!
          .settings
          .arguments as Event;
      controller = TeamChatsController(event: event);
      _loadTeams();
      _initialized = true;

    }
  }

  Future<void> _loadTeams() async {
    await controller.loadTeams();
    setState(() {
      isLoading = false;
    });
  }

  void _navigateToChat(int index) {
    final team = controller.teams![index];
    Navigator.pushNamed(
      context,
      Routes.chatScreen, // Make sure you have this route defined
      arguments: {
        'eventId': event.eventId,
        'team': team,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(appBarText: "Conversații"),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : controller.teams.length == 0
          ? const Center(
        child: Text(
          "Nicio echipă înscrisă.",
          style: TextStyle(fontSize: 18),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: controller.teams.length,
          itemBuilder: (context, index) {
            final team = controller.teams![index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12.0),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                leading: CircleAvatar(
                  backgroundColor: context.colors.accent,
                  child: Text(
                    team.name.isNotEmpty ? team.name[0].toUpperCase() : 'T',
                    style: TextStyle(
                      color: context.colors.onNavy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  team.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      "Căpitan: ${team.captainName}",
                      style: TextStyle(
                        color: context.colors.muted,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Membri: ${team.memberList.map((member) => member.displayName).join(', ')}",
                      style: TextStyle(
                        color: context.colors.muted,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                trailing: Icon(
                  Icons.chat_bubble_outline,
                  color: context.colors.accent,
                ),
                onTap: () => _navigateToChat(index),
              ),
            );
          },
        ),
      ),
    );
  }
}