import 'package:flutter/material.dart';

import '../../../backend/repo/news_category_repo.dart';
import '../../../model/newsCategory.dart';
import '../../../model/stire.dart';
import '../logic/news_filters.dart';

/// How adding a category went.
enum AddCategoryStatus { added, empty, duplicate, failed }

class AddCategoryResult {
  const AddCategoryResult(this.status, [this.name = '']);

  final AddCategoryStatus status;

  /// The saved name when [status] is [AddCategoryStatus.added].
  final String name;
}

/// How deleting a category went.
enum DeleteCategoryStatus { deleted, inUse, notFound, failed }

class DeleteCategoryResult {
  const DeleteCategoryResult(this.status, [this.newsCount = 0]);

  final DeleteCategoryStatus status;

  /// How many news use the category when [status] is [DeleteCategoryStatus.inUse].
  final int newsCount;
}

/// The Știri list, for players and organisers: what is filtered, the saved
/// categories, and adding or deleting a category.
class StiriDashboardController extends ChangeNotifier {
  StiriDashboardController({NewsCategoryRepo? categoryRepo})
    : _injectedCategoryRepo = categoryRepo;

  final NewsCategoryRepo? _injectedCategoryRepo;
  late final NewsCategoryRepo _categoryRepo =
      _injectedCategoryRepo ?? NewsCategoryRepo();

  NewsQuery _query = const NewsQuery();
  bool _searchOpen = false;
  List<String> _saved = const [];
  bool _savedLoaded = false;
  bool _disposed = false;

  NewsQuery get query => _query;
  bool get searchOpen => _searchOpen;

  /// The news the list shows.
  List<Stire> shown(Iterable<Stire> news) => selectNews(news, _query);

  /// The type chips' counts, under every filter but the type.
  NewsTypeCounts counts(Iterable<Stire> news) =>
      countByType(selectNews(news, _query.copyWith(type: NewsTypeFilter.all)));

  /// Saved categories plus the ones [news] use.
  List<String> categoriesFor(Iterable<Stire> news) => mergeCategoryNames(_saved, news);

  /// The player's chips: only categories that have news.
  List<String> playerCategories(Iterable<Stire> news) =>
      categoriesWithNews(categoriesFor(news), news);

  void _set(NewsQuery query) {
    _query = query;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void setType(NewsTypeFilter type) => _set(_query.copyWith(type: type));

  /// Null shows every category.
  void setCategory(String? name) => _set(_query.copyWith(category: name));

  void setPeriod(DateTime? start, DateTime? end) => _set(_query.copyWith(start: start, end: end));

  void clearPeriod() => setPeriod(null, null);

  void setSearch(String text) => _set(_query.copyWith(search: text));

  void clearSearch() => setSearch('');

  /// Opens or closes the search field; closing it clears the search.
  void toggleSearch() {
    _searchOpen = !_searchOpen;
    if (!_searchOpen) {
      _query = _query.copyWith(search: '');
    }
    _notify();
  }

  /// Reads the saved categories (once, unless [force]). If that fails, only
  /// the categories in use show.
  Future<void> loadCategories({bool force = false}) async {
    if (_savedLoaded && !force) return;
    try {
      _saved = [for (final c in await _categoryRepo.getAllCategories()) c.name];
      _savedLoaded = true;
    } catch (_) {
      // Keep what we had; the news still give their own categories.
    }
    _notify();
  }

  /// All category names: the saved ones plus any used by [news], sorted and
  /// without repeats (ignoring case). If loading fails, only those used by news.
  Future<List<String>> categoryNames(Iterable<Stire> news) async {
    await loadCategories(force: true);
    return categoriesFor(news);
  }

  /// Saves a new category unless it is empty or already in [existing].
  Future<AddCategoryResult> addCategory(
    String rawName,
    Iterable<String> existing,
  ) async {
    final name = rawName.trim();
    if (name.isEmpty) return const AddCategoryResult(AddCategoryStatus.empty);

    final lower = name.toLowerCase();
    if (existing.any((e) => e.trim().toLowerCase() == lower)) {
      return const AddCategoryResult(AddCategoryStatus.duplicate);
    }

    try {
      final category = NewsCategory(name: name);
      category.id = await _categoryRepo.getNewCategoryId();
      await _categoryRepo.createCategory(category);
      _saved = [..._saved, name];
      _notify();
      return AddCategoryResult(AddCategoryStatus.added, name);
    } catch (_) {
      return const AddCategoryResult(AddCategoryStatus.failed);
    }
  }

  /// Deletes the saved category called [name], unless [news] still use it
  /// (those news would bring it back, so it has to be changed there first).
  Future<DeleteCategoryResult> deleteCategory(
    String name,
    Iterable<Stire> news,
  ) async {
    final lower = name.trim().toLowerCase();

    final using =
        news
            .where(
              (s) => (s.category?.name ?? '').trim().toLowerCase() == lower,
            )
            .length;
    if (using > 0) {
      return DeleteCategoryResult(DeleteCategoryStatus.inUse, using);
    }

    try {
      final saved = await _categoryRepo.getAllCategories();
      final match = [
        for (final c in saved)
          if (c.name.trim().toLowerCase() == lower) c.id,
      ].whereType<String>();
      if (match.isEmpty) {
        return const DeleteCategoryResult(DeleteCategoryStatus.notFound);
      }
      await _categoryRepo.deleteCategory(match.first);
      _saved = [
        for (final s in _saved)
          if (s.trim().toLowerCase() != lower) s,
      ];
      if ((_query.category ?? '').trim().toLowerCase() == lower) {
        _query = _query.copyWith(category: null);
      }
      _notify();
      return const DeleteCategoryResult(DeleteCategoryStatus.deleted);
    } catch (_) {
      return const DeleteCategoryResult(DeleteCategoryStatus.failed);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
