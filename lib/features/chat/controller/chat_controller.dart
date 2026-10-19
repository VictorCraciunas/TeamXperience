import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/service/message_service.dart';
import 'package:teamxperience/service/team_service/team_service.dart';

import '../../../model/team.dart';
import '../../../model/user.dart';
import '../../../state_management/user_provider.dart';

class ChatController{
  late Team team;
  late String eventId;
  final chatTextField = TextEditingController();
  MessageService messageService = MessageService();
  TeamService teamService = TeamService();
  late BuildContext context;
  ChatController(this.eventId, this.team, this.context);

  Future<void> sendMessage() async {
    AppUser? user = Provider.of<UserProvider>(context, listen: false).currentUser;

    messageService.sendMessage(eventId, team.name, chatTextField.text,user!);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>  getMessages() {
    return messageService.getMessages(eventId, team.name);
  }

  Stream<Team> getTeamStream() {
    return teamService.getStreamTeam(eventId, team.name);
  }

  Future<void> approvePhoto(Team currentTeam, String approvalKey) async {
    await teamService.setPhotoApproval(
      eventId,
      team.name,
      approvalKey,
      PhotoApprovalStatus.approved,
    );
  }

  Future<void> denyPhoto(Team currentTeam, String approvalKey) async {
    await teamService.setPhotoApproval(
      eventId,
      team.name,
      approvalKey,
      PhotoApprovalStatus.denied,
    );
  }
}