import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/enums/message_type.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/features/chat_button/logic/chat_button_shown.dart';
import 'package:teamxperience/features/chat_button/logic/chat_button_texts.dart';
import 'package:teamxperience/features/chat_button/logic/chat_key.dart';
import 'package:teamxperience/features/chat_button/logic/chat_on_top.dart';
import 'package:teamxperience/features/chat_button/logic/chat_to_open.dart';
import 'package:teamxperience/features/chat_button/logic/first_watch.dart';
import 'package:teamxperience/features/chat_button/logic/unread.dart';
import 'package:teamxperience/features/chat_button/logic/watched_events.dart';
import 'package:teamxperience/features/chat_button/service/chat_seen_store.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/message.dart';
import 'package:teamxperience/model/team.dart';

final _t0 = DateTime(2026, 11, 21, 10);

Message _msg(Role sender, int minute, {String text = 'x', bool announcement = false, MessageType type = MessageType.text}) =>
    Message(
      sender: sender,
      text: text,
      timestamp: _t0.add(Duration(minutes: minute)),
      announcement: announcement,
      type: type,
    );

Team _team(String name) => Team(name: name, teamMembers: '', captainName: '', phoneNumber: '', captainEmail: '');

class _MemoryStore implements ChatSeenStore {
  final Map<ChatKey, DateTime> values = {};
  int writes = 0;

  @override
  Future<DateTime?> read(ChatKey chat) async => values[chat];

  @override
  Future<void> write(ChatKey chat, DateTime seen) async {
    writes++;
    values[chat] = seen;
  }
}

