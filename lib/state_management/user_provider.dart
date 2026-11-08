
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

  /// Takes the XP, stats, badges and events of a fresh copy of the signed-in user's
  /// document; anyone else's, or nobody's, is ignored.
  void updateProfile(AppUser fresh) {
    final user = _currentUser;
    if (user == null || user.uid != fresh.uid) return;
    _currentUser = user.copyWith(
      xp: fresh.xp,
      stats: fresh.stats,
      badges: fresh.badges,
      // A captain signing up the crew adds the event from the server.
      registeredEventIds: fresh.registeredEventIds,
    );
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    _firebaseUser = null;
    notifyListeners();
  }

  void addRegisteredEvent(String eventId) {
    final user = _currentUser;
    if (user == null || user.registeredEventIds.contains(eventId)) return;
    _currentUser = user.copyWith(registeredEventIds: [...user.registeredEventIds, eventId]);
    notifyListeners();
  }

}