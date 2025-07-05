import 'package:flutter/material.dart';
import 'package:teamxperience/model/event.dart';
import '../../../../enums/event_type.dart';
import '../../events_filter_service.dart';

class EventsDashboardUserController extends ChangeNotifier {
  final FilterService _filterService = FilterService();

  // Original events passed to the controller
  final List<Event> _allEvents;

  // Search state
  String _searchQuery = '';
  List<Event> _searchResults = [];

  // Filter state
  EventType? _selectedEventType;
  DateTime? _startDate;
  DateTime? _endDate;

  // Constructor
  EventsDashboardUserController(List<Event> events) : _allEvents = events;

  // Getters
  String get searchQuery => _searchQuery;
  EventType? get selectedEventType => _selectedEventType;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  bool get hasActiveFilters =>
      _selectedEventType != null ||
          _startDate != null ||
          _endDate != null;

  bool get isSearchActive => _searchQuery.isNotEmpty;

  Map<String, dynamic> get currentFilters => {
    'eventType': _selectedEventType,
    'startDate': _startDate,
    'endDate': _endDate,
  };

  // Get displayed events (with filters and search applied)
  List<Event> get events {
    // First apply filters
    List<Event> filteredEvents = _filterService.filterEvents(
      events: _allEvents,
      eventType: _selectedEventType,
      startDate: _startDate,
      endDate: _endDate,
    );

    // Then apply search if active
    if (_searchQuery.isNotEmpty) {
      return _filterService.searchEvents(
        events: filteredEvents,
        query: _searchQuery,
      );
    }

    return filteredEvents;
  }

  // Search functionality
  void searchEvents(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  // Filter functionality
  void updateFilters(Map<String, dynamic>? filterData) {
    if (filterData != null) {
      _selectedEventType = filterData['eventType'];
      _startDate = filterData['startDate'];
      _endDate = filterData['endDate'];
      notifyListeners();
    }
  }

  void clearFilters() {
    _selectedEventType = null;
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  void clearEventTypeFilter() {
    _selectedEventType = null;
    notifyListeners();
  }

  void clearDateFilter() {
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  // Combined filter and search using the service
  List<Event> getFilteredAndSearchedEvents() {
    return _filterService.filterAndSearchEvents(
      events: _allEvents,
      eventType: _selectedEventType,
      startDate: _startDate,
      endDate: _endDate,
      searchQuery: _searchQuery,
    );
  }
}