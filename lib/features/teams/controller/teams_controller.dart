import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/teams/widgets/new_crew_sheet.dart';
import 'package:teamxperience/model/crew.dart';
import 'package:teamxperience/service/share_service.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/ui/components/feedback/snackbars.dart';
import 'package:teamxperience/utils/invite_code.dart';

/// The Echipe screen: follows the crews the player belongs to and starts
/// the two ways to get into one, a new crew or a code.
class TeamsController extends ChangeNotifier {
  TeamsController({
    required this.context,
    TeamService? teamService,
    ShareService? shareService,
  }) : _teams = teamService ?? TeamService(),
       _share = shareService ?? ShareService() {
    _subscribe();
  }

  final BuildContext context;
  final TeamService _teams;
  final ShareService _share;
  StreamSubscription<List<Crew>>? _subscription;
  bool _disposed = false;

  /// Null until the first answer.
  List<Crew>? crews;
  Object? error;

  String get myUid => context.read<UserProvider>().currentUser?.uid ?? '';

  bool get loading => crews == null && error == null;

  void _subscribe() {
    final uid = myUid;
    if (uid.isEmpty) {
      crews = const [];
    } else {
      _subscription = _teams
          .streamUserCrews(uid)
          .listen(_onCrews, onError: _onError);
    }
  }

  /// Follows the crews again after an error.
  void retry() {
    _subscription?.cancel();
    crews = null;
    error = null;
    notifyListeners();
    _subscribe();
  }

  void _onCrews(List<Crew> value) {
    crews = value;
    error = null;
    if (!_disposed) notifyListeners();
  }

  void _onError(Object e) {
    error = e;
    if (!_disposed) notifyListeners();
  }

  /// Makes a crew called [name] and returns its invite code as shown.
  Future<String> createCrew(String name) async {
    final made = await _teams.createCrew(name);
    return displayCode(made.inviteCode);
  }

  void openJoin() => Navigator.pushNamed(context, Routes.joinTeam);

  void openNewCrew() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder:
          (_) => NewCrewSheet(
            onCreate: createCrew,
            onShare: (name, code) => _shareInvite(name, code),
            onCopy: _copyCode,
          ),
    );
  }

  void share(Crew crew) => _shareInvite(crew.name, crew.displayCode);

  Future<void> copy(Crew crew) => _copyCode(crew.displayCode);

  void _shareInvite(String name, String code) {
    _share.shareCrewInvite(context, code: code, crewName: name);
  }

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (context.mounted) {
      MySnackBars.successSnackBar(context, title: 'Cod copiat');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
