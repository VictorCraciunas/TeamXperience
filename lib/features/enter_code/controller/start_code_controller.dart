import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:teamxperience/features/enter_code/logic/start_code_check.dart';
import 'package:teamxperience/features/enter_code/logic/start_code_flow.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

/// The start-code screen: finds and follows the player's team, keeps the
/// typed code and the last refusal, and starts the team when the code is
/// right. A teammate who comes after the team started enters without a code.
class StartCodeController extends ChangeNotifier {
  StartCodeController({
    required this.event,
    required Future<Team?> Function() findTeam,
    required Stream<Team> Function(String teamName) watchTeam,
    required Future<void> Function(Team team) startTeam,
    required Future<void> Function(Event event, Team team) onEnter,
    DateTime Function() clock = DateTime.now,
  })  : _findTeam = findTeam,
        _watchTeam = watchTeam,
        _onEnter = onEnter,
        _clock = clock {
    _flow = StartCodeFlow(findTeam: () async => _team ?? await _findTeam(), startTeam: startTeam);
  }

  final Event event;
  final Future<Team?> Function() _findTeam;
  final Stream<Team> Function(String teamName) _watchTeam;
  final Future<void> Function(Event event, Team team) _onEnter;
  final DateTime Function() _clock;
  late final StartCodeFlow _flow;

  StreamSubscription<Team>? _subscription;
  Team? _team;
  String _code = '';
  StartCodeResult? _result;
  bool _busy = false;
  bool _disposed = false;

  /// The player's team, as last streamed; null when there is none.
  Team? get team => _team;
  String get code => _code;

  /// The last refusal; null when there is nothing to say.
  StartCodeResult? get result => _result;
  bool get busy => _busy;

  /// Someone in the team already entered the code.
  bool get started => _team?.hasStarted ?? false;

  /// Finds the team, then follows it.
  Future<void> load() async {
    Team? found;
    try {
      found = await _findTeam();
    } catch (e) {
      debugPrint('Start code: team lookup failed: $e');
    }
    // The screen may have closed while the team was being looked up.
    if (_disposed) return;
    _team = found;
    notifyListeners();
    if (found == null) return;
    _subscription = _watchTeam(found.name).listen(
      (team) {
        if (_disposed) return;
        final startedNow = team.hasStarted && !started;
        _team = team;
        if (startedNow) {
          _code = '';
          _result = null;
        }
        notifyListeners();
      },
      onError: (Object e) => debugPrint('Start code: team stream failed: $e'),
    );
  }

  void setCode(String code) {
    _code = code;
    _result = null;
    notifyListeners();
  }

  /// Enters the game: straight in when the team already started, else after
  /// the code is checked and the team is started. Ignored while busy.
  Future<void> submit() async {
    if (_busy) return;
    _busy = true;
    notifyListeners();
    try {
      final current = _team;
      if (started && current != null) {
        await _onEnter(event, current);
        return;
      }
      final outcome = await _flow.submit(input: _code, event: event, now: _clock());
      if (outcome == null) return;
      final (result, team) = outcome;
      if (result == StartCodeResult.ok && team != null) {
        _result = null;
        await _onEnter(event, team);
      } else {
        _result = result;
      }
    } finally {
      _busy = false;
      // Entering the game may already have closed the screen.
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
