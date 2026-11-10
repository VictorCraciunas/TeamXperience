import 'package:flutter/foundation.dart';
import 'package:teamxperience/service/team_service/invite_preview.dart';
import 'package:teamxperience/service/team_service/team_errors.dart';
import 'package:teamxperience/utils/invite_code.dart';

/// Where joining a team by code stands.
sealed class JoinState {
  const JoinState();
}

/// The code is not complete yet.
class Typing extends JoinState {
  const Typing();
}

/// A complete code is being looked up.
class Looking extends JoinState {
  const Looking();
}

/// The code belongs to a team; [preview] says whose.
class Found extends JoinState {
  const Found(this.preview);

  final InvitePreview preview;
}

/// The code was refused or the call failed; [text] is for the player.
class Problem extends JoinState {
  const Problem(this.text);

  final String text;
}

/// The player is being put into the team behind [preview].
class Joining extends JoinState {
  const Joining(this.preview);

  final InvitePreview preview;
}

/// The player is in; [eventIds] are the events whose team they entered.
class Joined extends JoinState {
  const Joined(this.eventIds);

  final List<String> eventIds;
}

/// The logic of the join screen without any widget: the code goes in, the
/// preview and the join come from the two functions, [state] says what to show.
class JoinFlow {
  JoinFlow({
    required Future<InvitePreview> Function(String code) preview,
    required Future<List<String>> Function(String code) join,
  }) : _preview = preview,
       _join = join;

  static const _codeLength = 6;

  final Future<InvitePreview> Function(String code) _preview;
  final Future<List<String>> Function(String code) _join;

  final ValueNotifier<JoinState> _state = ValueNotifier(const Typing());
  ValueListenable<JoinState> get state => _state;

  String _code = '';

  /// Counts the edits, so only the answer to the last code is used.
  int _latest = 0;
  bool _disposed = false;

  /// Edits while the player is being put into the team change nothing: the
  /// join is on its way and a second one must not start.
  void codeChanged(String code) {
    if (_state.value is Joining) return;
    final call = ++_latest;
    _code = normaliseCode(code);
    if (_code.length < _codeLength) {
      _set(const Typing());
    } else if (!isWellFormedCode(_code)) {
      _set(Problem(teamErrorText(TeamError.codeUnknown)));
    } else {
      _set(const Looking());
      _look(call, _code);
    }
  }

  Future<void> _look(int call, String code) async {
    try {
      final found = await _preview(code);
      if (call != _latest) return;
      _set(
        found.alreadyMember
            ? Problem(teamErrorText(TeamError.alreadyMember))
            : Found(found),
      );
    } catch (e) {
      if (call == _latest) _set(Problem(_textOf(e)));
    }
  }

  /// Joins the team of the code that was found. Does nothing in any other
  /// state, so a second tap while joining changes nothing.
  Future<void> confirm() async {
    final current = _state.value;
    if (current is! Found) return;
    final call = _latest;

    if (current.preview.isFull) {
      _set(Problem(teamErrorText(TeamError.teamFull)));
      return;
    }

    _set(Joining(current.preview));
    try {
      final eventIds = await _join(_code);
      // Joined even if the code was edited meanwhile: the player is in.
      _set(Joined(eventIds));
    } catch (e) {
      if (call == _latest) _set(Problem(_textOf(e)));
    }
  }

  String _textOf(Object e) => teamErrorText(
    TeamError.fromException(e),
    teamName: TeamError.teamNameFrom(e),
  );

  void _set(JoinState value) {
    if (!_disposed) _state.value = value;
  }

  void dispose() {
    _disposed = true;
    _state.dispose();
  }
}
