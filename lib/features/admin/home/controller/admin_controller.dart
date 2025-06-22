import 'dart:ui';

import '../../../../backend/repo/event_repo.dart';
import '../../../../backend/repo/stire_repo.dart';
import '../../../../model/event.dart';
import '../../../../model/stire.dart';

class AdminHomeController {
  final EventRepo _eventRepo = EventRepo();
  final StireRepo _stireRepo = StireRepo();

  List<Event> _events = [];
  List<Stire> _stiri = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Event> get events => _events;
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

  Future<void> loadEvents() async {
    _isLoading = true;
    _errorMessage = null;
    _notifyStateChanged();

    try {
      _events = await _eventRepo.getAllEvents();
    } catch (e) {
      _errorMessage = 'Failed to load events: $e';
      _events = [];
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
      await Future.wait([
        loadEvents(),
        loadStiri(),
      ]);
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      _notifyStateChanged();
    }
  }

  void dispose() {
    _onStateChanged = null;
  }
}