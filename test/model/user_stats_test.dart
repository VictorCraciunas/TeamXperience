import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/model/user.dart';

Map<String, dynamic> _base() => {
      'email': 'v@x.ro',
      'firstName': 'Victor',
      'lastName': 'C',
      'uid': 'u1',
    };

void main() {
  test('reads xp and stats', () {
    final user = AppUser.fromFirestore({
      ..._base(),
      'xp': 620,
      'stats': {'games': 3, 'distanceMeters': 12400},
    });
    expect(user.xp, 620);
    expect(user.stats.games, 3);
    expect(user.stats.distanceMeters, 12400.0);
  });

  test('without them they are zero', () {
    final user = AppUser.fromFirestore(_base());
    expect(user.xp, 0);
    expect(user.stats.games, 0);
    expect(user.stats.distanceMeters, 0.0);
  });

  test('copyWith keeps xp and stats', () {
    final user = AppUser.fromFirestore({
      ..._base(),
      'xp': 620,
      'stats': {'games': 3, 'distanceMeters': 12400},
    });
    final copy = user.copyWith(registeredEventIds: ['e']);
    expect(copy.registeredEventIds, ['e']);
    expect(copy.xp, 620);
    expect(copy.stats.games, 3);
    expect(copy.firstName, 'Victor');
  });
}
