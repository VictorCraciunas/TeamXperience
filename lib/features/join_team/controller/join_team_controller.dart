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
    : _teams = teamService ?? TeamService(),
      _user = context.read<UserProvider>(),
      _events = context.read<EventList>(),
      _navigator = Navigator.of(context) {
    _flow = JoinFlow(preview: _teams.previewInvite, join: _joinAndRemember);
    _flow.state.addListener(_onState);
  }

  final BuildContext context;
  final TeamService _teams;

  // Taken now, so a join that ends after the screen is gone can still reach
  // them without a context.
  final UserProvider _user;
  final EventList _events;
  final NavigatorState _navigator;
  late final JoinFlow _flow;
  bool _disposed = false;

  JoinState get state => _flow.state.value;

  void codeChanged(String code) => _flow.codeChanged(code);

  Future<void> confirm() => _flow.confirm();

  void back() => _navigator.maybePop();

  /// The player is in once the server says so, whether or not this screen
  /// is still there: the events join their own.
  Future<List<String>> _joinAndRemember(String code) async {
    final eventIds = await _teams.joinTeam(code);
    eventIds.forEach(_user.addRegisteredEvent);
    return eventIds;
  }

  void _onState() {
    if (_disposed) return;
    notifyListeners();
    final current = state;
    if (current is Joined) _finish(current.eventIds);
  }

  /// The first event that is known opens in place of this screen. With none,
  /// the Echipe screen does, where the new team is.
  void _finish(List<String> eventIds) {
    Event? first;
    for (final id in eventIds) {
      first ??= _events.getEventById(id);
    }

    final event = first;
    if (event == null) {
      _navigator.pushReplacementNamed(Routes.teams);
    } else {
      _navigator.pushReplacementNamed(
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
