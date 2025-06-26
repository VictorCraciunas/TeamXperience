import 'package:flutter/material.dart';
import '../../../model/stire.dart';
import '../../../model/newsCategory.dart';
import '../../../enums/stire_type.dart';

class StiriDashboardController extends ChangeNotifier {
  List<Stire> allRecentStiri = [];
  List<Stire> allOlderStiri = [];
  List<Stire> filteredRecentStiri = [];
  List<Stire> filteredOlderStiri = [];
  List<Stire> searchResults = [];
  String searchQuery = '';

  // Filter state
  StireType? selectedStireType;
  NewsCategory? selectedCategory;
  DateTime? startDate;
  DateTime? endDate;

  List<Stire> get displayedRecentStiri {
    if (searchQuery.isNotEmpty) {
      return searchResults.where((stire) {
        final now = DateTime.now();
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));
        return stire.publicationDate == null ||
            stire.publicationDate!.isAfter(thirtyDaysAgo);
      }).toList();
    }
    return filteredRecentStiri;
  }

  List<Stire> get displayedOlderStiri {
    if (searchQuery.isNotEmpty) {
      return searchResults.where((stire) {
        final now = DateTime.now();
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));
        return stire.publicationDate != null &&
            stire.publicationDate!.isBefore(thirtyDaysAgo);
      }).toList();
    }
    return filteredOlderStiri;
  }

  // For backward compatibility - returns combined list with recent first
  List<Stire> get displayedStiri {
    return [...displayedRecentStiri, ...displayedOlderStiri];
  }

  void initializeStiri(List<Stire>? stiri) {
    if (stiri != null && allRecentStiri.isEmpty && allOlderStiri.isEmpty) {
      _separateStiri(stiri);
      _applyFiltersToSeparatedStiri();
      notifyListeners();
    }
  }

  void _separateStiri(List<Stire> stiri) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    allRecentStiri = [];
    allOlderStiri = [];

    for (final stire in stiri) {
      if (stire.publicationDate == null) {
        // Stiri without dates go to recent stiri
        allRecentStiri.add(stire);
      } else if (stire.publicationDate!.isAfter(thirtyDaysAgo)) {
        allRecentStiri.add(stire);
      } else {
        allOlderStiri.add(stire);
      }
    }

    // Sort recent stiri descending (newest first)
    allRecentStiri.sort((a, b) {
      if (a.publicationDate == null && b.publicationDate == null) return 0;
      if (a.publicationDate == null) return 1;
      if (b.publicationDate == null) return -1;
      return b.publicationDate!.compareTo(a.publicationDate!);
    });

    // Sort older stiri descending (newest first)
    allOlderStiri.sort((a, b) {
      if (a.publicationDate == null && b.publicationDate == null) return 0;
      if (a.publicationDate == null) return 1;
      if (b.publicationDate == null) return -1;
      return b.publicationDate!.compareTo(a.publicationDate!);
    });
  }

  void _applyFiltersToSeparatedStiri() {
    // Apply filters to recent stiri
    filteredRecentStiri = allRecentStiri.where((stire) {
      return _stireMatchesFilters(stire);
    }).toList();

    // Apply filters to older stiri
    filteredOlderStiri = allOlderStiri.where((stire) {
      return _stireMatchesFilters(stire);
    }).toList();
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
    _applyFiltersToSeparatedStiri();

    // If search is active, apply search on filtered results
    if (searchQuery.isNotEmpty) {
      _applySearch();
    }

    notifyListeners();
  }

  void searchStiri(String query) {
    searchQuery = query.trim();
    if (searchQuery.isEmpty) {
      searchResults = [];
    } else {
      _applySearch();
    }
    notifyListeners();
  }

  void _applySearch() {
    final lowerQuery = searchQuery.toLowerCase();
    final allFilteredStiri = [...filteredRecentStiri, ...filteredOlderStiri];
    searchResults = allFilteredStiri.where((stire) {
      final stireTitle = stire.title?.toLowerCase() ?? '';
      final stireDescription = stire.description?.toLowerCase() ?? '';
      return stireTitle.contains(lowerQuery) ||
          stireDescription.contains(lowerQuery);
    }).toList();
  }

  void clearSearch() {
    searchQuery = '';
    searchResults = [];
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
    _applyFiltersToSeparatedStiri();
    if (searchQuery.isNotEmpty) {
      _applySearch();
    }
    notifyListeners();
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

  bool get hasRecentStiri => displayedRecentStiri.isNotEmpty;
  bool get hasOlderStiri => displayedOlderStiri.isNotEmpty;
}