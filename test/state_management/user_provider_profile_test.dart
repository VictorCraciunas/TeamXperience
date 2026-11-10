import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/model/user.dart';
import 'package:teamxperience/model/user_stats.dart';
import 'package:teamxperience/state_management/user_provider.dart';

class _FakeFirebaseUser implements User {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

AppUser _user(String uid, {int xp = 0}) =>
    AppUser(email: 'v@x.ro', firstName: 'Victor', lastName: 'C', uid: uid, fcmToken: '', xp: xp);

void main() {
  test('a fresh profile updates the numbers and tells the listeners once', () {
    final provider = UserProvider()..setUser(_user('vc'), _FakeFirebaseUser());
    var notified = 0;
    provider.addListener(() => notified++);
    provider.updateProfile(_user('vc').copyWith(xp: 640, stats: const UserStats(games: 3), badges: ['km10']));
    final user = provider.currentUser;
    expect((user?.xp, user?.stats.games), (640, 3));
    expect(user?.badges, ['km10']);
    expect(notified, 1);
  });

  test('takes the events the server signed them up to', () {
    final provider = UserProvider()..setUser(_user('vc'), _FakeFirebaseUser());
    provider.updateProfile(_user('vc').copyWith(registeredEventIds: ['e1']));
    expect(provider.currentUser?.registeredEventIds, ['e1']);
  });

  test('keeps everything else about the signed-in user', () {
    final provider = UserProvider()..setUser(_user('vc').copyWith(fcmToken: 'tok'), _FakeFirebaseUser());
    provider.updateProfile(_user('vc', xp: 10).copyWith(fcmToken: 'other'));
    expect(provider.currentUser?.fcmToken, 'tok');
    expect(provider.firebaseUser, isNotNull);
  });

  test('another user\'s numbers, or nobody signed in: ignored', () {
    final provider = UserProvider();
    var notified = 0;
    provider.addListener(() => notified++);
    provider.updateProfile(_user('vc', xp: 10));
    expect(provider.currentUser, isNull);
    provider.setUser(_user('vc'), _FakeFirebaseUser());
    notified = 0;
    provider.updateProfile(_user('altcineva', xp: 999));
    expect(provider.currentUser?.xp, 0);
    expect(notified, 0);
  });
}
