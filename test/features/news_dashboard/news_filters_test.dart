import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/stire_type.dart';
import 'package:teamxperience/features/news_dashboard/logic/news_filters.dart';
import 'package:teamxperience/model/newsCategory.dart';
import 'package:teamxperience/model/stire.dart';

Stire _s(
  String id, {
  StireType? type = StireType.PUBLICA,
  String? category,
  DateTime? date,
  String? title,
  String? description,
}) => Stire(
  id: id,
  type: type,
  category: category == null ? null : NewsCategory(name: category),
  publicationDate: date,
  title: title ?? id,
  description: description,
);

List<String?> _ids(Iterable<Stire> list) => list.map((s) => s.id).toList();

void main() {
  final news = [
    _s('a', date: DateTime(2026, 11, 10), category: 'Rezultate'),
    _s('b', date: DateTime(2026, 11, 16), category: 'Evenimente', type: StireType.PRIVATA),
    _s('c', category: 'rezultate', type: null),
    _s('d', date: DateTime(2026, 11, 14), category: 'Noutăți', title: 'Sezonul de iarnă'),
  ];

  group('selectNews', () {
    test('everything, newest first, undated last', () {
      expect(_ids(selectNews(news, const NewsQuery())), ['b', 'd', 'a', 'c']);
    });

    test('by type: a news with no type counts as public', () {
      expect(_ids(selectNews(news, const NewsQuery(type: NewsTypeFilter.private))), ['b']);
      expect(_ids(selectNews(news, const NewsQuery(type: NewsTypeFilter.public))), ['d', 'a', 'c']);
    });

    test('by category, ignoring case and spaces', () {
      expect(_ids(selectNews(news, const NewsQuery(category: ' Rezultate'))), ['a', 'c']);
      expect(_ids(selectNews(news, const NewsQuery(category: ''))), ['b', 'd', 'a', 'c']);
    });

    test('by period: the last day counts until its end, undated news stay', () {
      final q = NewsQuery(start: DateTime(2026, 11, 14), end: DateTime(2026, 11, 16));
      expect(_ids(selectNews(news, q)), ['b', 'd', 'c']);
    });

    test('by search in title or description, ignoring case', () {
      final withText = [
        ...news,
        _s('e', description: 'Despre IARNĂ și altele', date: DateTime(2026, 1, 1)),
      ];
      expect(_ids(selectNews(withText, const NewsQuery(search: ' iarnă '))), ['d', 'e']);
      expect(_ids(selectNews(withText, const NewsQuery(search: 'sezonul'))), ['d']);
    });

    test('filters combine', () {
      const q = NewsQuery(type: NewsTypeFilter.public, category: 'rezultate');
      expect(_ids(selectNews(news, q)), ['a', 'c']);
    });
  });

  test('NewsQuery.copyWith keeps or clears fields', () {
    const q = NewsQuery(type: NewsTypeFilter.private, category: 'X', search: 'y');
    final changed = q.copyWith(type: NewsTypeFilter.all);
    expect(changed.type, NewsTypeFilter.all);
    expect(changed.category, 'X');
    expect(changed.search, 'y');
    expect(q.copyWith(category: null).category, isNull);
    expect(q.copyWith(search: '').search, '');
    expect(q.copyWith().category, 'X');
  });

  test('NewsQuery.hasCategory and hasPeriod', () {
    expect(const NewsQuery(category: ' ').hasCategory, isFalse);
    expect(const NewsQuery(category: 'X').hasCategory, isTrue);
    expect(NewsQuery(start: DateTime(2026)).hasPeriod, isFalse);
    expect(NewsQuery(start: DateTime(2026), end: DateTime(2026, 2)).hasPeriod, isTrue);
  });

  test('countByType', () {
    final counts = countByType(news);
    expect(counts.all, 4);
    expect(counts.public, 3);
    expect(counts.private, 1);
    expect(counts.of(NewsTypeFilter.private), 1);
    expect(counts.of(NewsTypeFilter.public), 3);
    expect(counts.of(NewsTypeFilter.all), 4);
  });

  group('splitFeatured', () {
    test('the first is featured, the rest follow', () {
      final split = splitFeatured(news);
      expect(split.featured?.id, 'a');
      expect(_ids(split.rest), ['b', 'c', 'd']);
    });

    test('nothing to feature in an empty list', () {
      final split = splitFeatured(const []);
      expect(split.featured, isNull);
      expect(split.rest, isEmpty);
    });
  });

  test('mergeCategoryNames: used and saved names, sorted, no repeats, spelling as the news use it', () {
    expect(
      mergeCategoryNames(['anunțuri', ' Gol ', ''], [
        _s('x', category: 'Anunțuri'),
        _s('y', category: 'Povești'),
        _s('z'),
      ]),
      ['Anunțuri', 'Gol', 'Povești'],
    );
  });

  test('categoriesWithNews keeps only names some news uses, ignoring case', () {
    expect(
      categoriesWithNews(['Evenimente', 'Gol', 'Rezultate', 'Noutăți'], news),
      ['Evenimente', 'Rezultate', 'Noutăți'],
    );
  });
}
