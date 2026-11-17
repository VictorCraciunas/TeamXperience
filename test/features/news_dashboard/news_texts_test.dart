import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/stire_type.dart';
import 'package:teamxperience/features/news_dashboard/logic/news_texts.dart';
import 'package:teamxperience/model/newsCategory.dart';
import 'package:teamxperience/model/stire.dart';

final _now = DateTime(2026, 11, 17, 12);

void main() {
  group('newsDateText', () {
    test('day and short month in the current year', () {
      expect(newsDateText(DateTime(2026, 11, 16, 9), _now), '16 nov');
      expect(newsDateText(DateTime(2026, 1, 2), _now), '2 ian');
    });

    test('adds the year for another year', () {
      expect(newsDateText(DateTime(2025, 12, 30), _now), '30 dec 2025');
    });

    test('nothing without a date', () {
      expect(newsDateText(null, _now), '');
    });
  });

  group('featuredMeta', () {
    test('date and reading time', () {
      final s = Stire(publicationDate: DateTime(2026, 11, 16), description: List.filled(500, 'x').join(' '));
      expect(featuredMeta(s, _now), '16 nov · 3 min de citit');
    });

    test('only the reading time without a date', () {
      expect(featuredMeta(Stire(description: 'Scurt.'), _now), '1 min de citit');
    });
  });

  group('category and type texts', () {
    test('the category name, or Necategorizat', () {
      expect(newsCategoryText(Stire(category: NewsCategory(name: ' Rezultate '))), 'Rezultate');
      expect(newsCategoryText(Stire(category: NewsCategory(name: ''))), 'Necategorizat');
      expect(newsCategoryText(Stire()), 'Necategorizat');
    });

    test('organiser row: category and date', () {
      final s = Stire(category: NewsCategory(name: 'Rezultate'), publicationDate: DateTime(2026, 11, 16));
      expect(adminRowMeta(s, _now), 'Rezultate · 16 nov');
      expect(adminRowMeta(Stire(category: NewsCategory(name: 'Noutăți')), _now), 'Noutăți');
    });

    test('isPrivateNews: only PRIVATA is private', () {
      expect(isPrivateNews(Stire(type: StireType.PRIVATA)), isTrue);
      expect(isPrivateNews(Stire(type: StireType.PUBLICA)), isFalse);
      expect(isPrivateNews(Stire()), isFalse);
    });

    test('player row: the category, marked when private', () {
      final c = NewsCategory(name: 'Evenimente');
      expect(playerRowCategory(Stire(category: c, type: StireType.PUBLICA)), 'Evenimente');
      expect(playerRowCategory(Stire(category: c, type: StireType.PRIVATA)), 'Evenimente · Privată');
    });

    test('newsTypeLabel', () {
      expect(newsTypeLabel(Stire(type: StireType.PRIVATA)), 'Privată');
      expect(newsTypeLabel(Stire(type: StireType.PUBLICA)), 'Publică');
      expect(newsTypeLabel(Stire()), 'Publică');
    });
  });

  test('newsCountLine uses Romanian counts', () {
    expect(newsCountLine(8, 3), '8 știri · 3 categorii');
    expect(newsCountLine(1, 1), '1 știre · 1 categorie');
    expect(newsCountLine(0, 0), '0 știri · 0 categorii');
    expect(newsCountLine(20, 101), '20 de știri · 101 categorii');
    expect(newsCountLine(119, 200), '119 știri · 200 de categorii');
  });

  test('chipLabel', () {
    expect(chipLabel('Toate', 8), 'Toate · 8');
  });
}
