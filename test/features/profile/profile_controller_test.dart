import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/profile/controller/profile_controller.dart';
import 'package:teamxperience/features/profile/logic/notification_access.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/memory.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/user.dart';

AppUser _user({int xp = 0}) => AppUser(email: 'v@x.ro', firstName: 'Victor', lastName: 'C', uid: 'vc', fcmToken: '', xp: xp);

void main() {
  group('NotificationAccess', () {
    test('allowed: nothing to ask, the settings open (where they can be turned off)', () async {
      var asked = 0;
      var opened = 0;
      final access = NotificationAccess(
        read: () async => NotifStatus.allowed,
        ask: () async {
          asked++;
          return NotifStatus.allowed;
        },
        openSettings: () async => opened++,
      );
      expect(await access.status(), NotifStatus.allowed);
      expect(await access.askOrOpenSettings(), NotifStatus.allowed);
      expect(asked, 0);
      expect(opened, 1);
    });

    test('not asked yet: it asks', () async {
      final access = NotificationAccess(read: () async => NotifStatus.notAsked, ask: () async => NotifStatus.allowed);
      expect(await access.askOrOpenSettings(), NotifStatus.allowed);
    });

    test('refused: it opens the phone\'s settings; the change only shows on coming back', () async {
      var opened = 0;
      final access = NotificationAccess(
        read: () async => NotifStatus.refused,
        openSettings: () async => opened++,
      );
      expect(await access.askOrOpenSettings(), NotifStatus.refused);
      expect(opened, 1);
    });

    test('a read or an ask that throws reads as refused', () async {
      final reading = NotificationAccess(read: () async => throw Exception('nu'));
      expect(await reading.status(), NotifStatus.refused);
      final asking = NotificationAccess(read: () async => NotifStatus.notAsked, ask: () async => throw Exception('nu'));
      expect(await asking.askOrOpenSettings(), NotifStatus.refused);
    });
  });

  group('ProfileController', () {
    late StreamController<AppUser?> users;
    late StreamController<List<Memory>> memories;
    late List<AppUser> handedOn;
    late NotifStatus status;
    late int opened;

    Future<ProfileController> make(WidgetTester tester) async {
      users = StreamController<AppUser?>();
      memories = StreamController<List<Memory>>();
      handedOn = [];
      status = NotifStatus.notAsked;
      opened = 0;
      final controller = ProfileController(
        tester.element(find.byType(SizedBox)),
        user: _user(),
        userStream: users.stream,
        memoriesStream: memories.stream,
        notifications: NotificationAccess(
          read: () async => status,
          ask: () async => status = NotifStatus.refused,
          openSettings: () async => opened++,
        ),
        onFreshUser: handedOn.add,
      );
      await tester.pump();
      return controller;
    }

    Future<void> withContext(WidgetTester tester, Future<void> Function(ProfileController) body) async {
      await tester.pumpWidget(const SizedBox());
      final controller = await make(tester);
      await body(controller);
      controller.dispose();
    }

    testWidgets('starts with the user it was given, and no memories', (tester) async {
      await withContext(tester, (c) async {
        expect(c.user.xp, 0);
        expect(c.memories, isEmpty);
      });
    });

    testWidgets('a fresh user replaces it and goes on to the provider; a null keeps it', (tester) async {
      await withContext(tester, (c) async {
        users.add(_user(xp: 640));
        await tester.pump();
        expect(c.user.xp, 640);
        expect(handedOn.single.xp, 640);
        users.add(null);
        await tester.pump();
        expect(c.user.xp, 640);
        expect(handedOn, hasLength(1));
      });
    });

    testWidgets('memories arrive', (tester) async {
      await withContext(tester, (c) async {
        memories.add([const Memory(eventId: 'e1', eventName: 'Joc')]);
        await tester.pump();
        expect(c.memories.single.eventName, 'Joc');
      });
    });

    testWidgets('notifications are read once on start and the label follows', (tester) async {
      await withContext(tester, (c) async {
        expect(c.notifications, NotifStatus.notAsked);
        expect(c.notificationsLabel, 'Oprite');
        status = NotifStatus.allowed;
        await c.onNotificationsTap();
        expect(c.notificationsLabel, 'Activate');
      });
    });

    testWidgets('a tap on a refused status opens the settings', (tester) async {
      await withContext(tester, (c) async {
        status = NotifStatus.refused;
        await c.onNotificationsTap();
        expect(opened, 1);
      });
    });

    testWidgets('coming back to the app reads the status again', (tester) async {
      await withContext(tester, (c) async {
        expect(c.notificationsLabel, 'Oprite');
        status = NotifStatus.allowed;
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await tester.pump();
        expect(c.notificationsLabel, 'Activate');
      });
    });

    group('the push token', () {
      Future<(ProfileController, List<String>)> withToken(
        WidgetTester tester, {
        required NotifStatus start,
        String token = '',
        bool failing = false,
      }) async {
        await tester.pumpWidget(const SizedBox());
        status = start;
        final saved = <String>[];
        final c = ProfileController(
          tester.element(find.byType(SizedBox)),
          user: _user().copyWith(fcmToken: token),
          userStream: const Stream.empty(),
          memoriesStream: const Stream.empty(),
          notifications: NotificationAccess(
            read: () async => status,
            ask: () async => status = NotifStatus.allowed,
            openSettings: () async {},
          ),
          onFreshUser: (_) {},
          saveToken: () async {
            saved.add('saved');
            if (failing) throw Exception('offline');
          },
        );
        await tester.pump();
        return (c, saved);
      }

      testWidgets('allowed with no token saved: it is saved, once', (tester) async {
        final (c, saved) = await withToken(tester, start: NotifStatus.allowed);
        expect(saved, ['saved']);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await tester.pump();
        expect(saved, ['saved']);
        c.dispose();
      });

      testWidgets('allowed from the row: the token is saved then', (tester) async {
        final (c, saved) = await withToken(tester, start: NotifStatus.notAsked);
        expect(saved, isEmpty);
        await c.onNotificationsTap();
        expect(saved, ['saved']);
        c.dispose();
      });

      testWidgets('allowed in the phone\'s settings: saved on coming back', (tester) async {
        final (c, saved) = await withToken(tester, start: NotifStatus.refused);
        status = NotifStatus.allowed;
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await tester.pump();
        expect(saved, ['saved']);
        c.dispose();
      });

      testWidgets('a token already there, or refused: nothing is saved', (tester) async {
        final (a, savedA) = await withToken(tester, start: NotifStatus.allowed, token: 'tok');
        expect(savedA, isEmpty);
        a.dispose();
        final (b, savedB) = await withToken(tester, start: NotifStatus.refused);
        expect(savedB, isEmpty);
        b.dispose();
      });

      testWidgets('a save that fails does no harm', (tester) async {
        final (c, saved) = await withToken(tester, start: NotifStatus.allowed, failing: true);
        expect(saved, ['saved']);
        expect(tester.takeException(), isNull);
        expect(c.notificationsLabel, 'Activate');
        c.dispose();
      });
    });

    group('opening a memory', () {
      Future<ProfileController> inApp(WidgetTester tester, Event? Function(String id) find_) async {
        await tester.pumpWidget(MaterialApp(
          routes: {Routes.memory: (_) => const Text('pagina amintirii')},
          home: const SizedBox(),
        ));
        return ProfileController(
          tester.element(find.byType(SizedBox)),
          user: _user(),
          userStream: const Stream.empty(),
          memoriesStream: const Stream.empty(),
          notifications: NotificationAccess(read: () async => NotifStatus.allowed),
          onFreshUser: (_) {},
          findEvent: find_,
        );
      }

      const memory = Memory(eventId: 'e1', eventName: 'Joc');

      testWidgets('goes to the memory page', (tester) async {
        final c = await inApp(tester, (id) => Event(eventId: id));
        c.openMemory(memory);
        await tester.pumpAndSettle();
        expect(find.text('pagina amintirii'), findsOneWidget);
        c.dispose();
      });

      testWidgets('even when its event is not loaded', (tester) async {
        final c = await inApp(tester, (_) => null);
        c.openMemory(memory);
        await tester.pumpAndSettle();
        expect(find.text('pagina amintirii'), findsOneWidget);
        c.dispose();
      });

      testWidgets('coming back reads the albums again, so a late photo shows', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: SizedBox()));
        var photo = false;
        final c = ProfileController(
          tester.element(find.byType(SizedBox)),
          user: _user(),
          userStream: const Stream.empty(),
          memoriesStream: Stream.value(const [memory]),
          notifications: NotificationAccess(read: () async => NotifStatus.allowed),
          onFreshUser: (_) {},
          findEvent: (_) => null,
          findTeam: (_) async => Team.fromMap({
            'name': 'V',
            if (photo) 'teamPhotos': {'finish': {'url': 'late'}},
          }),
        );
        await tester.runAsync(() => Future<void>.delayed(Duration.zero));
        expect(c.albumOf('e1'), isEmpty);

        photo = true;
        c.setVisible(false);
        c.setVisible(true);
        await tester.runAsync(() => Future<void>.delayed(Duration.zero));
        expect(c.albumOf('e1').single.url, 'late');
        c.dispose();
      });

      testWidgets('loads an album per memory, and the event picture', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: SizedBox()));
        final asked = <String>[];
        final c = ProfileController(
          tester.element(find.byType(SizedBox)),
          user: _user(),
          userStream: const Stream.empty(),
          memoriesStream: Stream.value(const [memory, Memory(eventId: 'e2', eventName: 'Alt joc')]),
          notifications: NotificationAccess(read: () async => NotifStatus.allowed),
          onFreshUser: (_) {},
          findEvent: (id) => Event(eventId: id, landingImageUrl: 'poza-$id'),
          findTeam: (id) async {
            asked.add(id);
            return id == 'e1' ? Team.fromMap({'name': 'V', 'teamPhotos': {'start': {'url': 's'}}}) : null;
          },
        );
        await tester.runAsync(() => Future<void>.delayed(Duration.zero));
        await tester.pump();
        expect(asked, ['e1', 'e2']);
        expect(c.albumOf('e1').single.url, 's');
        expect(c.albumOf('e2'), isEmpty);
        expect(c.pictureOf('e2'), 'poza-e2');
        c.dispose();
      });
    });

    testWidgets('after dispose nothing is delivered', (tester) async {
      await tester.pumpWidget(const SizedBox());
      final c = await make(tester);
      c.dispose();
      users.add(_user(xp: 999));
      await tester.pump();
      expect(handedOn, isEmpty);
    });
  });
}