void main() {
  const key = ChatKey('e1', 'Vulpile');

  group('unread', () {
    test('counts only organiser messages after the seen time, announcements included', () {
      final messages = [
        _msg(Role.ADMIN, 1),
        _msg(Role.USER, 3),
        _msg(Role.ADMIN, 4, announcement: true),
        _msg(Role.ADMIN, 5),
        _msg(Role.USER, 6),
      ];
      expect(unreadCount(messages, _t0.add(const Duration(minutes: 2))), 2);
      expect(unreadCount(messages, _t0.add(const Duration(minutes: 5))), 0);
      expect(unreadCount(const [], _t0), 0);
    });

    test('a message at exactly the seen time is read', () {
      expect(unreadCount([_msg(Role.ADMIN, 2)], _t0.add(const Duration(minutes: 2))), 0);
    });

    test('the newest organiser message, if any', () {
      expect(newestOrganiserAt([_msg(Role.ADMIN, 1), _msg(Role.ADMIN, 4), _msg(Role.USER, 9)]),
          _t0.add(const Duration(minutes: 4)));
      expect(newestOrganiserAt([_msg(Role.USER, 9)]), isNull);
    });

    test('viewing a chat moves the seen time to the organiser\'s newest message and never back', () {
      final messages = [_msg(Role.ADMIN, 1), _msg(Role.ADMIN, 4), _msg(Role.USER, 3)];
      expect(seenAfterViewing(messages, _t0, null), _t0.add(const Duration(minutes: 4)));
      // An organiser message stamped ahead of this phone's clock still counts as read.
      expect(seenAfterViewing(messages, _t0, _t0), _t0.add(const Duration(minutes: 4)));
      // Never earlier than before.
      final later = _t0.add(const Duration(hours: 1));
      expect(seenAfterViewing(messages, _t0, later), later);
      // No organiser message: the seen time stays, or is now for a chat never seen.
      expect(seenAfterViewing([_msg(Role.USER, 8)], _t0.add(const Duration(minutes: 9)), _t0), _t0);
      expect(seenAfterViewing(const [], _t0, null), _t0);
    });

    test('a teammate whose clock runs ahead cannot hide a later organiser message', () {
      // The teammate's phone stamps its message an hour ahead.
      final viewed = [_msg(Role.ADMIN, 1), _msg(Role.USER, 60)];
      final seen = seenAfterViewing(viewed, _t0.add(const Duration(minutes: 2)), _t0);
      expect(seen, _t0.add(const Duration(minutes: 1)));
      // The organiser writes again ten minutes later: unread.
      expect(unreadCount([...viewed, _msg(Role.ADMIN, 10)], seen), 1);
    });

    test('a fresh organiser message is the newest unread one past the last known', () {
      final messages = [_msg(Role.ADMIN, 1), _msg(Role.ADMIN, 5, text: 'nou'), _msg(Role.USER, 6)];
      final seen = _t0;
      expect(freshOrganiserMessage(messages, seen, _t0.add(const Duration(minutes: 1)))?.text, 'nou');
      // Nothing past what was already known.
      expect(freshOrganiserMessage(messages, seen, _t0.add(const Duration(minutes: 5))), isNull);
      // Already read.
      expect(freshOrganiserMessage(messages, _t0.add(const Duration(minutes: 5)), null), isNull);
      // No organiser message known yet: any unread one is fresh.
      expect(freshOrganiserMessage(messages, seen, null)?.text, 'nou');
    });
  });

  group('which chat to open', () {
    test('the chat whose unread message is the newest, and the total', () {
      final a = ChatUnread(const ChatKey('e1', 'A'), 2, _t0.add(const Duration(minutes: 3)));
      final b = ChatUnread(const ChatKey('e2', 'B'), 1, _t0.add(const Duration(minutes: 7)));
      final c = ChatUnread(const ChatKey('e3', 'C'), 0, _t0.add(const Duration(minutes: 9)));
      expect(chatToOpen([a, b, c]), const ChatKey('e2', 'B'));
      expect(totalUnread([a, b, c]), 3);
    });

    test('nothing to open when all is read', () {
      expect(chatToOpen([ChatUnread(key, 0, _t0)]), isNull);
      expect(chatToOpen(const []), isNull);
      expect(totalUnread(const []), 0);
    });
  });

  group('first watch', () {
    test('a chat watched for the first time is read up to now', () async {
      final store = _MemoryStore();
      expect(await seenOrStart(store, key, _t0), _t0);
      expect(store.values[key], _t0);
    });

    test('a chat watched before keeps its seen time', () async {
      final store = _MemoryStore()..values[key] = _t0.subtract(const Duration(days: 1));
      expect(await seenOrStart(store, key, _t0), _t0.subtract(const Duration(days: 1)));
      expect(store.writes, 0);
    });
  });

  group('chat on top', () {
    test('the chat route with its event and team is that chat', () {
      expect(chatOnTop(Routes.chatScreen, {'eventId': 'e1', 'team': _team('Vulpile')}), key);
    });

    test('other routes and odd arguments are no chat', () {
      expect(chatOnTop(Routes.home, {'eventId': 'e1', 'team': _team('Vulpile')}), isNull);
      expect(chatOnTop(Routes.chatScreen, null), isNull);
      expect(chatOnTop(Routes.chatScreen, {'eventId': 'e1'}), isNull);
      expect(chatOnTop(Routes.chatScreen, {'eventId': 3, 'team': _team('A')}), isNull);
      expect(chatOnTop(null, null), isNull);
    });
  });

  group('when the button shows', () {
    bool shown({
      bool player = true,
      int unread = 2,
      String? route = Routes.home,
      bool page = true,
      bool keyboard = false,
      bool hidden = false,
    }) =>
        chatButtonShown(
          player: player,
          unread: unread,
          top: TopRoute(name: route, isPage: page),
          keyboardOpen: keyboard,
          hiddenByPage: hidden,
        );

    test('a player with unread messages on a page', () {
      expect(shown(), isTrue);
      expect(shown(route: Routes.puzzleGame), isTrue);
      // A page pushed without a name is still a player page.
      expect(shown(route: null), isTrue);
    });

    test('hidden with nothing unread, for organisers, with the keyboard up or on a page that hides it', () {
      expect(shown(unread: 0), isFalse);
      expect(shown(player: false), isFalse);
      expect(shown(keyboard: true), isFalse);
      expect(shown(hidden: true), isFalse);
    });

    test('hidden on the chat itself, the sign-in pages and over dialogs and sheets', () {
      for (final route in [
        Routes.chatScreen,
        Routes.redirect,
        Routes.splash,
        Routes.login,
        Routes.signup,
        Routes.register,
        Routes.forgotPassword,
      ]) {
        expect(shown(route: route), isFalse, reason: route);
      }
      expect(shown(page: false, route: null), isFalse);
      // The chat's full-screen photo, an unnamed page above it.
      expect(
        chatButtonShown(
          player: true,
          unread: 1,
          top: const TopRoute(name: null, isPage: true, aboveChat: true),
          keyboardOpen: false,
          hiddenByPage: false,
        ),
        isFalse,
      );
      expect(
        chatButtonShown(player: true, unread: 1, top: null, keyboardOpen: false, hiddenByPage: false),
        isFalse,
      );
    });
  });

  group('above the chat', () {
    test('unnamed routes over the chat are part of it', () {
      expect(aboveChat([Routes.home, Routes.chatScreen, null]), isTrue);
      expect(aboveChat([Routes.home, Routes.chatScreen, null, null]), isTrue);
    });

    test('the chat itself, a named page over it, or an unnamed page elsewhere are not', () {
      expect(aboveChat([Routes.home, Routes.chatScreen]), isFalse);
      expect(aboveChat([Routes.chatScreen, Routes.eventDetails, null]), isFalse);
      expect(aboveChat([Routes.home, null]), isFalse);
      expect(aboveChat([null]), isFalse);
      expect(aboveChat(const []), isFalse);
    });
  });

  group('texts', () {
    test('the spoken label counts messages the Romanian way', () {
      expect(chatButtonLabel(1), 'Deschide chatul cu organizatorul, 1 mesaj nou');
      expect(chatButtonLabel(2), 'Deschide chatul cu organizatorul, 2 mesaje noi');
      expect(chatButtonLabel(19), 'Deschide chatul cu organizatorul, 19 mesaje noi');
      expect(chatButtonLabel(20), 'Deschide chatul cu organizatorul, 20 de mesaje noi');
      expect(chatButtonLabel(101), 'Deschide chatul cu organizatorul, 101 mesaje noi');
      expect(chatButtonLabel(120), 'Deschide chatul cu organizatorul, 120 de mesaje noi');
    });

    test('the badge stops at 99+', () {
      expect(chatBadgeText(3), '3');
      expect(chatBadgeText(99), '99');
      expect(chatBadgeText(100), '99+');
    });

    test('the preview shows the text, or a photo label', () {
      expect(previewHeader, 'Organizator · acum');
      expect(previewText(_msg(Role.ADMIN, 1, text: '  Ne vedem la poartă. ')), 'Ne vedem la poartă.');
      expect(previewText(_msg(Role.ADMIN, 1, text: '', type: MessageType.image)), 'Fotografie');
    });
  });

  group('events to watch', () {
    test('registered events that are not over', () {
      final now = _t0;
      final upcoming = Event(eventId: 'up', name: 'A', dateEvent: now.add(const Duration(days: 2)));
      final running = Event(eventId: 'run', name: 'B', dateEvent: now.subtract(const Duration(minutes: 30)), durationMinutes: 120);
      final ended = Event(eventId: 'end', name: 'C', dateEvent: now.subtract(const Duration(hours: 5)), durationMinutes: 120);
      final stopped = Event(eventId: 'stop', name: 'D', dateEvent: now.subtract(const Duration(minutes: 5)))..isStopped = true;
      expect(eventsToWatch([upcoming, running, ended, stopped], now).map((e) => e.eventId), ['up', 'run']);
    });
  });
}
