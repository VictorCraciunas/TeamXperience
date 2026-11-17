import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/backend/repo/news_category_repo.dart';
import 'package:teamxperience/enums/stire_type.dart';
import 'package:teamxperience/features/news_dashboard/controller/stiri_dashboard_controller.dart';
import 'package:teamxperience/features/news_dashboard/logic/news_filters.dart';
import 'package:teamxperience/model/newsCategory.dart';
import 'package:teamxperience/model/stire.dart';

class _FakeCategoryRepo extends Fake implements NewsCategoryRepo {
  _FakeCategoryRepo(this.stored);

  final List<NewsCategory> stored;
  int loads = 0;

  @override
  Future<List<NewsCategory>> getAllCategories() async {
    loads++;
    return stored;
  }

  @override
  Future<String> getNewCategoryId() async => 'new';

  @override
  Future<void> createCategory(NewsCategory category) async => stored.add(category);

  @override
  Future<void> deleteCategory(String id) async => stored.removeWhere((c) => c.id == id);
}

Stire _s(String id, {StireType type = StireType.PUBLICA, String? category, DateTime? date}) => Stire(
  id: id,
  title: id,
  type: type,
  category: category == null ? null : NewsCategory(name: category),
  publicationDate: date,
);

final _news = [
  _s('a', category: 'Rezultate', date: DateTime(2026, 11, 10)),
  _s('b', category: 'Evenimente', type: StireType.PRIVATA, date: DateTime(2026, 11, 16)),
  _s('c', category: 'Rezultate', type: StireType.PRIVATA, date: DateTime(2026, 11, 12)),
];

List<String?> _ids(Iterable<Stire> list) => list.map((s) => s.id).toList();

void main() {
  late _FakeCategoryRepo repo;
  late StiriDashboardController c;
  late int notified;

  setUp(() {
    repo = _FakeCategoryRepo([NewsCategory(id: '1', name: 'Gol'), NewsCategory(id: '2', name: 'Rezultate')]);
    c = StiriDashboardController(categoryRepo: repo);
    notified = 0;
    c.addListener(() => notified++);
  });

  test('shows everything, newest first, until a filter is chosen', () {
    expect(_ids(c.shown(_news)), ['b', 'c', 'a']);
  });

  test('the type chips filter, and their counts ignore the chosen type', () {
    c.setType(NewsTypeFilter.private);
    expect(_ids(c.shown(_news)), ['b', 'c']);
    final counts = c.counts(_news);
    expect([counts.all, counts.public, counts.private], [3, 1, 2]);
    expect(notified, 1);
  });

  test('the counts follow the other filters', () {
    c.setCategory('Rezultate');
    final counts = c.counts(_news);
    expect([counts.all, counts.public, counts.private], [2, 1, 1]);
  });

  test('a category chip filters; Toate (null) clears it', () {
    c.setCategory('rezultate');
    expect(_ids(c.shown(_news)), ['c', 'a']);
    c.setCategory(null);
    expect(_ids(c.shown(_news)), ['b', 'c', 'a']);
  });

  test('categories: saved ones plus the ones in use, loaded once unless forced', () async {
    await c.loadCategories();
    await c.loadCategories();
    expect(repo.loads, 1);
    expect(c.categoriesFor(_news), ['Evenimente', 'Gol', 'Rezultate']);
    expect(c.playerCategories(_news), ['Evenimente', 'Rezultate']);
    await c.loadCategories(force: true);
    expect(repo.loads, 2);
  });
}
