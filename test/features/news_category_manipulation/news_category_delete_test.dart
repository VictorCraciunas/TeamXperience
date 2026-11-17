import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/backend/repo/news_category_repo.dart';
import 'package:teamxperience/features/news_category_manipulation/controller/news_category_controller.dart';
import 'package:teamxperience/model/newsCategory.dart';
import 'package:teamxperience/model/stire.dart';

class _Repo extends Fake implements NewsCategoryRepo {
  _Repo(this.stored, {this.failDelete = false});

  final List<NewsCategory> stored;
  final bool failDelete;
  final deleted = <String>[];

  @override
  Future<List<NewsCategory>> getAllCategories() async => stored;

  @override
  Future<void> deleteCategory(String id) async {
    if (failDelete) throw Exception('denied');
    deleted.add(id);
  }
}

Stire _stire(String category) => Stire(title: 't', category: NewsCategory(name: category));

Future<NewsCategoryController> _loaded(_Repo repo) async {
  final controller = NewsCategoryController(categoryRepo: repo);
  await controller.loadCategories();
  return controller;
}

void main() {
  test('deletes a category no news uses and drops it from the list', () async {
    final povesti = NewsCategory(id: 'c1', name: 'Povești');
    final repo = _Repo([povesti, NewsCategory(id: 'c2', name: 'Anunțuri')]);
    final controller = await _loaded(repo);

    final result = await controller.deleteCategory(povesti, [_stire('Anunțuri')]);

    expect(result.status, DeleteCategoryStatus.deleted);
    expect(repo.deleted, ['c1']);
    expect(controller.filteredCategories.map((c) => c.name), ['Anunțuri']);
  });

  test('refuses a category news still use, ignoring case, and says how many', () async {
    final anunturi = NewsCategory(id: 'c1', name: 'Anunțuri');
    final repo = _Repo([anunturi]);
    final controller = await _loaded(repo);

    final result = await controller.deleteCategory(anunturi, [_stire('anunțuri'), _stire('Anunțuri'), _stire('Alta')]);

    expect(result.status, DeleteCategoryStatus.inUse);
    expect(result.newsCount, 2);
    expect(repo.deleted, isEmpty);
    expect(controller.filteredCategories, hasLength(1));
  });

  test('deleting the selected category clears the selection', () async {
    final povesti = NewsCategory(id: 'c1', name: 'Povești');
    final controller = await _loaded(_Repo([povesti]));
    controller.selectCategory(povesti);

    await controller.deleteCategory(povesti, const []);

    expect(controller.selectedCategory, isNull);
  });

  test('a failed delete keeps the category', () async {
    final povesti = NewsCategory(id: 'c1', name: 'Povești');
    final controller = await _loaded(_Repo([povesti], failDelete: true));

    final result = await controller.deleteCategory(povesti, const []);

    expect(result.status, DeleteCategoryStatus.failed);
    expect(controller.filteredCategories, hasLength(1));
  });

  test('a category without an id cannot be deleted', () async {
    final controller = await _loaded(_Repo([]));
    final result = await controller.deleteCategory(NewsCategory(name: 'Fără id'), const []);
    expect(result.status, DeleteCategoryStatus.failed);
  });
}
