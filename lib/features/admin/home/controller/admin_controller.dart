
import 'dart:ui';

import '../../../../backend/repo/event_repo.dart';
import '../../../../model/event.dart';

class AdminHomeController {
  final EventRepo _eventRepo = EventRepo();

  List<Event> _events = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Event> get events => _events;
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


  void dispose() {
    _onStateChanged = null;
  }
}