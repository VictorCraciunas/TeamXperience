import 'dart:async';

import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/features/chat_button/controller/chat_button_controller.dart';
import 'package:teamxperience/features/chat_button/logic/chat_key.dart';
import 'package:teamxperience/features/chat_button/logic/watched_chat.dart';
import 'package:teamxperience/features/chat_button/service/chat_seen_store.dart';
import 'package:teamxperience/model/message.dart';
import 'package:teamxperience/model/team.dart';

final t0 = DateTime(2026, 11, 21, 10);

Message organiser(int minute, [String text = 'Mesaj']) =>
    Message(sender: Role.ADMIN, text: text, timestamp: t0.add(Duration(minutes: minute)));

Message player(int minute, [String text = 'Răspuns']) =>
    Message(sender: Role.USER, text: text, timestamp: t0.add(Duration(minutes: minute)));

Team team(String name) => Team(name: name, teamMembers: '', captainName: '', phoneNumber: '', captainEmail: '');

WatchedChat chat(String eventId, String teamName) => WatchedChat(eventId, team(teamName));

class MemoryChatSeenStore implements ChatSeenStore {
  final Map<ChatKey, DateTime> values = {};

  @override
  Future<DateTime?> read(ChatKey chat) async => values[chat];

  @override
  Future<void> write(ChatKey chat, DateTime seen) async => values[chat] = seen;
}

/// One stream per chat, fed by the test.
class FakeChats {
  final Map<ChatKey, StreamController<List<Message>>> _controllers = {};

  /// The bound each chat was last asked from.
  final Map<ChatKey, DateTime> since = {};

  StreamController<List<Message>> of(ChatKey chat) =>
      _controllers.putIfAbsent(chat, () => StreamController<List<Message>>.broadcast());

  Stream<List<Message>> stream(ChatKey chat, DateTime after) {
    since[chat] = after;
    return of(chat).stream;
  }

  void send(ChatKey chat, List<Message> messages) => of(chat).add(messages);

  /// The chat can no longer be read (a renamed team's old chat).
  void fail(ChatKey chat) => of(chat).addError(StateError('permission-denied'));

  bool listened(ChatKey chat) => _controllers[chat]?.hasListener ?? false;
}

/// A controller over [chats] and [store], its clock at [now] (changeable).
class ControllerRig {
  ControllerRig({Duration previewFor = const Duration(milliseconds: 30)}) {
    controller = ChatButtonController(
      messages: chats.stream,
      store: store,
      now: () => now,
      previewFor: previewFor,
      onLost: lost.add,
    );
  }

  final chats = FakeChats();
  final lost = <ChatKey>[];
  final store = MemoryChatSeenStore();
  DateTime now = t0;
  late final ChatButtonController controller;
}

/// Lets the store reads and stream events go through.
Future<void> settle() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
