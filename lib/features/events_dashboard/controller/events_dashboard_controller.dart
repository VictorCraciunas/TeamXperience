import 'package:flutter/material.dart';
import '../../../enums/event_type.dart';
import '../../../model/event.dart';

class EventsDashboardController extends ChangeNotifier {
  List<Event> allUpcomingEvents = [];
  List<Event> allPastEvents = [];
  List<Event> filteredUpcomingEvents = [];
  List<Event> filteredPastEvents = [];
  List<Event> searchResults = [];
  String searchQuery = '';

  // Filter state
  EventType? selectedEventType;
  DateTime? startDate;
  DateTime? endDate;

  List<Event> get displayedUpcomingEvents {
    if (searchQuery.isNotEmpty) {
      return searchResults.where((event) {
        final now = DateTime.now();
        return event.dateEvent == null || event.dateEvent!.isAfter(now);
      }).toList();
    }
    return filteredUpcomingEvents;
  }

  List<Event> get displayedPastEvents {
    if (searchQuery.isNotEmpty) {
      return searchResults.where((event) {
        final now = DateTime.now();
        return event.dateEvent != null && event.dateEvent!.isBefore(now);
      }).toList();
    }
    return filteredPastEvents;
  }

  // For backward compatibility - returns combined list with upcoming first
  List<Event> get displayedEvents {
    return [...displayedUpcomingEvents, ...displayedPastEvents];
  }

  void initializeEvents(List<Event>? events) {
    if (events != null && allUpcomingEvents.isEmpty && allPastEvents.isEmpty) {
      _separateEvents(events);
      _applyFiltersToSeparatedEvents();
      notifyListeners();
    }
  }

  void _separateEvents(List<Event> events) {
    final now = DateTime.now();
    allUpcomingEvents = [];
    allPastEvents = [];

    for (final event in events) {
      if (event.dateEvent == null) {
        // Events without dates go to upcoming events
        allUpcomingEvents.add(event);
      } else if (event.dateEvent!.isAfter(now)) {
        allUpcomingEvents.add(event);
      } else {
        allPastEvents.add(event);
      }
    }

    // Sort upcoming events ascending (closest first)
    allUpcomingEvents.sort((a, b) {
      if (a.dateEvent == null && b.dateEvent == null) return 0;
      if (a.dateEvent == null) return 1;
      if (b.dateEvent == null) return -1;
      return a.dateEvent!.compareTo(b.dateEvent!);
    });

    // Sort past events descending (most recent first)
    allPastEvents.sort((a, b) {
      if (a.dateEvent == null && b.dateEvent == null) return 0;
      if (a.dateEvent == null) return 1;
      if (b.dateEvent == null) return -1;
      return b.dateEvent!.compareTo(a.dateEvent!);
    });
  }

  void _applyFiltersToSeparatedEvents() {
    // Apply filters to upcoming events
    filteredUpcomingEvents = allUpcomingEvents.where((event) {
      return _eventMatchesFilters(event);
    }).toList();

    // Apply filters to past events
    filteredPastEvents = allPastEvents.where((event) {
      return _eventMatchesFilters(event);
    }).toList();
  }

  bool _eventMatchesFilters(Event event) {
    // Filter by event type
    if (selectedEventType != null && event.type != selectedEventType) {
      return false;
    }

    // Filter by date range
    if (startDate != null && endDate != null && event.dateEvent != null) {
      final eventDate = event.dateEvent!;
      if (eventDate.isBefore(startDate!) || eventDate.isAfter(endDate!)) {
        return false;
      }
    }

    return true;
  }

  void applyFilters() {
    _applyFiltersToSeparatedEvents();

    // If search is active, apply search on filtered results
    if (searchQuery.isNotEmpty) {
      _applySearch();
    }

    notifyListeners();
  }

  void searchEvents(String query) {
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
    final allFilteredEvents = [...filteredUpcomingEvents, ...filteredPastEvents];
    searchResults = allFilteredEvents.where((event) {
      final eventName = event.name?.toLowerCase() ?? '';
      return eventName.contains(lowerQuery);
    }).toList();
  }

  void clearSearch() {
    searchQuery = '';
    searchResults = [];
    notifyListeners();
  }

  void updateFilters(Map<String, dynamic>? filterData) {
    if (filterData != null) {
      selectedEventType = filterData['eventType'];
      startDate = filterData['startDate'];
      endDate = filterData['endDate'];
      applyFilters();
    }
  }

  void clearFilters() {
    selectedEventType = null;
    startDate = null;
    endDate = null;
    _applyFiltersToSeparatedEvents();
    if (searchQuery.isNotEmpty) {
      _applySearch();
    }
    notifyListeners();
  }

  void clearEventTypeFilter() {
    selectedEventType = null;
    applyFilters();
  }

  void clearDateFilter() {
    startDate = null;
    endDate = null;
    applyFilters();
  }

  bool get hasActiveFilters =>
      selectedEventType != null ||
          startDate != null ||
          endDate != null;

  Map<String, dynamic> get currentFilters => {
    'eventType': selectedEventType,
    'startDate': startDate,
    'endDate': endDate,
  };

  bool get hasUpcomingEvents => displayedUpcomingEvents.isNotEmpty;
  bool get hasPastEvents => displayedPastEvents.isNotEmpty;
}