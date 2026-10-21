import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/user.dart';
import '../../../../backend/repo/teamRepo.dart';
import '../../../../state_management/user_provider.dart';
import '../../events_filter_service.dart';

class EventsDashboardUserController extends ChangeNotifier {
  final FilterService _filterService = FilterService();
  late final TeamRepo _teamRepo = TeamRepo();

  // Original events passed to the controller
  List<Event> _allEvents;
  late final List<Event> registeredEvents;
  AppUser? user;

  // Event statistics (eventId -> {nrTeams, nrPerson})
  Map<String, Map<String, int>> _eventStats = {};

  // Search state
  String _searchQuery = '';

  // Filter state
  DateTime? _startDate;
  DateTime? _endDate;

  // Constructor
  EventsDashboardUserController(List<Event> events, context)
    : _allEvents = events {
    user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user != null) {
      //registeredEvents = _filterService.registeredEventsFromUser(_allEvents, user!);
    } else {
      registeredEvents = []; // ← Initialize to empty list if no user
    }
  }

  /// Replaces the events shown (used when the shared event list refreshes).
  void updateEvents(List<Event> events) {
    _allEvents = events;
    notifyListeners();
  }

  // Getters
  String get searchQuery => _searchQuery;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  Map<String, Map<String, int>> get eventStats => _eventStats;

  bool get hasActiveFilters => _startDate != null || _endDate != null;

  bool get isSearchActive => _searchQuery.isNotEmpty;

  Map<String, dynamic> get currentFilters => {
    'startDate': _startDate,
    'endDate': _endDate,
  };

  // Get displayed events (with filters and search applied)
  List<Event> get events {
    // First apply filters
    List<Event> filteredEvents = _filterService.filterEvents(
      events: _allEvents,
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
    notifyListeners();
  }

  // Filter functionality
  void updateFilters(Map<String, dynamic>? filterData) {
    if (filterData != null) {
      _startDate = filterData['startDate'];
      _endDate = filterData['endDate'];
      notifyListeners();
    }
  }

  void clearFilters() {
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  void clearEventTypeFilter() {
    notifyListeners();
  }

  void clearDateFilter() {
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  List<Event> getFilteredAndSearchedEvents() {
    return _filterService.filterAndSearchEvents(
      events: _allEvents,
      startDate: _startDate,
      endDate: _endDate,
      searchQuery: _searchQuery,
    );
  }

  List<Event> filterRegisteredEvents(List<Event> registeredEvents) {
    List<Event> filteredEvents = _filterService.filterEvents(
      events: registeredEvents,
      startDate: _startDate,
      endDate: _endDate,
    );

    if (_searchQuery.isNotEmpty) {
      return _filterService.searchEvents(
        events: filteredEvents,
        query: _searchQuery,
      );
    }

    return filteredEvents;
  }

  /// Load team statistics for events (only for admin view)
  Future<void> loadEventStats(List<Event> events) async {
    for (final event in events) {
      try {
        final teams = await _teamRepo.getAllTeamsForEvent(event.eventId);
        final nrTeams = teams.length;
        final nrPerson = teams.fold<int>(
          0,
          (sum, team) => sum + team.userIds.length,
        );

        _eventStats[event.eventId] = {'nrTeams': nrTeams, 'nrPerson': nrPerson};
      } catch (e) {
        _eventStats[event.eventId] = {'nrTeams': 0, 'nrPerson': 0};
      }
    }
    notifyListeners();
  }
}
