import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/model/team.dart';

Map<String, dynamic> _team([Object? photos]) => {
      'name': 'Vulpile',
      'userIds': ['u1'],
      if (photos != null) 'teamPhotos': photos,
    };

void main() {
  test('reads both photos', () {
    final team = Team.fromMap(_team({
      'start': {'url': 'a', 'by': 'u1'},
      'finish': {'url': 'b', 'by': 'u2'},
    }));
    expect(team.startPhotoUrl, 'a');
    expect(team.finishPhotoUrl, 'b');
  });

  test('older teams and bad data have none', () {
    expect(Team.fromMap(_team()).startPhotoUrl, isNull);
    expect(Team.fromMap(_team('x')).finishPhotoUrl, isNull);
    expect(Team.fromMap(_team({'start': {'url': 7}})).startPhotoUrl, isNull);
    expect(Team.fromMap(_team({'start': 'a'})).startPhotoUrl, isNull);
  });

  test('toJson never writes them', () {
    final team = Team.fromMap(_team({'start': {'url': 'a'}}));
    expect(team.toJson().containsKey('teamPhotos'), isFalse);
  });
}
