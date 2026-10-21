import 'package:flutter/material.dart';
import '../../../model/stire.dart';
import '../../../model/newsCategory.dart';
import '../../../enums/stire_type.dart';
import '../../../state_management/news_state_management.dart';

class StiriDashboardController extends ChangeNotifier {
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

    // Filter by date range
    if (startDate != null && endDate != null && stire.publicationDate != null) {
      final stireDate = stire.publicationDate!;
      if (stireDate.isBefore(startDate!) || stireDate.isAfter(endDate!)) {
        return false;
      }
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
