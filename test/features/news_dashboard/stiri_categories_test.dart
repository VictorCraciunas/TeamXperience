import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/backend/repo/news_category_repo.dart';
import 'package:teamxperience/features/news_dashboard/controller/stiri_dashboard_controller.dart';
import 'package:teamxperience/model/newsCategory.dart';
import 'package:teamxperience/model/stire.dart';

class _FakeCategoryRepo extends Fake implements NewsCategoryRepo {
  _FakeCategoryRepo({this.stored = const [], this.failLoad = false, this.failCreate = false});

  final List<NewsCategory> stored;
  final bool failLoad;
  final bool failCreate;
  final created = <NewsCategory>[];

  @override
  Future<List<NewsCategory>> getAllCategories() async {
    if (failLoad) throw Exception('offline');
    return stored;
  }

  @override
  Future<String> getNewCategoryId() async => 'id-${created.length + 1}';

  @override
  Future<void> createCategory(NewsCategory category) async {
    if (failCreate) throw Exception('denied');
    created.add(category);
  }
}

Stire _stire(String? category) =>
    Stire(title: 't', category: category == null ? null : NewsCategory(name: category));

void main() {
  group('categoryNames', () {
    test('merges stored categories with the ones used by news, sorted, without repeats', () async {
      final c = StiriDashboardController(
        categoryRepo: _FakeCategoryRepo(
          stored: [NewsCategory(name: 'Rezultate'), NewsCategory(name: 'anunțuri')],
        ),
      );
      final names = await c.categoryNames([_stire('Anunțuri'), _stire('Povești'), _stire(null)]);
      expect(names, ['Anunțuri', 'Povești', 'Rezultate']);
    });

    test('falls back to the categories of the news when loading fails', () async {
      final c = StiriDashboardController(categoryRepo: _FakeCategoryRepo(failLoad: true));
      expect(await c.categoryNames([_stire('Anunțuri')]), ['Anunțuri']);
    });
  });

  group('addCategory', () {
    test('creates the category with a new id and reports it', () async {
      final repo = _FakeCategoryRepo();
      final c = StiriDashboardController(categoryRepo: repo);
      final result = await c.addCategory('  Povești ', const ['Anunțuri']);
      expect(result.status, AddCategoryStatus.added);
      expect(result.name, 'Povești');
      expect(repo.created.single.id, 'id-1');
      expect(repo.created.single.name, 'Povești');
    });

    test('rejects an empty name', () async {
      final repo = _FakeCategoryRepo();
      final result = await StiriDashboardController(categoryRepo: repo).addCategory('   ', const []);
      expect(result.status, AddCategoryStatus.empty);
      expect(repo.created, isEmpty);
    });

    test('rejects a name that already exists, ignoring case', () async {
      final repo = _FakeCategoryRepo();
      final result =
          await StiriDashboardController(categoryRepo: repo).addCategory('anunțuri', const ['Anunțuri']);
      expect(result.status, AddCategoryStatus.duplicate);
      expect(repo.created, isEmpty);
    });

    test('reports a failure when saving does not work', () async {
      final result = await StiriDashboardController(
        categoryRepo: _FakeCategoryRepo(failCreate: true),
      ).addCategory('Nou', const []);
      expect(result.status, AddCategoryStatus.failed);
    });
  });
}
