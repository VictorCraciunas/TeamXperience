import 'package:teamxperience/model/crew.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/register_team/logic/team_name_check.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/service/share_service.dart';
import 'package:teamxperience/service/team_service/register_result.dart';
import 'package:teamxperience/service/team_service/team_errors.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/ui/components/feedback/field_status_line.dart';
import 'package:teamxperience/ui/components/feedback/snackbars.dart';
import 'package:teamxperience/utils/event_formats.dart';
import 'package:teamxperience/utils/invite_code.dart';
import 'package:teamxperience/utils/team_names.dart';

/// Registers the player's team for [event] on one screen. Once the team is
/// made, [result] holds the invite code and the same screen shows it.
class RegisterTeamController extends ChangeNotifier {
  RegisterTeamController({
    required this.context,
    required this.event,
    TeamService? teamService,
    ShareService? shareService,
  }) : _teams = teamService ?? TeamService(),
       _share = shareService ?? ShareService() {
    size = _startSize(event);
    nameCheck = TeamNameCheck(
      isFree: (name) => _teams.isTeamNameFree(event.eventId, name),
    );
    nameCheck.state.addListener(notifyListeners);
    _loadCrews();
  }

  /// The crews this captain can sign up again; none while loading or if they
  /// cannot be read, which leaves just a new team.
  List<Crew> crews = const [];

  /// The crew being signed up; null for a new team.
  Crew? chosenCrew;

  Future<void> _loadCrews() async {
    final uid = context.read<UserProvider>().currentUser?.uid;
    if (uid == null || uid.isEmpty) return;
    try {
      final all = await _teams.streamUserCrews(uid).first;
      if (_disposed) return;
      crews = [
        for (final crew in all)
          if (crew.captainUid == uid && crew.members.length <= event.teamSizeMax) crew,
      ];
      notifyListeners();
    } catch (_) {
      // A new team still works.
    }
  }

  /// The team must have room for everyone in the chosen crew.
  int get sizeMin {
    final members = chosenCrew?.members.length ?? 0;
    return members > event.teamSizeMin ? members : event.teamSizeMin;
  }

  /// Signs up [crew] under its name, or goes back to a new team.
  void chooseCrew(Crew? crew) {
    chosenCrew = crew;
    if (crew != null) {
      nameController.text = crew.name;
      onNameChanged(crew.name);
      if (size < sizeMin) size = sizeMin;
    }
    notifyListeners();
  }

  final BuildContext context;
  final Event event;
  final TeamService _teams;
  final ShareService _share;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  late final TeamNameCheck nameCheck;

  late int size;
  bool rulesAccepted = false;
  bool photoConsent = false;
  bool sending = false;

  /// Set once the team is registered.
  RegisterResult? result;
  bool _disposed = false;

  bool get registered => result != null;

  FieldStatus get nameStatus => nameCheck.state.value.$1;
  String get nameStatusText => nameCheck.state.value.$2;

  /// The invite code as shown, "VLP-482".
  String get displayInviteCode => displayCode(result?.inviteCode ?? '');

  /// Who went into the team: the crew's who were free, or just the captain.
  List<String> get teamInitials {
    final crew = chosenCrew;
    if (crew == null) return [captainInitials];
    final skipped = result?.skippedUids ?? const <String>[];
    return [for (final m in crew.members) if (!skipped.contains(m.uid)) m.initials];
  }

  /// The chosen crew's names left out of the team.
  List<String> get leftOutNames {
    final skipped = result?.skippedUids ?? const <String>[];
    final crew = chosenCrew;
    if (crew == null) return const [];
    return [for (final m in crew.members) if (skipped.contains(m.uid)) m.displayName];
  }

  /// The captain's initials, for the first place in the team.
  String get captainInitials {
    final user = context.read<UserProvider>().currentUser;
    return user == null ? '' : initialsOf('${user.firstName} ${user.lastName}');
  }

  /// The most players usually come in fours; an event with smaller teams
  /// starts at its own maximum.
  static int _startSize(Event event) {
    final size = event.teamSizeMax < 4 ? event.teamSizeMax : 4;
    return size < event.teamSizeMin ? event.teamSizeMin : size;
  }

  /// The first reason the button is disabled, or null when it can be used.
  String? get blocker {
    if (nameController.text.trim().isEmpty) return 'Scrie numele echipei';
    if (nameStatus != FieldStatus.ok) {
      return nameStatusText.isEmpty ? 'Numele nu e bun' : nameStatusText;
    }
    if (phoneController.text.trim().isEmpty) {
      return 'Scrie telefonul căpitanului';
    }
    if (!rulesAccepted) return 'Acceptă regulamentul';
    return null;
  }

  bool get canSubmit => blocker == null && !sending && !registered;

  void onNameChanged(String name) {
    nameCheck.onChanged(name);
    notifyListeners();
  }

  void onPhoneChanged(String _) => notifyListeners();

  void setSize(int value) {
    size = value;
    notifyListeners();
  }

  void setRulesAccepted(bool value) {
    rulesAccepted = value;
    notifyListeners();
  }

  void setPhotoConsent(bool value) {
    photoConsent = value;
    notifyListeners();
  }

  Future<void> submit() async {
    if (!canSubmit) return;
    final userProvider = context.read<UserProvider>();
    sending = true;
    notifyListeners();

    try {
      final made = await _teams.registerTeam(
        eventId: event.eventId,
        name: cleanTeamName(nameController.text),
        size: size,
        phone: phoneController.text.trim(),
        rulesAccepted: rulesAccepted,
        photoConsent: photoConsent,
        crewId: chosenCrew?.id,
      );
      userProvider.addRegisteredEvent(event.eventId);
      result = made;
    } catch (e) {
      final error = TeamError.fromException(e);
      if (error == TeamError.nameTaken) nameCheck.markTaken();
      if (context.mounted) {
        MySnackBars.errorSnackBar(
          context,
          title: 'Nu am putut înscrie echipa',
          message: teamErrorText(error, teamName: TeamError.teamNameFrom(e)),
        );
      }
    }

    sending = false;
    if (!_disposed) notifyListeners();
  }

  void shareInvite() {
    final made = result;
    if (made == null) return;
    _share.shareInvite(
      context,
      code: displayInviteCode,
      teamName: made.teamName,
      eventName: event.name ?? '',
    );
  }

  Future<void> copyInvite() async {
    await Clipboard.setData(ClipboardData(text: displayInviteCode));
    if (context.mounted) {
      MySnackBars.successSnackBar(context, title: 'Cod copiat');
    }
  }

  /// The cross in the bar and the back button. Once the team is made the
  /// event page underneath is out of date, so it is opened afresh.
  void close() {
    final navigator = Navigator.of(context);
    if (!registered) {
      navigator.maybePop();
      return;
    }
    navigator.popUntil((route) => route.isFirst);
    navigator.pushNamed(
      Routes.eventDetails,
      arguments: {'event': event, 'isAdmin': false},
    );
  }

  @override
  void dispose() {
    _disposed = true;
    nameCheck.state.removeListener(notifyListeners);
    nameCheck.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
