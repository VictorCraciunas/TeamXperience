import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/notifications/logic/notification_view.dart';
import 'package:teamxperience/model/app_notification.dart';

final _now = DateTime(2026, 11, 9, 14);

AppNotification _n(NotificationKind kind, {DateTime? at, String? eventId, String? teamName}) =>
    AppNotification(id: '${kind.name}$at$eventId$teamName', kind: kind, title: 'T', body: 'B', createdAt: at, read: false, eventId: eventId, teamName: teamName);

void main() {
  test('today and earlier; no date is earlier', () {
    final today = _n(NotificationKind.chat, at: DateTime(2026, 11, 9, 0, 1));
    final yesterday = _n(NotificationKind.chat, at: DateTime(2026, 11, 8, 23, 59));
    final undated = _n(NotificationKind.chat);
    final groups = groupNotifications([today, yesterday, undated], _now);
    expect(groups.today, [today]);
    expect(groups.earlier, [yesterday, undated]);
  });

  test('the time line', () {
    expect(notificationTime(_now.subtract(const Duration(seconds: 20)), _now), 'chiar acum');
    expect(notificationTime(_now.subtract(const Duration(minutes: 10)), _now), 'acum 10 min');
    expect(notificationTime(_now.subtract(const Duration(hours: 1)), _now), 'acum 1 h');
    expect(notificationTime(DateTime(2026, 11, 7, 18), _now), '7 nov');
    expect(notificationTime(DateTime(2026, 11, 8, 23), _now), '8 nov');
    expect(notificationTime(null, _now), '');
    expect(notificationTime(_now.add(const Duration(minutes: 3)), _now), 'chiar acum');
  });

  group('where a tap goes', () {
    bool loaded(String id) => id == 'e1';
    NotificationTarget target(AppNotification n) => notificationTarget(n, eventLoaded: loaded);

    test('a chat message opens the chat', () {
      final t = target(_n(NotificationKind.chat, eventId: 'e9', teamName: 'Vulpile'));
      expect(t, isA<OpenChat>());
      expect(((t as OpenChat).eventId, t.teamName), ('e9', 'Vulpile'));
      expect(target(_n(NotificationKind.chat, eventId: 'e9')), isA<StayHere>());
    });

    test('results open the memory', () {
      expect(target(_n(NotificationKind.results, eventId: 'e9')), isA<OpenMemory>());
      expect(target(_n(NotificationKind.results)), isA<StayHere>());
    });

    test('a team or an announcement opens a loaded event', () {
      expect(target(_n(NotificationKind.team, eventId: 'e1')), isA<OpenEvent>());
      expect(target(_n(NotificationKind.announcement, eventId: 'e1')), isA<OpenEvent>());
      expect(target(_n(NotificationKind.announcement, eventId: 'e9')), isA<StayHere>());
      expect(target(_n(NotificationKind.team, eventId: 'e9')), isA<StayHere>());
    });

    test('a team with no event opens Echipe; others stay', () {
      expect(target(_n(NotificationKind.team)), isA<OpenTeams>());
      expect(target(_n(NotificationKind.announcement)), isA<StayHere>());
      expect(target(_n(NotificationKind.other, eventId: 'e1')), isA<StayHere>());
    });
  });
}
