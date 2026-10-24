import 'package:flutter/material.dart';
import '../../../model/stire.dart';
import '../../../backend/repo/news_category_repo.dart';
import '../../../utils/period_utils.dart';
import '../../../model/newsCategory.dart';
import '../../../enums/stire_type.dart';
import '../../../state_management/news_state_management.dart';

/// How adding a category went.
enum AddCategoryStatus { added, empty, duplicate, failed }

class AddCategoryResult {
  const AddCategoryResult(this.status, [this.name = '']);

  final AddCategoryStatus status;

  /// The saved name when [status] is [AddCategoryStatus.added].
  final String name;
}

class StiriDashboardController extends ChangeNotifier {
  StiriDashboardController({NewsCategoryRepo? categoryRepo})
    : _injectedCategoryRepo = categoryRepo;

  final NewsCategoryRepo? _injectedCategoryRepo;
  late final NewsCategoryRepo _categoryRepo =
      _injectedCategoryRepo ?? NewsCategoryRepo();

  List<Stire> _searchResults = [];
  String _searchQuery = '';

  // Filter state
  StireType? selectedStireType;
  NewsCategory? selectedCategory;
  DateTime? startDate;
  DateTime? endDate;

  // Getters
  String get searchQuery => _searchQuery;

  bool get hasActiveFilters =>
      selectedStireType != null ||
      (selectedCategory != null && selectedCategory!.name.isNotEmpty) ||
      startDate != null ||
      endDate != null;

  Map<String, dynamic> get currentFilters => {
    'stireType': selectedStireType,
    'category': selectedCategory,
    'startDate': startDate,
    'endDate': endDate,
  };

  /// All category names: the saved ones plus any used by [news], sorted and
  /// without repeats (ignoring case). If loading fails, only those used by news.
  Future<List<String>> categoryNames(Iterable<Stire> news) async {
    final byLower = <String, String>{};

    void add(String? name) {
      final clean = name?.trim() ?? '';
      if (clean.isEmpty) return;
      byLower.putIfAbsent(clean.toLowerCase(), () => clean);
    }

    // News first, so a name keeps the spelling it is used with.
    for (final stire in news) {
      add(stire.category?.name);
    }
    try {
      for (final category in await _categoryRepo.getAllCategories()) {
        add(category.name);
      }
    } catch (_) {
      // Keep what the news already gave us.
    }

    return byLower.values.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
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
      return AddCategoryResult(AddCategoryStatus.added, name);
    } catch (_) {
      return const AddCategoryResult(AddCategoryStatus.failed);
    }
  }

  /// Get filtered stiri from NewsList
  List<Stire> getFilteredStiri(NewsList newsList) {
    return newsList.stireList.where(_stireMatchesFilters).toList()
      ..sort((a, b) {
        if (a.publicationDate == null && b.publicationDate == null) return 0;
        if (a.publicationDate == null) return 1;
        if (b.publicationDate == null) return -1;
        return b.publicationDate!.compareTo(a.publicationDate!);
      });
  }

  /// Get displayed stiri (with search applied if active)
  List<Stire> getDisplayedStiri(NewsList newsList) {
    if (_searchQuery.isNotEmpty) {
      return _searchResults;
    }
    return getFilteredStiri(newsList);
  }

  bool _stireMatchesFilters(Stire stire) {
    // Filter by stire type
    if (selectedStireType != null && stire.type != selectedStireType) {
      return false;
    }

    // Filter by category
    if (selectedCategory != null &&
        selectedCategory!.name.isNotEmpty &&
        stire.category?.name != selectedCategory!.name) {
      return false;
    }

    // Filter by date range (the last day counts until its end)
    if (!isWithinPeriod(stire.publicationDate, startDate, endDate)) {
      return false;
    }

    return true;
  }

  void applyFilters() {
    // Clear search when filters change
    if (_searchQuery.isNotEmpty) {
      _searchQuery = '';
      _searchResults = [];
    }
    notifyListeners();
  }

  void searchStiri(String query, NewsList newsList) {
    _searchQuery = query.trim();
    if (_searchQuery.isEmpty) {
      _searchResults = [];
    } else {
      final lowerQuery = _searchQuery.toLowerCase();
      final allFilteredStiri = getFilteredStiri(newsList);
      _searchResults =
          allFilteredStiri.where((stire) {
            final stireTitle = stire.title?.toLowerCase() ?? '';
            final stireDescription = stire.description?.toLowerCase() ?? '';
            return stireTitle.contains(lowerQuery) ||
                stireDescription.contains(lowerQuery);
          }).toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  void updateFilters(Map<String, dynamic>? filterData) {
    if (filterData != null) {
      selectedStireType = filterData['stireType'];
      selectedCategory = filterData['category'];
      startDate = filterData['startDate'];
      endDate = filterData['endDate'];
      applyFilters();
    }
  }

  void clearFilters() {
    selectedStireType = null;
    selectedCategory = null;
    startDate = null;
    endDate = null;
    applyFilters();
  }

  void clearStireTypeFilter() {
    selectedStireType = null;
    applyFilters();
  }

  void clearCategoryFilter() {
    selectedCategory = null;
    applyFilters();
  }

  void clearDateFilter() {
    startDate = null;
    endDate = null;
    applyFilters();
  }
}
