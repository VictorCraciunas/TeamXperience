import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/service/message_service.dart';

import '../../../model/message.dart';
import '../../../model/team.dart';
import '../../../model/user.dart';
import '../../../state_management/user_provider.dart';

class ChatController{
  late Team team;
  late Event event;
  final chatTextField = TextEditingController();
  MessageService messageService = MessageService();
  late BuildContext context;
  ChatController(this.event, this.team, this.context);

  Future<void> sendMessage() async {
    AppUser? user = Provider.of<UserProvider>(context, listen: false).currentUser;

    messageService.sendMessage(event.eventId, team.name, chatTextField.text,user!);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>  getMessages() {
    return messageService.getMessages(event.eventId, team.name);
  }


}