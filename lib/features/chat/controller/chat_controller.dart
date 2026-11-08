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
  late MessageService messageService = MessageService();
  late TeamService teamService = TeamService();
  late BuildContext context;

  /// Writes a photo decision; by default through [teamService] (tests pass
  /// their own).
  late final Future<void> Function(String key, PhotoApprovalStatus status, {String? reason, String? url}) _writeApproval;

  ChatController(
    this.eventId,
    this.team,
    this.context, {
    Future<void> Function(String key, PhotoApprovalStatus status, {String? reason, String? url})? writeApproval,
  }) {
    _writeApproval = writeApproval ??
        (key, status, {reason, url}) =>
            teamService.setPhotoApproval(eventId, team.name, key, status, reason: reason, url: url);
  }

  Future<void> sendMessage() async {
    AppUser? user = Provider.of<UserProvider>(context, listen: false).currentUser;

    messageService.sendMessage(eventId, team.name, chatTextField.text,user!);
  }

  /// The organiser has seen this chat: the live room stops asking about it.
  /// A failure only leaves the card up.
  void markRead() {
    teamService.clearUnread(eventId, team.name).catchError((_) {});
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>  getMessages() {
    return messageService.getMessages(eventId, team.name);
  }

  Stream<Team> getTeamStream() {
    return teamService.getStreamTeam(eventId, team.name);
  }

  /// Approves a photo, keeping its picture ([url]) on the try.
  Future<void> approvePhoto(Team currentTeam, String approvalKey, {String? url}) async {
    await _writeApproval(approvalKey, PhotoApprovalStatus.approved, url: url);
  }

  /// Rejects a photo with the [reason] the team will read.
  Future<void> denyPhoto(Team currentTeam, String approvalKey, String reason, {String? url}) async {
    final text = reason.trim();
    await _writeApproval(approvalKey, PhotoApprovalStatus.denied, reason: text.isEmpty ? null : text, url: url);
  }
}