import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/features/chat/controller/chat_controller.dart';
import 'package:teamxperience/features/chat/widgets/chat_composer.dart';
import 'package:teamxperience/features/chat/widgets/message_stream.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';

import '../../../model/team.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatController controller;
  bool _initialized = false;
  bool _hasText = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final eventId = arguments['eventId'] as String;
      final team = arguments['team'] as Team?;

      controller = ChatController(eventId, team!, context);
      controller.chatTextField.addListener(_onTextChanged);
      _initialized = true;
    }
  }

  void _onTextChanged() {
    final has = controller.chatTextField.text.trim().isNotEmpty;
    if (has != _hasText) {
      setState(() => _hasText = has);
    }
  }

  void _send() {
    controller.sendMessage();
    controller.chatTextField.clear();
  }

  @override
  void dispose() {
    controller.chatTextField.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser!;
    final isAdmin = user.role == Role.ADMIN;
    final subtitle = isAdmin ? controller.team.name : 'Administrator';

    return Scaffold(
      appBar: MyAppBar(appBarText: 'Chat', subtitle: subtitle),
      body: Column(
        children: [
          MessagesStream(controller: controller),
          ChatComposer(
            controller: controller.chatTextField,
            onSend: _send,
            hasText: _hasText,
          ),
        ],
      ),
    );
  }
}
