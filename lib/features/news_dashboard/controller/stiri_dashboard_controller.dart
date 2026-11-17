import 'package:flutter/material.dart';

import '../../../backend/repo/news_category_repo.dart';
import '../../../model/stire.dart';
import '../logic/news_filters.dart';

/// The Știri list, for players and organisers: the chosen type or category
/// chip and the saved categories (added and deleted on the Categorii screen).
class StiriDashboardController extends ChangeNotifier {
  StiriDashboardController({NewsCategoryRepo? categoryRepo})
    : _injectedCategoryRepo = categoryRepo;

  final NewsCategoryRepo? _injectedCategoryRepo;
  late final NewsCategoryRepo _categoryRepo =
      _injectedCategoryRepo ?? NewsCategoryRepo();

  NewsQuery _query = const NewsQuery();
  List<String> _saved = const [];
  bool _savedLoaded = false;
  bool _disposed = false;

  NewsQuery get query => _query;

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

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
