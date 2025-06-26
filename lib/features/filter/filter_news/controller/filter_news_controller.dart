import 'package:flutter/material.dart';
import '../../../../model/newsCategory.dart';
import '../../../../enums/stire_type.dart';

class FilterStiriController extends ChangeNotifier {
  StireType? _selectedStireType;
  NewsCategory? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;

  StireType? get selectedStireType => _selectedStireType;
  NewsCategory? get selectedCategory => _selectedCategory;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  void setStireType(StireType? type) {
    _selectedStireType = type;
    notifyListeners();
  }

  void setCategory(NewsCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setStartDate(DateTime? date) {
    _startDate = date;
    notifyListeners();
  }

  void setEndDate(DateTime? date) {
    _endDate = date;
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void clearFilters() {
    _selectedStireType = null;
    _selectedCategory = null;
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  Map<String, dynamic> getFilterData() {
    return {
      'stireType': _selectedStireType,
      'category': _selectedCategory,
      'startDate': _startDate,
      'endDate': _endDate,
    };
  }

  bool get hasActiveFilters =>
      _selectedStireType != null ||
          (_selectedCategory != null && _selectedCategory!.name.isNotEmpty) ||
          _startDate != null ||
          _endDate != null;
}