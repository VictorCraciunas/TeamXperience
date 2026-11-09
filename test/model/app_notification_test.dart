import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/model/app_notification.dart';

void main() {
  test('a full entry', () {
    final at = DateTime(2026, 11, 9, 14);
    final n = AppNotification.fromMap('n1', {
      'kind': 'chat',
      'title': 'Mesaj de la organizator',
      'body': 'Salut',
      'createdAt': Timestamp.fromDate(at),
      'read': false,
      'eventId': 'e1',
      'teamName': 'Vulpile',
    });
    expect(n.id, 'n1');
    expect(n.kind, NotificationKind.chat);
    expect((n.title, n.body, n.createdAt, n.read, n.eventId, n.teamName), ('Mesaj de la organizator', 'Salut', at, false, 'e1', 'Vulpile'));
  });

  test('an unknown kind still shows', () {
    expect(AppNotification.fromMap('a', {'kind': 'later', 'title': 'T'}).kind, NotificationKind.other);
  });

  test('bad data does not throw; a missing read counts as read', () {
    final n = AppNotification.fromMap('a', {'title': 7, 'read': 'x', 'createdAt': 'x', 'eventId': ''});
    expect(n.title, '');
    expect(n.read, isTrue);
    expect(n.createdAt, isNull);
    expect(n.eventId, isNull);
  });
}
