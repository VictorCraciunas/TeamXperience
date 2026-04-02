import 'package:flutter/material.dart';

import '../../../../backend/repo/teamRepo.dart';
import '../../../../enums/event_type.dart';
import '../../../../model/event.dart';
import '../../../../state_management/events_state_management.dart';
import '../../events_filter_service.dart';

class EventsDashboardController extends ChangeNotifier {
  final FilterService _filterService = FilterService();
  final TeamRepo _teamRepo = TeamRepo();

  List<Event> _searchResults = [];
  String _searchQuery = '';

  // Event statistics (eventId -> {nrTeams, nrPerson})
  Map<String, Map<String, int>> _eventStats = {};

  // Filter state
  EventType? _selectedEventType;
  DateTime? _startDate;
  DateTime? _endDate;

  // Getters
  String get searchQuery => _searchQuery;
  EventType? get selectedEventType => _selectedEventType;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  Map<String, Map<String, int>> get eventStats => _eventStats;

  bool get hasActiveFilters => _selectedEventType != null || _startDate != null || _endDate != null;


  Map<String, dynamic> get currentFilters => {
    'eventType': _selectedEventType,
    'startDate': _startDate,
    'endDate': _endDate,
  };

  /// Get filtered upcoming events from EventList
  List<Event> getFilteredUpcomingEvents(EventList eventList) {
    return _filterService.filterEvents(
      events: eventList.upcomingEvents,
      eventType: _selectedEventType,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  /// Get filtered past events from EventList
  List<Event> getFilteredPastEvents(EventList eventList) {
    return _filterService.filterEvents(
      events: eventList.pastEvents,
      eventType: _selectedEventType,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  /// Get displayed upcoming events (with search applied if active)
  List<Event> getDisplayedUpcomingEvents(EventList eventList) {
    if (_searchQuery.isNotEmpty) {
      // Filter search results to only upcoming events
      return _searchResults.where((event) {
        final now = DateTime.now();
        return event.dateEvent == null || event.dateEvent!.isAfter(now);
      }).toList();
    }
    return getFilteredUpcomingEvents(eventList);
  }

  /// Get displayed past events (with search applied if active)
  List<Event> getDisplayedPastEvents(EventList eventList) {
    if (_searchQuery.isNotEmpty) {
      // Filter search results to only past events
      return _searchResults.where((event) {
        final now = DateTime.now();
        return event.dateEvent != null && event.dateEvent!.isBefore(now);
      }).toList();
    }
    return getFilteredPastEvents(eventList);
  }

  bool hasUpcomingEvents(EventList eventList) => getDisplayedUpcomingEvents(eventList).isNotEmpty;
  bool hasPastEvents(EventList eventList) => getDisplayedPastEvents(eventList).isNotEmpty;

  void searchEvents(String query, EventList eventList) {
    _searchQuery = query.trim();
    if (_searchQuery.isEmpty) {
      _searchResults = [];
    } else {
      // Get all filtered events (both upcoming and past)
      final allFilteredEvents = [
        ...getFilteredUpcomingEvents(eventList),
        ...getFilteredPastEvents(eventList),
      ];

      _searchResults = _filterService.searchEvents(
        events: allFilteredEvents,
        query: _searchQuery,
      );
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

  /// Load team statistics for all events
  Future<void> loadEventStats(List<Event> events) async {
    for (final event in events) {
      try {
        final teams = await _teamRepo.getAllTeamsForEvent(event.eventId);
        final nrTeams = teams.length;
        final nrPerson = teams.fold<int>(0, (sum, team) => sum + team.numberOfMembers);

        _eventStats[event.eventId] = {
          'nrTeams': nrTeams,
          'nrPerson': nrPerson,
        };
      } catch (e) {
        // If error fetching teams, default to 0
        _eventStats[event.eventId] = {'nrTeams': 0, 'nrPerson': 0};
      }
    }
    notifyListeners();
  }

  /// Get statistics for a specific event
  Map<String, int> getEventStats(String eventId) {
    return _eventStats[eventId] ?? {'nrTeams': 0, 'nrPerson': 0};
  }
}