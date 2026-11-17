import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/model/message.dart';
import 'package:teamxperience/service/message_service.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/state_management/user_registered_events.dart';

import '../controller/chat_button_controller.dart';
import '../controller/chat_button_spots.dart';
import '../controller/chat_route_watch.dart';
import '../controller/chat_teams_watch.dart';
import '../logic/chat_key.dart';
import '../logic/chat_on_top.dart';
import '../logic/watched_chat.dart';
import '../service/chat_seen_store.dart';
import 'chat_button_overlay.dart';
import 'chat_button_scope.dart';

/// The player's floating chat button over the whole app, put around the
/// navigator by MaterialApp.builder. It watches the player's team chats,
/// counts the organiser's unread messages and opens the newest one's chat.
class ChatButtonLayer extends StatefulWidget {
  const ChatButtonLayer({super.key, required this.routes, required this.child});

  /// The observer registered on the same MaterialApp.
  final ChatRouteWatch routes;
  final Widget child;

  @override
  State<ChatButtonLayer> createState() => _ChatButtonLayerState();
}

class _ChatButtonLayerState extends State<ChatButtonLayer> {
  late final ChatButtonController _controller = ChatButtonController(
    messages: _messagesOf,
    store: SharedPrefsChatSeenStore(),
    onLost: (_) => _teams?.lookAgain(),
  );
  final ChatButtonSpots _spots = ChatButtonSpots();
  ChatTeamsWatch? _teams;

  AppLifecycleListener? _lifecycle;
  String? _lastTopName;

  // Made on first use: nothing touches Firestore until a player has a team.
  MessageService? _messageService;
  TeamService? _teamService;

  /// Only what is newer than the chat's seen time: never the whole history.
  Stream<List<Message>> _messagesOf(ChatKey chat, DateTime since) {
    final service = _messageService ??= MessageService();
    return service.getMessagesAfter(chat.eventId, chat.teamName, since).map(_parse);
  }

  static List<Message> _parse(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final messages = <Message>[];
    for (final doc in snapshot.docs) {
      try {
        messages.add(Message.fromFirestore(doc.data()));
      } catch (_) {
        // A message the app cannot read counts as nothing.
      }
    }
    return messages;
  }

  @override
  void initState() {
    super.initState();
    widget.routes.addListener(_routeChanged);
    // Back in the app, a teammate may have renamed the team meanwhile.
    _lifecycle = AppLifecycleListener(onResume: () => _teams?.lookAgain());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_teams != null) return;
    final users = context.read<UserProvider>();
    final userEvents = context.read<UserEventsProvider>();
    _teams = ChatTeamsWatch(
      user: () => users.currentUser,
      registered: () => userEvents.registeredEvents,
      changes: Listenable.merge([users, userEvents]),
      teamFor: (eventId, uid) => (_teamService ??= TeamService()).getUserTeamForEvent(eventId, uid),
      onChats: _controller.watch,
    )..start();
  }

  void _routeChanged() {
    final top = widget.routes.top;
    _controller.chatOnTop(top == null ? null : chatOnTop(top.name, top.arguments));
    // The team page is where the captain renames the team.
    final left = _lastTopName;
    _lastTopName = top?.name;
    if (left == Routes.registerTeamDetails && top?.name != left) _teams?.lookAgain();
  }

  void _open(WatchedChat chat) {
    _controller.dismissPreview();
    widget.routes.navigator?.pushNamed(Routes.chatScreen, arguments: chat.routeArguments);
  }

  @override
  void dispose() {
    widget.routes.removeListener(_routeChanged);
    _lifecycle?.dispose();
    _teams?.stop();
    _controller.dispose();
    _spots.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = context.select<UserProvider, bool>((users) => users.currentUser?.role == Role.USER);
    return ChatButtonScope(
      spots: _spots,
      controller: _controller,
      child: ChatButtonOverlay(
        controller: _controller,
        routes: widget.routes,
        spots: _spots,
        player: player,
        onOpen: _open,
        child: widget.child,
      ),
    );
  }
}
