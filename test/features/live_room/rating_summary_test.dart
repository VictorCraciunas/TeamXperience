import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/live_room/logic/live_texts.dart';
import 'package:teamxperience/features/live_room/logic/rating_summary.dart';

void main() {
  group('ratingSummary', () {
    test('no ratings: nothing to average', () {
      final s = ratingSummary(const []);
      expect(s.count, 0);
      expect(s.average, isNull);
      expect(s.byStars, [0, 0, 0, 0, 0]);
    });

    test('average, count and how many gave each star', () {
      final s = ratingSummary(const [5, 5, 4, 3, 5]);
      expect(s.count, 5);
      expect(s.average, closeTo(4.4, 1e-9));
      expect(s.byStars, [0, 0, 1, 1, 3]);
      expect(s.of(5), 3);
      expect(s.of(1), 0);
    });

    test('values outside 1-5 are left out', () {
      final s = ratingSummary(const [0, 6, -1, 2, 4]);
      expect(s.count, 2);
      expect(s.average, 3);
      expect(s.byStars, [0, 1, 0, 1, 0]);
    });
  });

  group('rating texts', () {
    test('the average with a comma, one decimal', () {
      expect(ratingAverageText(4.44), '4,4');
      expect(ratingAverageText(4.45), '4,5');
      expect(ratingAverageText(5), '5,0');
    });

    test('how many rated, in Romanian', () {
      expect(ratingCountLine(1), 'dintr-o notă');
      expect(ratingCountLine(3), 'din 3 note');
      expect(ratingCountLine(19), 'din 19 note');
      expect(ratingCountLine(20), 'din 20 de note');
      expect(ratingCountLine(101), 'din 101 note');
    });
  });
}
