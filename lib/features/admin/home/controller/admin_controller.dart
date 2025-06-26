import 'dart:ui';

import '../../../../backend/repo/event_repo.dart';
import '../../../../backend/repo/stire_repo.dart';
import '../../../../model/event.dart';
import '../../../../model/stire.dart';

class AdminHomeController {
  final EventRepo _eventRepo = EventRepo();
  final StireRepo _stireRepo = StireRepo();

  List<Event> _allEvents = [];
  List<Event> _upcomingEvents = [];
  List<Event> _pastEvents = [];
  List<Stire> _stiri = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Event> get allEvents => _allEvents;
  List<Event> get upcomingEvents => _upcomingEvents;
  List<Event> get pastEvents => _pastEvents;
  List<Event> get events => _upcomingEvents; // For backward compatibility with carousel
  List<Stire> get stiri => _stiri;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Callback to trigger UI updates
  VoidCallback? _onStateChanged;

  void setStateCallback(VoidCallback callback) {
    _onStateChanged = callback;
  }

  void _notifyStateChanged() {
    if (_onStateChanged != null) {
      _onStateChanged!();
    }
  }

  /// Separates events into upcoming and past events, then sorts them
  void _separateAndSortEvents() {
    final now = DateTime.now();
    _upcomingEvents = [];
    _pastEvents = [];

    for (final event in _allEvents) {
      if (event.dateEvent == null) {
        // Events without dates go to upcoming events
        _upcomingEvents.add(event);
      } else if (event.dateEvent!.isAfter(now)) {
        _upcomingEvents.add(event);
      } else {
        _pastEvents.add(event);
      }
    }

    // Sort upcoming events ascending (closest first)
    _upcomingEvents.sort((a, b) {
      if (a.dateEvent == null && b.dateEvent == null) return 0;
      if (a.dateEvent == null) return 1;
      if (b.dateEvent == null) return -1;
      return a.dateEvent!.compareTo(b.dateEvent!);
    });

    // Sort past events descending (most recent first)
    _pastEvents.sort((a, b) {
      if (a.dateEvent == null && b.dateEvent == null) return 0;
      if (a.dateEvent == null) return 1;
      if (b.dateEvent == null) return -1;
      return b.dateEvent!.compareTo(a.dateEvent!);
    });
  }

  /// Sorts stiri by publicationDate descending (most recent first)
  /// Stiri without dates are placed at the end
  void _sortStiri() {
    _stiri.sort((a, b) {
      // Handle null dates - put them at the end
      if (a.publicationDate == null && b.publicationDate == null) return 0;
      if (a.publicationDate == null) return 1;
      if (b.publicationDate == null) return -1;

      // Sort descending (most recent first)
      return b.publicationDate!.compareTo(a.publicationDate!);
    });
  }

  Future<void> loadEvents() async {
    _isLoading = true;
    _errorMessage = null;
    _notifyStateChanged();

    try {
      _allEvents = await _eventRepo.getAllEvents();
      _separateAndSortEvents();
    } catch (e) {
      _errorMessage = 'Failed to load events: $e';
      _allEvents = [];
      _upcomingEvents = [];
      _pastEvents = [];
    } finally {
      _isLoading = false;
      _notifyStateChanged();
    }
  }

  Future<void> loadStiri() async {
    _isLoading = true;
    _errorMessage = null;
    _notifyStateChanged();

    try {
      _stiri = await _stireRepo.getAllStire();
      _sortStiri();
    } catch (e) {
      _errorMessage = 'Failed to load stiri: $e';
      _stiri = [];
    } finally {
      _isLoading = false;
      _notifyStateChanged();
    }
  }

  Future<void> loadAll() async {
    _isLoading = true;
    _errorMessage = null;
    _notifyStateChanged();

    try {
      // Load both events and stiri concurrently
      final results = await Future.wait([
        _eventRepo.getAllEvents(),
        _stireRepo.getAllStire(),
      ]);

      _allEvents = results[0] as List<Event>;
      _stiri = results[1] as List<Stire>;

      // Sort and separate events, sort stiri
      _separateAndSortEvents();
      _sortStiri();
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
      _allEvents = [];
      _upcomingEvents = [];
      _pastEvents = [];
      _stiri = [];
    } finally {
      _isLoading = false;
      _notifyStateChanged();
    }
  }

  /// Manually trigger sorting if needed (e.g., after adding/updating items)
  void sortAll() {
    _separateAndSortEvents();
    _sortStiri();
    _notifyStateChanged();
  }

  void dispose() {
    _onStateChanged = null;
  }
}