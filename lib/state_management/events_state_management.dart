import 'package:flutter/cupertino.dart';

import '../enums/event_type.dart';
import '../model/event.dart';
import '../service/event_service/event_service.dart';

class EventList extends ChangeNotifier {
  final EventService _eventService;

  // State
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetch;

  // Constructor
  EventList(this._eventService);

  // Getters
  List<Event> get events => List.unmodifiable(_events);
  List<Event> get upcomingEvents {
    final now = DateTime.now();
    return _events.where((e) =>
    e.dateEvent?.isAfter(now) ?? false
    ).toList()..sort((a, b) =>
        a.dateEvent!.compareTo(b.dateEvent!)
    );
  }

  List<Event> get pastEvents {
    final now = DateTime.now();
    return _events.where((e) =>
    e.dateEvent?.isBefore(now) ?? false
    ).toList()..sort((a, b) =>
        b.dateEvent!.compareTo(a.dateEvent!)
    );
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _events.isNotEmpty;
  bool get needsRefresh => _lastFetch == null ||
      DateTime.now().difference(_lastFetch!).inMinutes > 5;

  // Event operations
  Future<void> loadEvents({bool forceRefresh = false}) async {
    if (_isLoading) return;

    if (!forceRefresh && !needsRefresh && hasData) {
      return; // Don't reload if we have recent data
    }

    _setLoading(true);
    _clearError();

    try {
      final events = await _eventService.getAllEvents();
      _events = events;
      _lastFetch = DateTime.now();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<Event> createEvent(Event event) async {
    _setLoading(true);
    _clearError();

    try {
      final createdEvent = await _eventService.createEvent(event);
      _events.add(createdEvent);
      _sortEvents();
      notifyListeners();
      return createdEvent;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateEvent(Event event) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedEvent = await _eventService.updateEvent(event);
      final index = _events.indexWhere((e) => e.eventId == event.eventId);
      if (index != -1) {
        _events[index] = updatedEvent;
        _sortEvents();
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteEvent(String eventId) async {
    _setLoading(true);
    _clearError();

    try {
      await _eventService.deleteEvent(eventId);
      _events.removeWhere((e) => e.eventId == eventId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Event> duplicateEvent(String eventId) async {
    _setLoading(true);
    _clearError();

    try {
      final originalEvent = getEventById(eventId);
      if (originalEvent == null) {
        throw Exception('Event not found');
      }

      final duplicatedEvent = await _eventService.duplicateEvent(originalEvent);
      return duplicatedEvent;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Query methods
  Event? getEventById(String eventId) {
    try {
      return _events.firstWhere((e) => e.eventId == eventId);
    } catch (e) {
      return null;
    }
  }

  List<Event> searchEvents(String query) {
    if (query.isEmpty) return events;

    final lowercaseQuery = query.toLowerCase();
    return _events.where((event) =>
    (event.name?.toLowerCase().contains(lowercaseQuery) ?? false) ||
        (event.location?.toLowerCase().contains(lowercaseQuery) ?? false) ||
        (event.description?.toLowerCase().contains(lowercaseQuery) ?? false)
    ).toList();
  }

  List<Event> filterEvents({
    EventType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _events.where((event) {
      if (type != null && event.type != type) return false;
      if (startDate != null && (event.dateEvent?.isBefore(startDate) ?? true)) return false;
      if (endDate != null && (event.dateEvent?.isAfter(endDate) ?? true)) return false;
      return true;
    }).toList();
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

  void _clearError() {
    _error = null;
  }

  void _sortEvents() {
    _events.sort((a, b) {
      if (a.dateEvent == null && b.dateEvent == null) return 0;
      if (a.dateEvent == null) return 1;
      if (b.dateEvent == null) return -1;
      return a.dateEvent!.compareTo(b.dateEvent!);
    });
  }

  // Refresh method for pull-to-refresh
  Future<void> refresh() async {
    await loadEvents(forceRefresh: true);
  }

  // Clear all data (useful for logout)
  void clear() {
    _events.clear();
    _error = null;
    _isLoading = false;
    _lastFetch = null;
    notifyListeners();
  }
}