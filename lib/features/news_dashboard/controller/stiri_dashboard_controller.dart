import 'package:flutter/material.dart';
import '../../../model/stire.dart';

class StiriDashboardController extends ChangeNotifier {
  List<Stire> allStiri = [];
  List<Stire> searchResults = [];
  String searchQuery = '';

  List<Stire> get displayedStiri {
    if (searchQuery.isNotEmpty) {
      return searchResults;
    }
    return allStiri;
  }

  void initializeStiri(List<Stire>? stiri) {
    if (stiri != null && allStiri.isEmpty) {
      allStiri = stiri;
      notifyListeners();
    }
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
    searchResults = allStiri.where((stire) {
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
}