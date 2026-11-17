import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/service/startup_permissions.dart';

/// A flag store in memory, standing in for shared_preferences.
class _Flag {
  bool value = false;
  int writes = 0;
}

void main() {
  late _Flag flag;
  late List<String> asked;

  StartupPermissions permissions({
    Future<void> Function()? notifications,
    Future<void> Function()? location,
    Future<void> Function()? camera,
    Future<bool> Function()? alreadyAsked,
    Future<void> Function()? markAsked,
  }) =>
      StartupPermissions(
        alreadyAsked: alreadyAsked ?? () async => flag.value,
        markAsked: markAsked ??
            () async {
              flag.value = true;
              flag.writes++;
            },
        asks: [
          notifications ?? () async => asked.add('notifications'),
          location ?? () async => asked.add('location'),
          camera ?? () async => asked.add('camera'),
        ],
      );

  setUp(() {
    flag = _Flag();
    asked = [];
  });

  test('asks notifications, then location, then camera, and sets the flag', () async {
    await permissions().askOnce();
    expect(asked, ['notifications', 'location', 'camera']);
    expect(flag.value, isTrue);
  });

  test('asks only once per install, whoever signs in next', () async {
    await permissions().askOnce();
    // Another account on the same phone: a new instance, the same flag.
    await permissions().askOnce();
    expect(asked, ['notifications', 'location', 'camera']);
    expect(flag.writes, 1);
  });

  test('asks nothing when the flag is already set', () async {
    flag.value = true;
    await permissions().askOnce();
    expect(asked, isEmpty);
    expect(flag.writes, 0);
  });

  test('a prompt that throws does not stop the next ones', () async {
    await permissions(
      notifications: () async => throw Exception('no messaging'),
      location: () async => throw StateError('request already running'),
    ).askOnce();
    expect(asked, ['camera']);
    expect(flag.value, isTrue);
  });

  test('a refusal is just a finished prompt: the next one is still asked', () async {
    // The requesters return nothing; a refused prompt completes like any other.
    await permissions(location: () async => asked.add('location refused')).askOnce();
    expect(asked, ['notifications', 'location refused', 'camera']);
  });

  test('waits for each prompt before showing the next', () async {
    final notifications = Completer<void>();
    final running = permissions(
      notifications: () {
        asked.add('notifications');
        return notifications.future;
      },
    ).askOnce();
    await pumpEventQueue();
    expect(asked, ['notifications']);
    notifications.complete();
    await running;
    expect(asked, ['notifications', 'location', 'camera']);
  });

  test('a second call while the prompts run asks nothing more', () async {
    final notifications = Completer<void>();
    final p = permissions(
      notifications: () {
        asked.add('notifications');
        return notifications.future;
      },
    );
    final first = p.askOnce();
    final second = p.askOnce();
    await pumpEventQueue();
    notifications.complete();
    await Future.wait([first, second]);
    expect(asked, ['notifications', 'location', 'camera']);
    expect(flag.writes, 1);
  });

  test('a flag that cannot be read asks nothing and does not throw', () async {
    await permissions(alreadyAsked: () async => throw Exception('no prefs')).askOnce();
    expect(asked, isEmpty);
  });

  test('a flag that cannot be saved does not throw', () async {
    await permissions(markAsked: () async => throw Exception('no prefs')).askOnce();
    expect(asked, ['notifications', 'location', 'camera']);
  });
}
