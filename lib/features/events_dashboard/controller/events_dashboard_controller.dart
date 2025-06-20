import 'package:flutter/material.dart';
import '../../../enums/event_type.dart';
import '../../../model/event.dart';

class EventsDashboardController extends ChangeNotifier {
  List<Event> allEvents = [];
  List<Event> filteredEvents = [];
  List<Event> searchResults = [];
  String searchQuery = '';

  // Filter state
  EventType? selectedEventType;
  DateTime? startDate;
  DateTime? endDate;

  List<Event> get displayedEvents {
    if (searchQuery.isNotEmpty) {
      return searchResults;
    }
    return filteredEvents;
  }

  void initializeEvents(List<Event>? events) {
    if (events != null && allEvents.isEmpty) {
      allEvents = events;
      filteredEvents = events;
      notifyListeners();
    }
  }

  void applyFilters() {
    filteredEvents = allEvents.where((event) {
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
    }).toList();

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
    searchResults = filteredEvents.where((event) {
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
    filteredEvents = allEvents;
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
}