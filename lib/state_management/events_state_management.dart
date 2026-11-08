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

  List<Event> get _published => _events.where((e) => !e.isDraft).toList();

  // Getters. Drafts are only for organisers and are listed apart in
  // [draftEvents]; everything else here is what players can see.
  List<Event> get events => List.unmodifiable(_published);

  /// Events still being built, most recently edited first.
  List<Event> get draftEvents {
    final drafts = _events.where((e) => e.isDraft).toList();
    drafts.sort((a, b) {
      final x = a.updatedAt;
      final y = b.updatedAt;
      if (x == null && y == null) return 0;
      if (x == null) return 1;
      if (y == null) return -1;
      return y.compareTo(x);
    });
    return List.unmodifiable(drafts);
  }

  List<Event> get upcomingEvents {
    final now = DateTime.now();
    return _published.where((e) =>
    e.dateEvent?.isAfter(now) ?? false
    ).toList()..sort((a, b) =>
        a.dateEvent!.compareTo(b.dateEvent!)
    );
  }

  List<Event> get liveEvents {
    final now = DateTime.now();
    return _published.where((e) {
      final start = e.dateEvent;
      if (start == null) return false;
      if (e.isOver) return false;
      return !start.isAfter(now);
    }).toList()..sort((a, b) => a.dateEvent!.compareTo(b.dateEvent!));
  }

  List<Event> get pastEvents {
    final now = DateTime.now();
    return _published.where((e) =>
    e.dateEvent?.isBefore(now) ?? false
    ).toList()..sort((a, b) =>
        b.dateEvent!.compareTo(a.dateEvent!)
    );
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// The last read failed and there is nothing to show from before it.
  bool get loadFailed => _error != null && !hasData;
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
    clearError();

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
    clearError();

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
    clearError();

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
    }
  }

  /// Saves [event] as a draft (a new one gets its id here) and keeps the list
  /// in step. Returns the saved event.
  Future<Event> saveDraft(Event event, {int? wizardStep}) async {
    clearError();

    try {
      final saved = await _eventService.saveDraft(event, wizardStep: wizardStep);
      _replaceOrAdd(saved);
      notifyListeners();
      return saved;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  /// Publishes a draft (or saves a published event again). If the event is not
  /// complete this throws and the list is left as it was.
  Future<Event> publishEvent(Event event) async {
    clearError();

    try {
      final published = await _eventService.publishEvent(event);
      _replaceOrAdd(published);
      _sortEvents();
      notifyListeners();
      return published;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  void _replaceOrAdd(Event event) {
    final index = _events.indexWhere((e) => e.eventId == event.eventId);
    if (index == -1) {
      _events.add(event);
    } else {
      _events[index] = event;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    _setLoading(true);
    clearError();

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

  // Query methods
  Event? getEventById(String eventId) {
    try {
      return _events.firstWhere((e) => e.eventId == eventId);
    } catch (e) {
      return null;
    }
  }

  void _sortEvents() {
    _events.sort((a, b) {
      if (a.dateEvent == null && b.dateEvent == null) return 0;
      if (a.dateEvent == null) return 1;
      if (b.dateEvent == null) return -1;
      return a.dateEvent!.compareTo(b.dateEvent!);
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