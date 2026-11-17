import 'package:teamxperience/model/message.dart';
import 'package:teamxperience/model/team.dart';

import 'chat_key.dart';

/// The player's team in one event, whose chat the button watches.
class WatchedChat {
  const WatchedChat(this.eventId, this.team);

  final String eventId;
  final Team team;

  ChatKey get key => ChatKey(eventId, team.name);

  /// What [Routes.chatScreen] is opened with everywhere in the app.
  Map<String, Object> get routeArguments => {'eventId': eventId, 'team': team};
}

/// A new organiser message, shown for a few seconds above the button.
class ChatPreview {
  const ChatPreview(this.chat, this.message);

  final WatchedChat chat;
  final Message message;
}
