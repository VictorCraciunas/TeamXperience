import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/model/team.dart';

Team _team(Object? unread) => Team.fromMap({'name': 'Lupii', if (unread != null) 'unreadByAdmin': unread});

void main() {
  group('Team.unreadCount', () {
    test('the stored count', () {
      expect(_team({'text': 'Alo', 'count': 3}).unreadCount, 3);
    });

    test('a mark from before the count: one message', () {
      expect(_team({'text': 'Alo'}).unreadCount, 1);
    });

    test('nothing unread: none, whatever else is stored', () {
      expect(_team(null).unreadCount, 0);
      expect(_team({'count': 2}).unreadCount, 0);
      expect(_team(true).unreadCount, 0);
    });

    test('a broken count still says there is something to read', () {
      expect(_team({'text': 'Alo', 'count': 0}).unreadCount, 1);
      expect(_team({'text': 'Alo', 'count': 'x'}).unreadCount, 1);
      expect(_team({'text': 'Alo', 'count': 2.0}).unreadCount, 2);
    });

    test('toJson never writes it', () {
      expect(_team({'text': 'Alo', 'count': 2}).toJson().containsKey('unreadByAdmin'), isFalse);
    });
  });
}
