import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/event_details/logic/event_page_content.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';

Mission _m(int i, {String? title, String? teaser, bool public = false, List<PuzzleType> types = const []}) => Mission(
      id: '$i',
      title: title,
      teaser: teaser,
      isTeaserPublic: public,
      puzzles: [for (var p = 0; p < types.length; p++) Puzzle(id: '$p', type: types[p])],
    );

void main() {
  group('mission teasers', () {
    test('public titled missions are shown with their number, the rest are secret', () {
      final event = Event(eventId: 'e', missions: [
        _m(0, title: 'Scara Pasajului', teaser: 'Numără treptele.', public: true),
        _m(1, title: 'Podul Minciunilor', public: true),
        _m(2, title: '  ', public: true),
        _m(3, title: 'Turnul Sfatului'),
        _m(4),
        _m(5),
      ]);
      final result = missionTeasers(event);
      expect(result.shown.map((t) => (t.number, t.title, t.teaser)),
          [(1, 'Scara Pasajului', 'Numără treptele.'), (2, 'Podul Minciunilor', '')]);
      expect(result.secret, 4);
    });

    test('an event with no missions has nothing to show', () {
      final result = missionTeasers(Event(eventId: 'e'));
      expect(result.shown, isEmpty);
      expect(result.secret, 0);
    });

    test('the secret line counts the missions', () {
      expect(secretMissionsLine(4), 'Încă 4 misiuni secrete');
      expect(secretMissionsLine(1), 'Încă o misiune secretă');
    });
  });

  group('puzzle kinds', () {
    test('kinds come in a fixed order, once each, only when present', () {
      final event = Event(eventId: 'e', missions: [
        _m(0, types: [PuzzleType.geolocation, PuzzleType.code]),
        _m(1, types: [PuzzleType.code, PuzzleType.redirect]),
      ]);
      expect(puzzleKinds(event), [PuzzleKind.codes, PuzzleKind.places]);
    });

    test('photos are a kind, and other types add nothing', () {
      final event = Event(eventId: 'e', missions: [
        _m(0, types: [PuzzleType.imageToUpload, PuzzleType.ar]),
      ]);
      expect(puzzleKinds(event), [PuzzleKind.photos]);
      expect(puzzleKinds(Event(eventId: 'e')), isEmpty);
    });

    test('labels', () {
      expect([for (final k in PuzzleKind.values) puzzleKindLabel(k)], ['Coduri', 'Fotografii', 'Locuri pe hartă']);
    });
  });
}
