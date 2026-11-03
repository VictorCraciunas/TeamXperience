import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';

void main() {
  test('title, teaser and the public flag survive toJson and fromMap', () {
    final m = Mission(id: '0', title: 'Scara Pasajului', teaser: 'Numără treptele.', isTeaserPublic: true);
    final back = Mission.fromMap(m.toJson());
    expect(back.title, 'Scara Pasajului');
    expect(back.teaser, 'Numără treptele.');
    expect(back.isTeaserPublic, isTrue);
  });

  test('an old mission reads as no title, no teaser, not public', () {
    final m = Mission.fromMap({'id': '0', 'puzzles': []});
    expect(m.title, isNull);
    expect(m.teaser, isNull);
    expect(m.isTeaserPublic, isFalse);
  });

  test('withId keeps everything but the id', () {
    final puzzles = [Puzzle(id: '0')];
    final m = Mission(id: '0', puzzles: puzzles, title: 'T', teaser: 'S', isTeaserPublic: true).withId('3');
    expect(m.id, '3');
    expect(m.puzzles, same(puzzles));
    expect(m.title, 'T');
    expect(m.teaser, 'S');
    expect(m.isTeaserPublic, isTrue);
  });
}
