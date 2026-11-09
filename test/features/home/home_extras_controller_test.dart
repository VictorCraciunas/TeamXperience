import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/home/controller/home_extras_controller.dart';
import 'package:teamxperience/model/app_notification.dart';
import 'package:teamxperience/model/crew.dart';
import 'package:teamxperience/model/memory.dart';
import 'package:teamxperience/model/season_standing.dart';
import 'package:teamxperience/model/team.dart';

class _Harness {
  final memories = StreamController<List<Memory>>.broadcast();
  final crews = StreamController<List<Crew>>.broadcast();
  final standings = StreamController<List<SeasonStanding>>.broadcast();
  final unread = StreamController<List<AppNotification>>.broadcast();
  final watched = <String>[];
  Team? team;

  late final controller = HomeExtrasController(
    memories: (uid) {
      watched.add(uid);
      return memories.stream;
    },
    crews: (_) => crews.stream,
    standings: standings.stream,
    seasonName: 'Toamna 2026',
    findTeam: (_, __) async => team,
    notifications: (_) => unread.stream,
  );
}

const _unreadOne = AppNotification(id: 'n', kind: NotificationKind.chat, title: 'T', body: 'B', read: false);

Future<void> _settle() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

void main() {
  test('follows unread notifications for the player', () async {
    final h = _Harness();
    h.controller.watch('u1');
    await _settle();
    h.unread.add([_unreadOne]);
    await _settle();
    expect(h.controller.hasUnread, isTrue);
    h.unread.add(const []);
    await _settle();
    expect(h.controller.hasUnread, isFalse);
  });

  test('a failing stream means no dot', () async {
    final h = _Harness();
    h.controller.watch('u1');
    await _settle();
    h.unread.add([_unreadOne]);
    await _settle();
    h.unread.addError(Exception('denied'));
    await _settle();
    expect(h.controller.hasUnread, isFalse);
  });

  test('watch(null) clears the dot and stops following', () async {
    final h = _Harness();
    h.controller.watch('u1');
    await _settle();
    h.unread.add([_unreadOne]);
    await _settle();
    h.controller.watch(null);
    await _settle();
    expect(h.controller.hasUnread, isFalse);
    expect(h.unread.hasListener, isFalse);
  });

  test('follows the newest memory and loads its album', () async {
    final h = _Harness()..team = Team.fromMap({'name': 'Vulpile', 'teamPhotos': {'start': {'url': 's'}}});
    h.controller.watch('u1');
    await _settle();
    h.memories.add(const [Memory(eventId: 'e', eventName: 'Harta')]);
    await _settle();
    expect(h.controller.memory?.eventName, 'Harta');
    expect(h.controller.album.single.url, 's');
  });

  test('coming back to Home reads the photos again, so a late one shows', () async {
    final h = _Harness()..team = Team.fromMap(const {'name': 'Vulpile'});
    h.controller.watch('u1');
    await _settle();
    h.memories.add(const [Memory(eventId: 'e', eventName: 'Harta')]);
    await _settle();
    expect(h.controller.album, isEmpty);

    h.team = Team.fromMap(const {'name': 'Vulpile', 'teamPhotos': {'finish': {'url': 'late'}}});
    h.controller.setVisible(true);
    await _settle();
    expect(h.controller.album, isEmpty, reason: 'still on screen: no extra read');

    h.controller.setVisible(false);
    await _settle();
    expect(h.controller.album, isEmpty, reason: 'leaving reads nothing');

    h.controller.setVisible(true);
    await _settle();
    expect(h.controller.album.single.url, 'late');
  });

  test('no memories: nothing to show', () async {
    final h = _Harness();
    h.controller.watch('u1');
    await _settle();
    h.memories.add(const []);
    await _settle();
    expect(h.controller.memory, isNull);
    expect(h.controller.album, isEmpty);
  });

  test('works out the season spot from crews and standings', () async {
    final h = _Harness();
    h.controller.watch('u1');
    await _settle();
    h.standings.add(const [
      SeasonStanding(crewId: 'x', crewName: 'X', points: 200),
      SeasonStanding(crewId: 'c1', crewName: 'Vulpile', points: 135),
    ]);
    h.crews.add([Crew.fromMap('c1', const {'name': 'Vulpile'})]);
    await _settle();
    expect(h.controller.seasonSpot?.place, 2);
    expect(h.controller.seasonName, 'Toamna 2026');
  });

  test('the same uid keeps the watch; a new one replaces it; null stops', () async {
    final h = _Harness();
    h.controller
      ..watch('u1')
      ..watch('u1');
    expect(h.watched, ['u1']);
    h.controller.watch('u2');
    expect(h.watched, ['u1', 'u2']);

    h.memories.add(const [Memory(eventId: 'e', eventName: 'Harta')]);
    await _settle();
    expect(h.controller.memory, isNotNull);
    h.controller.watch(null);
    await _settle();
    expect(h.controller.memory, isNull);
    expect(h.memories.hasListener, isFalse);
  });

  test('errors in the streams leave things empty', () async {
    final h = _Harness();
    h.controller.watch('u1');
    await _settle();
    h.memories.addError(Exception('denied'));
    h.crews.addError(Exception('denied'));
    h.standings.addError(Exception('denied'));
    await _settle();
    expect(h.controller.memory, isNull);
    expect(h.controller.seasonSpot, isNull);
  });

  test('a dispose during an album load does not throw', () async {
    final h = _Harness();
    h.controller.watch('u1');
    await _settle();
    h.memories.add(const [Memory(eventId: 'e', eventName: 'Harta')]);
    h.controller.dispose();
    await _settle();
  });
}
