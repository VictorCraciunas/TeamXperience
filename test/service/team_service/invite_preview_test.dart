import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/service/team_service/invite_preview.dart';
import 'package:teamxperience/utils/event_formats.dart';

Map<String, dynamic> _map({int? count, int size = 4}) => {
  'crewId': 'c1',
  'crewName': 'Vulpile',
  'captainName': 'Victor Crăciunaș',
  'members': [
    {'uid': 'u1', 'displayName': 'Victor Crăciunaș', 'initials': 'VC'},
  ],
  'alreadyMember': false,
  if (count != null)
    'event': {
      'eventId': 'e1',
      'name': 'Vânătoarea de comori',
      'dateEvent': '2026-11-20T15:00:00.000Z',
      'teamName': 'Vulpile',
      'size': size,
      'count': count,
    },
};

void main() {
  test('fromMap reads the crew and its members', () {
    final preview = InvitePreview.fromMap(_map(count: 1));
    expect(preview.crewId, 'c1');
    expect(preview.crewName, 'Vulpile');
    expect(preview.captainName, 'Victor Crăciunaș');
    expect(preview.members.single.initials, 'VC');
    expect(preview.alreadyMember, isFalse);
  });

  test('fromMap reads the event', () {
    final event = InvitePreview.fromMap(_map(count: 1)).event;
    expect(event, isNotNull);
    expect(event?.eventId, 'e1');
    expect(event?.name, 'Vânătoarea de comori');
    expect(
      event?.dateEvent.isAtSameMomentAs(
        DateTime.parse('2026-11-20T15:00:00.000Z'),
      ),
      isTrue,
    );
    expect(event?.teamName, 'Vulpile');
    expect(event?.size, 4);
    expect(event?.count, 1);
  });

  test('without an event there is no slot line', () {
    final preview = InvitePreview.fromMap(_map());
    expect(preview.event, isNull);
    expect(preview.slotLine, isNull);
    expect(preview.isFull, isFalse);
  });

  test('slotLine uses Romanian ordinals', () {
    expect(
      InvitePreview.fromMap(_map(count: 0)).slotLine,
      '0 din 4 · tu ești primul',
    );
    expect(
      InvitePreview.fromMap(_map(count: 1)).slotLine,
      '1 din 4 · tu ești al 2-lea',
    );
    expect(
      InvitePreview.fromMap(_map(count: 2)).slotLine,
      '2 din 4 · tu ești al 3-lea',
    );
  });

  test('isFull when the team has no room', () {
    expect(InvitePreview.fromMap(_map(count: 3)).isFull, isFalse);
    expect(InvitePreview.fromMap(_map(count: 4)).isFull, isTrue);
  });

  test('the event date is local time, so it reads right on screen', () {
    final map = _map(count: 1);
    (map['event'] as Map<String, dynamic>)['dateEvent'] =
        '2026-11-14T08:00:00.000Z';
    final date = InvitePreview.fromMap(map).event!.dateEvent;
    expect(date.isUtc, isFalse);
    expect(
      shortDateTime(date),
      shortDateTime(DateTime.utc(2026, 11, 14, 8).toLocal()),
    );
  });
}
