import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/news_dashboard/logic/news_reading_time.dart';

String _words(int n) => List.filled(n, 'cuvânt').join(' ');

void main() {
  group('readingMinutes', () {
    test('words / 200, rounded up', () {
      expect(readingMinutes(_words(200)), 1);
      expect(readingMinutes(_words(201)), 2);
      expect(readingMinutes(_words(600)), 3);
      expect(readingMinutes(_words(601)), 4);
    });

    test('at least one minute, also for no text', () {
      expect(readingMinutes(null), 1);
      expect(readingMinutes(''), 1);
      expect(readingMinutes('   \n '), 1);
      expect(readingMinutes('Scurt.'), 1);
    });

    test('any run of spaces, tabs or new lines separates two words', () {
      final text = List.filled(201, 'a').join(' \n\t  ');
      expect(readingMinutes(text), 2);
    });
  });

  test('readingTimeText', () {
    expect(readingTimeText(_words(450)), '3 min de citit');
    expect(readingTimeText(null), '1 min de citit');
  });
}
