import 'package:flutter/cupertino.dart';
import 'package:teamxperience/service/news_service/news_service.dart';

import '../enums/stire_type.dart';
import '../model/stire.dart';

class NewsList extends ChangeNotifier {
  final NewsService _stireService;

  // State
  List<Stire> _stireList = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetch;

  // Constructor
  NewsList(this._stireService);

  // Getters
  List<Stire> get stireList => List.unmodifiable(_stireList);


  List<Stire> getNewsByType(StireType type) {
    return _stireList.where((s) =>
    s.type == type && s.publicationDate != null
    ).toList()..sort((a, b) =>
        b.publicationDate!.compareTo(a.publicationDate!)
    );
  }

  List<Stire> getNewsByCategory(String categoryName) {
    return _stireList.where((s) =>
    s.category?.name == categoryName && s.publicationDate != null
    ).toList()..sort((a, b) =>
        b.publicationDate!.compareTo(a.publicationDate!)
    );
  }

  // Get all news sorted by most recent first (all will be in the past)
  List<Stire> get allNewsSorted {
    return _stireList.where((s) => s.publicationDate != null).toList()
      ..sort((a, b) => b.publicationDate!.compareTo(a.publicationDate!));
  }

  // Get latest N news articles
  List<Stire> getLatestNews(int count) {
    return allNewsSorted.take(count).toList();
  }

  // Get news from a specific time period
  List<Stire> getNewsFromPeriod({required DateTime startDate, required DateTime endDate}) {
    return _stireList.where((s) =>
    s.publicationDate != null &&
        s.publicationDate!.isAfter(startDate) &&
        s.publicationDate!.isBefore(endDate)
    ).toList()..sort((a, b) => b.publicationDate!.compareTo(a.publicationDate!));
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _stireList.isNotEmpty;
  bool get needsRefresh => _lastFetch == null ||
      DateTime.now().difference(_lastFetch!).inMinutes > 5;

  // News operations
  Future<void> loadStire({bool forceRefresh = false}) async {
    if (_isLoading) return;

    if (!forceRefresh && !needsRefresh && hasData) {
      return; // Don't reload if we have recent data
    }

    _setLoading(true);
    clearError();

    try {
      final stireList = await _stireService.getAllStire();
      _stireList = stireList;
      _lastFetch = DateTime.now();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<Stire> createStire(Stire stire) async {
    _setLoading(true);
    clearError();

    try {
      final createdStire = await _stireService.createStire(stire);
      _stireList.add(createdStire);
      _sortStire();
      notifyListeners();
      return createdStire;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateStire(Stire stire) async {
    clearError();

    try {
      final updatedStire = await _stireService.updateStire(stire);
      final index = _stireList.indexWhere((s) => s.id == stire.id);
      if (index != -1) {
        _stireList[index] = updatedStire;
        _sortStire();
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
    }
  }



  // Query methods
  Stire? getStireById(String stireId) {
    try {
      return _stireList.firstWhere((s) => s.id == stireId);
    } catch (e) {
      return null;
    }
  }

  void _sortStire() {
    _stireList.sort((a, b) {
      if (a.publicationDate == null && b.publicationDate == null) return 0;
      if (a.publicationDate == null) return 1;
      if (b.publicationDate == null) return -1;
      // Sort by most recent first (newest date = higher value, so b.compareTo(a))
      return b.publicationDate!.compareTo(a.publicationDate!);
    });
  }

  // State management helpers
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
  }

  // Refresh method for pull-to-refresh
  Future<void> refresh() async {
    await loadStire(forceRefresh: true);
  }

  // Clear all data (useful for logout)
  void clear() {
    _stireList.clear();
    _error = null;
    _isLoading = false;
    _lastFetch = null;
    notifyListeners();
  }
}