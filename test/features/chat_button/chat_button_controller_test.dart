import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/features/chat_button/controller/chat_teams_watch.dart';
import 'package:teamxperience/features/chat_button/logic/watched_chat.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/user.dart';

import 'chat_button_test_helpers.dart';

void main() {
  final vulpile = chat('e1', 'Vulpile');
  final lupii = chat('e2', 'Lupii');

  group('ChatButtonController', () {
    test('a chat watched for the first time counts only messages after now', () async {
      final rig = ControllerRig()..now = t0.add(const Duration(minutes: 10));
      rig.controller.watch([vulpile]);
      await settle();
      expect(rig.store.values[vulpile.key], t0.add(const Duration(minutes: 10)));

      rig.chats.send(vulpile.key, [organiser(1), organiser(5)]);
      await settle();
      expect(rig.controller.unread, 0);
      expect(rig.controller.chatToOpen, isNull);

      rig.chats.send(vulpile.key, [organiser(1), organiser(5), organiser(12), player(13), organiser(14)]);
      await settle();
      expect(rig.controller.unread, 2);
      expect(rig.controller.chatToOpen?.key, vulpile.key);
      rig.controller.dispose();
    });

    test('a seen time kept from before is used, and the total spans every chat', () async {
      final rig = ControllerRig();
      rig.store.values[vulpile.key] = t0;
      rig.store.values[lupii.key] = t0;
      rig.controller.watch([vulpile, lupii]);
      await settle();
      rig.chats.send(vulpile.key, [organiser(1), organiser(2)]);
      rig.chats.send(lupii.key, [organiser(5)]);
      await settle();
      expect(rig.controller.unread, 3);
      // Lupii's message is the newest.
      expect(rig.controller.chatToOpen?.key, lupii.key);
      rig.controller.dispose();
    });

    test('the chat on top is read, keeps being read while open, and is read up to leaving', () async {
      final rig = ControllerRig();
      rig.store.values[vulpile.key] = t0;
      rig.controller.watch([vulpile]);
      await settle();
      rig.chats.send(vulpile.key, [organiser(1), organiser(2)]);
      await settle();
      expect(rig.controller.unread, 2);

      rig.controller.chatOnTop(vulpile.key);
      expect(rig.controller.unread, 0);
      expect(rig.store.values[vulpile.key], t0.add(const Duration(minutes: 2)));

      // A message while the chat is open is read straight away.
      rig.chats.send(vulpile.key, [organiser(1), organiser(2), organiser(3)]);
      await settle();
      expect(rig.controller.unread, 0);
      expect(rig.controller.preview, isNull);
      expect(rig.store.values[vulpile.key], t0.add(const Duration(minutes: 3)));

      rig.controller.chatOnTop(null);
      rig.chats.send(vulpile.key, [organiser(1), organiser(2), organiser(3), organiser(4)]);
      await settle();
      expect(rig.controller.unread, 1);
      rig.controller.dispose();
    });

    test('a new organiser message shows its preview for a while; the first snapshot does not', () async {
      final rig = ControllerRig();
      rig.store.values[vulpile.key] = t0;
      rig.controller.watch([vulpile]);
      await settle();
      rig.chats.send(vulpile.key, [organiser(1, 'vechi')]);
      await settle();
      expect(rig.controller.unread, 1);
      expect(rig.controller.preview, isNull);

      // The player's own messages are no news.
      rig.chats.send(vulpile.key, [organiser(1, 'vechi'), player(2)]);
      await settle();
      expect(rig.controller.preview, isNull);

      rig.chats.send(vulpile.key, [organiser(1, 'vechi'), player(2), organiser(3, 'Poarta de nord')]);
      await settle();
      expect(rig.controller.preview?.message.text, 'Poarta de nord');
      expect(rig.controller.preview?.chat.key, vulpile.key);

      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(rig.controller.preview, isNull);
      expect(rig.controller.unread, 2);
      rig.controller.dispose();
    });

    test('opening the chat clears its preview', () async {
      final rig = ControllerRig(previewFor: const Duration(seconds: 5));
      rig.store.values[vulpile.key] = t0;
      rig.controller.watch([vulpile]);
      await settle();
      rig.chats.send(vulpile.key, []);
      await settle();
      rig.chats.send(vulpile.key, [organiser(1, 'Salut')]);
      await settle();
      expect(rig.controller.preview, isNotNull);
      rig.controller.chatOnTop(vulpile.key);
      expect(rig.controller.preview, isNull);
      rig.controller.dispose();
    });

    test('a chat no longer watched stops counting and listening', () async {
      final rig = ControllerRig();
      rig.store.values[vulpile.key] = t0;
      rig.controller.watch([vulpile]);
      await settle();
      rig.chats.send(vulpile.key, [organiser(1)]);
      await settle();
      expect(rig.controller.unread, 1);
      rig.controller.watch([]);
      expect(rig.controller.unread, 0);
      expect(rig.chats.listened(vulpile.key), isFalse);
      rig.controller.dispose();
    });
  });

  group('ChatTeamsWatch', () {
    AppUser user(Role role) => AppUser(email: 'a@b.ro', firstName: 'A', lastName: 'B', uid: 'u1', role: role, fcmToken: '');

    test('a player watches their team in each event not over', () async {
      final events = [
        Event(eventId: 'soon', name: 'A', dateEvent: t0.add(const Duration(days: 1))),
        Event(eventId: 'over', name: 'B', dateEvent: t0.subtract(const Duration(days: 1)), durationMinutes: 60),
        Event(eventId: 'noteam', name: 'C', dateEvent: t0.add(const Duration(days: 2))),
      ];
      final asked = <String>[];
      List<WatchedChat>? got;
      final watch = ChatTeamsWatch(
        user: () => user(Role.USER),
        registered: () => events,
        changes: ChangeNotifier(),
        teamFor: (eventId, uid) async {
          asked.add('$eventId/$uid');
          return eventId == 'noteam' ? null : team('Vulpile');
        },
        onChats: (chats) => got = chats,
        now: () => t0,
      );
      await watch.refresh(force: true);
      expect(asked, ['soon/u1', 'noteam/u1']);
      expect(got?.map((c) => c.key.eventId), ['soon']);

      // Nothing changed: no new lookups.
      await watch.refresh();
      expect(asked, hasLength(2));
      watch.stop();
    });

    test('an organiser or nobody signed in watches nothing', () async {
      for (final who in [user(Role.ADMIN), null]) {
        List<WatchedChat>? got;
        var asked = 0;
        final watch = ChatTeamsWatch(
          user: () => who,
          registered: () => [Event(eventId: 'soon', dateEvent: t0.add(const Duration(days: 1)))],
          changes: ChangeNotifier(),
          teamFor: (eventId, uid) async {
            asked++;
            return team('X');
          },
          onChats: (chats) => got = chats,
          now: () => t0,
        );
        await watch.refresh(force: true);
        expect(got, isEmpty);
        expect(asked, 0);
        watch.stop();
      }
    });
  });

  test('a watched chat opens the chat route with the arguments the app uses', () {
    final args = vulpile.routeArguments;
    expect(args['eventId'], 'e1');
    expect((args['team'] as Team).name, 'Vulpile');
  });
}
