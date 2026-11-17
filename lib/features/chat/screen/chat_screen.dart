import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/chat/controller/chat_controller.dart';
import 'package:teamxperience/features/live_room/controller/live_room_controller.dart' show CallResult;
import 'package:teamxperience/features/live_room/logic/live_texts.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/ui/components/feedback/snackbars.dart';
import 'package:teamxperience/ui/ui.dart';

import '../../../model/team.dart';
import '../logic/chat_texts.dart';
import '../logic/chat_timeline.dart';
import '../widgets/chat_composer.dart';
import '../widgets/chat_view.dart';
import '../widgets/organiser_chat_header.dart';
import '../widgets/player_chat_header.dart';
import '../widgets/reject_photo_dialog.dart';

/// One team's chat (`Routes.chatScreen`, `{'eventId', 'team': Team}`): the
/// organiser's (navy header, mission strip, photo cards to decide) or a
/// player's with the organiser.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatController? _controller;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (arguments is! Map || user == null) return;
    final eventId = arguments['eventId'];
    final team = arguments['team'];
    if (eventId is! String || team is! Team) return;
    final controller = ChatController(eventId: eventId, team: team, user: user);
    controller.markRead();
    _controller = controller;
  }

  @override
  void dispose() {
    final controller = _controller;
    if (controller != null) {
      // Whatever came in while the chat was open has been read too.
      controller.markRead();
      controller.dispose();
    }
    super.dispose();
  }

  void _back() => Navigator.maybePop(context);

  Future<void> _sendText(ChatController controller) async {
    final result = await controller.sendMessage();
    if (!mounted || result != ChatSendResult.failed) return;
    MySnackBars.errorSnackBar(context, title: ChatController.sendFailedLine);
  }

  Future<void> _sendPhoto(ChatController controller) async {
    final result = await controller.sendPhoto();
    if (!mounted || result != ChatPhotoResult.failed) return;
    MySnackBars.errorSnackBar(context, title: ChatController.photoFailedLine);
  }

  Future<void> _call(ChatController controller) async {
    final result = await controller.callCaptain();
    if (!mounted) return;
    switch (result) {
      case CallResult.opened:
        break;
      case CallResult.noPhone:
        MySnackBars.errorSnackBar(context, title: 'Echipa nu are număr de telefon.');
      case CallResult.failed:
        MySnackBars.errorSnackBar(context, title: 'Nu am putut deschide telefonul.');
    }
  }

  Future<void> _decide(Future<void> Function() write) async {
    try {
      await write();
    } catch (_) {
      if (!mounted) return;
      MySnackBars.errorSnackBar(context, title: 'Nu am putut salva decizia.');
    }
  }

  Future<void> _reject(ChatController controller, ChatPhotoReviewEntry entry) async {
    final reason = await showRejectPhotoDialog(context);
    if (reason == null || !mounted) return;
    await _decide(() => controller.denyPhoto(entry.approvalKey, reason, url: entry.imageUrl));
  }

  Widget _header(ChatController controller) {
    final team = controller.team;
    if (!controller.isOrganiser) {
      return PlayerChatHeader(subtitle: playerSubtitle(controller.event?.name, team.name), onBack: _back);
    }
    final strip = controller.strip;
    final total = controller.event?.missions.length ?? 0;
    final mapArgs = controller.mapArgs;
    return OrganiserChatHeader(
      teamName: team.name,
      teamInitial: teamInitial(team.name),
      members: membersLine(team),
      onBack: _back,
      onMap: mapArgs == null ? null : () => Navigator.pushNamed(context, Routes.map, arguments: mapArgs),
      onCall: controller.canCall ? () => _call(controller) : null,
      strip: strip == null ? null : (text: strip.text, total: total, done: strip.done, current: strip.current),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return Scaffold(backgroundColor: context.colors.inset);
    return Scaffold(
      backgroundColor: context.colors.inset,
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => ChatView(
          header: _header(controller),
          entries: controller.entries(),
          loading: controller.loading,
          emptyText: controller.isOrganiser ? 'Niciun mesaj încă. Scrie-i echipei.' : 'Niciun mesaj încă. Scrie-i organizatorului.',
          onApprove: (entry) => _decide(() => controller.approvePhoto(entry.approvalKey, url: entry.imageUrl)),
          onReject: (entry) => _reject(controller, entry),
          composer: ChatComposer(
            controller: controller.chatTextField,
            hint: controller.isOrganiser ? 'Scrie echipei…' : 'Scrie organizatorului…',
            onSend: () => _sendText(controller),
            onPhoto: () => _sendPhoto(controller),
            sendingPhoto: controller.sendingPhoto,
          ),
        ),
      ),
    );
  }
}
