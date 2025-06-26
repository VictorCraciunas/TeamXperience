import 'package:flutter/material.dart';

import '../../../../enums/event_type.dart';

class FilterController extends ChangeNotifier {
  EventType? _selectedEventType;
  DateTime? _startDate;
  DateTime? _endDate;

  EventType? get selectedEventType => _selectedEventType;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  void setEventType(EventType? type) {
    _selectedEventType = type;
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void clearFilters() {
    _selectedEventType = null;
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  Map<String, dynamic> getFilterData() {
    return {
      'eventType': _selectedEventType,
      'startDate': _startDate,
      'endDate': _endDate,
    };
  }

  bool get hasActiveFilters =>
      _selectedEventType != null ||
          _startDate != null ||
          _endDate != null;
}