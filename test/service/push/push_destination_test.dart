import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/service/push/push_destination.dart';

void main() {
  group('pushDestination', () {
    PushDestination player(Map<String, dynamic> data) => pushDestination(data, isAdmin: false);
    PushDestination organiser(Map<String, dynamic> data) => pushDestination(data, isAdmin: true);

    test('a chat push opens that team\'s chat, for a player and an organiser', () {
      const data = {'type': 'chat_message', 'eventId': 'e1', 'teamName': 'Vulpile'};
      for (final target in [player(data), organiser(data)]) {
        expect(target, isA<PushChat>());
        final chat = target as PushChat;
        expect(chat.eventId, 'e1');
        expect(chat.teamName, 'Vulpile');
      }
    });

    test('a chat entry from the notification list counts as a chat too', () {
      expect(player({'type': 'chat', 'eventId': 'e1', 'teamName': 'Vulpile'}), isA<PushChat>());
    });

    test('a chat push missing its event or team goes to the list', () {
      expect(player({'type': 'chat_message', 'eventId': 'e1'}), isA<PushNotifications>());
      expect(player({'type': 'chat_message', 'teamName': 'Vulpile', 'eventId': ''}), isA<PushNotifications>());
    });

    test('results open the memory of that game', () {
      final target = player({'type': 'results', 'eventId': 'e1'});
      expect(target, isA<PushMemory>());
      expect((target as PushMemory).eventId, 'e1');
    });

    test('an organiser\'s push or a team push about an event opens the event', () {
      for (final type in ['admin_notification', 'announcement', 'team']) {
        final target = player({'type': type, 'eventId': 'e2'});
        expect(target, isA<PushEvent>(), reason: type);
        expect((target as PushEvent).eventId, 'e2');
      }
    });

    test('anything without an event goes to the list', () {
      expect(player({'type': 'admin_notification'}), isA<PushNotifications>());
      expect(player({'type': 'team'}), isA<PushNotifications>());
      expect(player({}), isA<PushNotifications>());
      expect(player({'type': 'something-new', 'eventId': 5}), isA<PushNotifications>());
    });

    test('an unknown type with an event still opens the event', () {
      expect(player({'type': 'something-new', 'eventId': 'e3'}), isA<PushEvent>());
    });

    test('an organiser only follows chat pushes: the list is the players\'', () {
      expect(organiser({'type': 'admin_notification', 'eventId': 'e1'}), isA<PushNowhere>());
      expect(organiser({'type': 'results', 'eventId': 'e1'}), isA<PushNowhere>());
      expect(organiser({}), isA<PushNowhere>());
    });
  });

  group('the payload of a notification shown in the app', () {
    test('goes there and back', () {
      const data = {'type': 'chat_message', 'eventId': 'e1', 'teamName': 'Ăla Mare'};
      expect(pushDataFromPayload(pushPayload(data)), data);
    });

    test('a missing or broken payload is empty', () {
      expect(pushDataFromPayload(null), isEmpty);
      expect(pushDataFromPayload(''), isEmpty);
      expect(pushDataFromPayload('not json'), isEmpty);
      expect(pushDataFromPayload('[1, 2]'), isEmpty);
    });
  });
}
