import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/user.dart';

import '../logic/watched_chat.dart';
import '../logic/watched_events.dart';

/// Finds the chats the button watches: for a signed-in player, their team in
/// each registered event that is not over. Organisers and signed-out users
/// watch none. Looked up when the user or their registered events change
/// (signing up or joining a team changes them), and when asked to
/// ([lookAgain]: the app comes back, the team page is left, a chat can no
/// longer be read), which catches renamed teams. Nothing is read on a timer:
/// the minute tick only drops events that ended, which needs no lookup.
class ChatTeamsWatch {
  ChatTeamsWatch({
    required AppUser? Function() user,
    required List<Event> Function() registered,
    required Listenable changes,
    required Future<Team?> Function(String eventId, String uid) teamFor,
    required void Function(List<WatchedChat> chats) onChats,
    DateTime Function()? now,
    this.tick = const Duration(minutes: 1),
    this.minGap = const Duration(minutes: 1),
  })  : _user = user,
        _registered = registered,
        _changes = changes,
        _teamFor = teamFor,
        _onChats = onChats,
        _now = now ?? DateTime.now;

  final AppUser? Function() _user;
  final List<Event> Function() _registered;
  final Listenable _changes;
  final Future<Team?> Function(String eventId, String uid) _teamFor;
  final void Function(List<WatchedChat> chats) _onChats;
  final DateTime Function() _now;

  /// How often the events are checked for one that ended.
  final Duration tick;

  /// [lookAgain] looks the teams up at most once in this long; a call sooner
  /// is done at the first tick after it.
  final Duration minGap;

  Timer? _timer;
  String? _lastAsked;
  DateTime? _lastLookup;
  bool _pending = false;
  int _generation = 0;
  bool _stopped = false;

  void start() {
    _changes.addListener(_changed);
    _timer = Timer.periodic(tick, (_) {
      if (_pending && _gapPassed()) {
        _pending = false;
        refresh(force: true);
      } else {
        refresh();
      }
    });
    scheduleMicrotask(() => refresh(force: true));
  }

  // Providers may notify while a frame builds; the chats are handed over
  // after it, never in the middle.
  void _changed() => scheduleMicrotask(refresh);

  bool _gapPassed() {
    final last = _lastLookup;
    return last == null || _now().difference(last) >= minGap;
  }

  /// Looks the teams up again (one may have been renamed or left): now, or
  /// once at a later tick when the last lookup is under [minGap] old (the
  /// app comes back after every photo taken with the camera).
  void lookAgain() {
    if (_stopped) return;
    if (_gapPassed()) {
      _pending = false;
      refresh(force: true);
    } else {
      _pending = true;
    }
  }

  /// Looks the teams up when the user or their events changed, or always
  /// with [force].
  Future<void> refresh({bool force = false}) async {
    if (_stopped) return;
    final user = _user();
    if (user == null || user.role != Role.USER) {
      if (_lastAsked == '') return;
      _lastAsked = '';
      _generation++;
      _onChats(const []);
      return;
    }
    final events = eventsToWatch(_registered(), _now());
    final ids = [for (final e in events) e.eventId]..sort();
    final asked = '${user.uid}|${ids.join(',')}';
    if (!force && asked == _lastAsked) return;
    _lastAsked = asked;
    _lastLookup = _now();
    final generation = ++_generation;
    final chats = <WatchedChat>[];
    for (final event in events) {
      try {
        final team = await _teamFor(event.eventId, user.uid);
        if (team != null) chats.add(WatchedChat(event.eventId, team));
      } catch (_) {
        // Offline or not allowed: that chat waits for the next look.
      }
    }
    if (_stopped || generation != _generation) return;
    _onChats(chats);
  }

  void stop() {
    _stopped = true;
    _timer?.cancel();
    _changes.removeListener(_changed);
  }
}
