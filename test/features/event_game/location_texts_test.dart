import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/event_game/logic/location_texts.dart';
import 'package:teamxperience/model/puzzle.dart';

void main() {
  test('compass words, eight ways', () {
    expect(compassWord(0), 'nord');
    expect(compassWord(40), 'nord-est');
    expect(compassWord(90), 'est');
    expect(compassWord(135), 'sud-est');
    expect(compassWord(200), 'sud');
    expect(compassWord(-90), 'vest');
    expect(compassWord(-135), 'sud-vest');
    expect(compassWord(-40), 'nord-vest');
    expect(compassWord(337.6), 'nord');
    expect(compassWord(-180), 'sud');
  });

  test('the walk line at 80 m a minute, at least a minute', () {
    expect(walkLine(140, 40), 'spre nord-est · ~2 min pe jos');
    expect(walkLine(10, 0), 'spre nord · ~1 min pe jos');
    expect(walkLine(800, 180), 'spre sud · ~10 min pe jos');
  });

  test('the short distance', () {
    expect(shortDistance(143), '140 m');
    expect(shortDistance(1234), '1,2 km');
    expect(shortDistance(996), '1,0 km');
    expect(shortDistance(12), 'câțiva metri');
  });

  group('trendOf', () {
    test('closer by 3 m or more over the last three readings', () {
      expect(trendOf([150, 146, 140]), DistanceTrend.closer);
    });

    test('under 3 m, or fewer than three readings: nothing', () {
      expect(trendOf([140, 141, 142]), isNull);
      expect(trendOf([140, 150]), isNull);
      expect(trendOf([]), isNull);
    });

    test('only the last three count', () {
      expect(trendOf([200, 150, 152, 160]), DistanceTrend.farther);
    });

    test('the labels', () {
      expect(trendLabel(DistanceTrend.closer), 'mai aproape');
      expect(trendLabel(DistanceTrend.farther), 'mai departe');
      expect(trendLabel(null), isNull);
    });
  });

  test('a target needs both coordinates', () {
    expect(locationTarget(Puzzle(id: '0', type: PuzzleType.geolocation, latitude: 45.79)), isNull);
    expect(
      locationTarget(Puzzle(id: '0', type: PuzzleType.geolocation, latitude: 45.79, longitude: 24.15)),
      (lat: 45.79, lng: 24.15),
    );
  });

  test('inside the circle includes its edge', () {
    expect(insideCircle(20, 20), isTrue);
    expect(insideCircle(20.1, 20), isFalse);
  });
}
