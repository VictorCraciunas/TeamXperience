import 'package:teamxperience/model/user.dart';

import '../../../../enums/event_type.dart';
import '../../../../model/event.dart';

class FilterService {
  /// Filters events based on event type and/or date range
  List<Event> filterEvents({
    required List<Event> events,
    EventType? eventType,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return events.where((event) {
      // Filter by event type
      if (eventType != null && event.type != eventType) {
        return false;
      }

      // Filter by date range (only if both dates are provided and event has a date)
      if (startDate != null && endDate != null && event.dateEvent != null) {
        final eventDate = event.dateEvent!;
        if (eventDate.isBefore(startDate) || eventDate.isAfter(endDate)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Searches events by name
  /// Returns list of events whose name contains the search query (case-insensitive)
  List<Event> searchEvents({
    required List<Event> events,
    required String query,
  }) {
    if (query.trim().isEmpty) {
      return events;
    }

    final lowerQuery = query.toLowerCase().trim();

    return events.where((event) {
      final eventName = event.name?.toLowerCase() ?? '';
      return eventName.contains(lowerQuery);
    }).toList();
  }

  /// Combines filtering and searching in one method
  /// Useful when you want to apply both filters and search at once
  List<Event> filterAndSearchEvents({
    required List<Event> events,
    EventType? eventType,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) {
    // First apply filters
    var filteredEvents = filterEvents(
      events: events,
      eventType: eventType,
      startDate: startDate,
      endDate: endDate,
    );

    // Then apply search if query is provided
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filteredEvents = searchEvents(
        events: filteredEvents,
        query: searchQuery,
      );
    }

    return filteredEvents;
  }

}