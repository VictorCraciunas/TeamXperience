import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../model/event.dart';
import '../model/user.dart';

class UserProvider extends ChangeNotifier {
  AppUser? _currentUser;
  List<Event> _registeredEvents= [];
  User? _firebaseUser;

  AppUser? get currentUser => _currentUser;
  User? get firebaseUser => _firebaseUser;
  bool get isLoggedIn => _currentUser != null && _firebaseUser != null;

  List<Event> get registeredEvents => List.unmodifiable(_registeredEvents);

  void setUser(AppUser appUser, User firebaseUser) {
    _currentUser = appUser;
    _firebaseUser = firebaseUser;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    _firebaseUser = null;
    notifyListeners();
  }

  void addRegisteredEvent(String eventId) {
    if (_currentUser != null) {
      final updatedEventIds = List<String>.from(_currentUser!.registeredEventIds);
      if (!updatedEventIds.contains(eventId)) {
        updatedEventIds.add(eventId);

        _currentUser = AppUser(
          email: _currentUser!.email,
          firstName: _currentUser!.firstName,
          lastName: _currentUser!.lastName,
          uid: _currentUser!.uid,
          role: _currentUser!.role,
          registeredEventIds: updatedEventIds,
        );

        notifyListeners();
      }
    }
  }

}