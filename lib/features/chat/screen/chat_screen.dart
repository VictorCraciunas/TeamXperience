import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/features/chat/controller/chat_controller.dart';
import 'package:teamxperience/features/chat/widgets/message_stream.dart';
import 'package:teamxperience/widgets/my_appbar.dart';
import 'package:teamxperience/widgets/my_button.dart';
import 'package:teamxperience/widgets/my_text_field.dart';

import '../../../model/event.dart';
import '../../../model/team.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatController controller;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (!_initialized) {
      final arguments =
      ModalRoute
          .of(context)!
          .settings
          .arguments as Map<String, dynamic>;
      final event = arguments['event'] as Event;
      final team = arguments['team'] as Team?;

      controller = ChatController(event, team!, context);
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(appBarText: "Chat"),
      body: SafeArea(
        child: Column(
          children: [
            MessagesStream(messageSteam: controller.getMessages()),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0,bottom: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: MyTextField(
                      controller: controller.chatTextField),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      controller.sendMessage();
                      controller.chatTextField.clear();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.lightBlue, // Add background color
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Icon(Icons.send,size: 20,),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
