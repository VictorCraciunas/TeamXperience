import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/profile/controller/profile_controller.dart';
import 'package:teamxperience/features/profile/logic/notification_access.dart';
import 'package:teamxperience/model/memory.dart';
import 'package:teamxperience/model/user.dart';

AppUser _user({int xp = 0}) => AppUser(email: 'v@x.ro', firstName: 'Victor', lastName: 'C', uid: 'vc', fcmToken: '', xp: xp);

void main() {
  group('NotificationAccess', () {
    test('allowed stays allowed and asks nothing', () async {
      var asked = 0;
      final access = NotificationAccess(read: () async => NotifStatus.allowed, ask: () async {
        asked++;
        return NotifStatus.allowed;
      });
      expect(await access.status(), NotifStatus.allowed);
      expect(await access.askOrOpenSettings(), NotifStatus.allowed);
      expect(asked, 0);
    });

    test('not asked yet: it asks', () async {
      final access = NotificationAccess(read: () async => NotifStatus.notAsked, ask: () async => NotifStatus.allowed);
      expect(await access.askOrOpenSettings(), NotifStatus.allowed);
    });

    test('refused: it opens the phone\'s settings and reads again', () async {
      var opened = 0;
      var status = NotifStatus.refused;
      final access = NotificationAccess(
        read: () async => status,
        openSettings: () async {
          opened++;
          status = NotifStatus.allowed;
        },
      );
      expect(await access.askOrOpenSettings(), NotifStatus.allowed);
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
