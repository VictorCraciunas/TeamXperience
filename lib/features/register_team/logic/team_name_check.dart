import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:teamxperience/ui/components/feedback/field_status_line.dart';
import 'package:teamxperience/utils/team_names.dart';

/// Watches the team name while it is typed: bad names are refused at once,
/// good ones are asked about on the server once typing pauses. [state] is the
/// status and the text for the line under the field.
class TeamNameCheck {
  TeamNameCheck({
    required Future<bool?> Function(String name) isFree,
    this.debounce = const Duration(milliseconds: 400),
  }) : _isFree = isFree;

  final Future<bool?> Function(String name) _isFree;
  final Duration debounce;

  final ValueNotifier<(FieldStatus, String)> _state = ValueNotifier((
    FieldStatus.neutral,
    '',
  ));
  ValueListenable<(FieldStatus, String)> get state => _state;

  Timer? _timer;

  /// Counts the calls, so only the last one's answer is used.
  int _latest = 0;
  bool _disposed = false;

  void onChanged(String name) {
    final call = ++_latest;
    _timer?.cancel();
    final cleaned = cleanTeamName(name);

    if (cleaned.isEmpty) {
      _state.value = (FieldStatus.neutral, '');
    } else if (teamNameProblem(cleaned) != null) {
      _state.value = (FieldStatus.problem, 'Numele are 2–30 de litere, fără /');
    } else {
      _state.value = (FieldStatus.checking, 'Verificăm numele…');
      _timer = Timer(debounce, () => _ask(call, cleaned));
    }
  }

  Future<void> _ask(int call, String cleaned) async {
    bool? free;
    try {
      free = await _isFree(cleaned);
    } catch (_) {
      // Any failure of the check is the same to the player as no answer.
      free = null;
    }
    if (_disposed || call != _latest) return;
    _state.value = switch (free) {
      true => (FieldStatus.ok, 'Numele e liber'),
      false => (FieldStatus.problem, 'Numele e luat'),
      null => (FieldStatus.neutral, 'Nu am putut verifica numele'),
    };
  }

  /// The server refused the name as taken although the check said it was
  /// free: somebody else registered it in between.
  void markTaken() {
    _latest++;
    _timer?.cancel();
    _state.value = (FieldStatus.problem, 'Numele e luat');
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _state.dispose();
  }
}
