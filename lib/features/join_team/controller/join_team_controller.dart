import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/join_team/logic/join_state.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/state_management/user_provider.dart';

/// Joins a team by invite code. The [JoinFlow] holds the steps; this wires it
/// to [TeamService] and, once the player is in, to the rest of the app.
class JoinTeamController extends ChangeNotifier {
  JoinTeamController({required this.context, TeamService? teamService})
    : _teams = teamService ?? TeamService() {
    _flow = JoinFlow(preview: _teams.previewInvite, join: _teams.joinTeam);
    _flow.state.addListener(_onState);
  }

  final BuildContext context;
  final TeamService _teams;
  late final JoinFlow _flow;
  bool _disposed = false;

  JoinState get state => _flow.state.value;

  void codeChanged(String code) => _flow.codeChanged(code);

  Future<void> confirm() => _flow.confirm();

  void back() => Navigator.of(context).maybePop();

  void _onState() {
    if (_disposed) return;
    notifyListeners();
    final current = state;
    if (current is Joined) _finish(current.eventIds);
  }

  /// The events join the player's own; the first one that is known opens
  /// in place of this screen. With none, the screen closes.
  void _finish(List<String> eventIds) {
    final user = context.read<UserProvider>();
    final events = context.read<EventList>();
    final navigator = Navigator.of(context);
    Event? first;
    for (final id in eventIds) {
      user.addRegisteredEvent(id);
      first ??= events.getEventById(id);
    }

    final event = first;
    if (event == null) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed(
        Routes.eventDetails,
        arguments: {'event': event, 'isAdmin': false},
      );
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _flow.state.removeListener(_onState);
    _flow.dispose();
    super.dispose();
  }
}
