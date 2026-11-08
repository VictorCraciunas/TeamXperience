import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/model/user.dart';
import 'package:teamxperience/model/user_stats.dart';

Map<String, dynamic> _base() => {'firstName': 'Victor', 'lastName': 'Crăciunaș', 'email': 'v@x.ro', 'uid': 'vc'};

void main() {
  group('UserStats', () {
    test('reads games, distance, missions and podiums', () {
      final stats = UserStats.fromMap({'games': 3, 'distanceMeters': 12400, 'missions': 17, 'podiums': 1});
      expect((stats.games, stats.distanceMeters, stats.missions, stats.podiums), (3, 12400.0, 17, 1));
    });

    test('numbers that are not finite are zero', () {
      final stats = UserStats.fromMap({'games': double.nan, 'distanceMeters': double.infinity, 'missions': double.infinity});
      expect((stats.games, stats.distanceMeters, stats.missions), (0, 0.0, 0));
    });

    test('anything unreadable is zero', () {
      for (final raw in [null, 'x', 7, <String, dynamic>{}, {'games': 'trei', 'podiums': null}]) {
        final stats = UserStats.fromMap(raw);
        expect((stats.games, stats.distanceMeters, stats.missions, stats.podiums), (0, 0.0, 0, 0), reason: '$raw');
      }
    });
  });

  group('AppUser', () {
    test('an unreadable xp is zero, it does not lock the player out', () {
      for (final xp in ['640', double.nan, double.infinity, null, true]) {
        expect(AppUser.fromFirestore({..._base(), 'xp': xp}).xp, 0, reason: '$xp');
      }
      expect(AppUser.fromFirestore({..._base(), 'xp': 640}).xp, 640);
    });

    test('reads the earned badges', () {
      final user = AppUser.fromFirestore({..._base(), 'badges': ['km10', 'noHints']});
      expect(user.badges, ['km10', 'noHints']);
    });

    test('no badges field, or one that is not a list: none; non-text ids are skipped', () {
      expect(AppUser.fromFirestore(_base()).badges, isEmpty);
      expect(AppUser.fromFirestore({..._base(), 'badges': 'km10'}).badges, isEmpty);
      expect(AppUser.fromFirestore({..._base(), 'badges': [1, 'noHints', null]}).badges, ['noHints']);
    });

    test('toJson never writes xp, stats or badges (only the end-of-event function does)', () {
      final user = AppUser.fromFirestore({
        ..._base(),
        'xp': 640,
        'stats': {'games': 3},
        'badges': ['km10'],
      });
      final json = user.toJson();
      expect(json.containsKey('xp'), isFalse);
      expect(json.containsKey('stats'), isFalse);
      expect(json.containsKey('badges'), isFalse);
    });

    test('copyWith changes xp, stats and badges and keeps the rest', () {
      final user = AppUser.fromFirestore({..._base(), 'registeredEventIds': ['e1'], 'fcmToken': 't'});
      final fresh = user.copyWith(xp: 640, stats: const UserStats(games: 3), badges: ['km10']);
      expect((fresh.xp, fresh.stats.games), (640, 3));
      expect(fresh.badges, ['km10']);
      expect(fresh.uid, 'vc');
      expect(fresh.registeredEventIds, ['e1']);
      expect(fresh.fcmToken, 't');
      expect(user.copyWith(fcmToken: 'u').xp, user.xp);
    });
  });
}
