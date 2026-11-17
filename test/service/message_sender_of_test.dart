import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/model/user.dart';
import 'package:teamxperience/service/message_service.dart';

AppUser _user({String uid = 'u1', String first = 'Ana', String last = 'Pop'}) =>
    AppUser(email: 'a@x.ro', firstName: first, lastName: last, uid: uid, fcmToken: '');

void main() {
  test('a player signs a message with their uid and first name', () {
    final from = senderOf(_user());
    expect(from.uid, 'u1');
    expect(from.name, 'Ana');
  });

  test('without a first name the full name is used; nothing is left blank', () {
    expect(senderOf(_user(first: ' ', last: 'Pop')).name, 'Pop');
    final none = senderOf(_user(uid: '', first: '', last: ''));
    expect(none.uid, isNull);
    expect(none.name, isNull);
  });
}
