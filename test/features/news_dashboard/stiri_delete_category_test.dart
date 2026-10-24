import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/backend/repo/news_category_repo.dart';
import 'package:teamxperience/features/news_dashboard/controller/stiri_dashboard_controller.dart';
import 'package:teamxperience/model/newsCategory.dart';
import 'package:teamxperience/model/stire.dart';

class _Repo extends Fake implements NewsCategoryRepo {
  _Repo(this.stored, {this.failDelete = false, this.failLoad = false});

  final List<NewsCategory> stored;
  final bool failDelete;
  final bool failLoad;
  final deleted = <String>[];

  @override
  Future<List<NewsCategory>> getAllCategories() async {
    if (failLoad) throw Exception('offline');
    return stored;
  }

  @override
  Future<void> deleteCategory(String id) async {
    if (failDelete) throw Exception('denied');
    deleted.add(id);
  }
}

Stire _stire(String category) => Stire(title: 't', category: NewsCategory(name: category));

void main() {
  test('deletes a saved category that no news uses', () async {
    final repo = _Repo([NewsCategory(id: 'c1', name: 'Povești')]);
    final result = await StiriDashboardController(categoryRepo: repo)
        .deleteCategory('Povești', [_stire('Anunțuri')]);
    expect(result.status, DeleteCategoryStatus.deleted);
    expect(repo.deleted, ['c1']);
  });

  test('matches the name ignoring case', () async {
    final repo = _Repo([NewsCategory(id: 'c1', name: 'Povești')]);
    final result = await StiriDashboardController(categoryRepo: repo).deleteCategory('povești', const []);
    expect(result.status, DeleteCategoryStatus.deleted);
  });

  test('refuses to delete a category used by news and says how many', () async {
    final repo = _Repo([NewsCategory(id: 'c1', name: 'Anunțuri')]);
    final result = await StiriDashboardController(categoryRepo: repo)
        .deleteCategory('Anunțuri', [_stire('anunțuri'), _stire('Anunțuri'), _stire('Alta')]);
    expect(result.status, DeleteCategoryStatus.inUse);
    expect(result.newsCount, 2);
    expect(repo.deleted, isEmpty);
  });

  test('a name with no saved category cannot be deleted', () async {
    final repo = _Repo([NewsCategory(id: 'c1', name: 'Altceva')]);
    final result = await StiriDashboardController(categoryRepo: repo).deleteCategory('Lipsă', const []);
    expect(result.status, DeleteCategoryStatus.notFound);
  });

  test('reports a failure when the delete does not work', () async {
    final repo = _Repo([NewsCategory(id: 'c1', name: 'Povești')], failDelete: true);
    final result = await StiriDashboardController(categoryRepo: repo).deleteCategory('Povești', const []);
    expect(result.status, DeleteCategoryStatus.failed);
  });

  test('reports a failure when the categories cannot be loaded', () async {
    final repo = _Repo(const [], failLoad: true);
    final result = await StiriDashboardController(categoryRepo: repo).deleteCategory('Povești', const []);
    expect(result.status, DeleteCategoryStatus.failed);
  });
}
