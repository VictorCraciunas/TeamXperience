import 'package:teamxperience/model/crew.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/features/register_team/logic/crew_prefill.dart';
import 'package:teamxperience/features/register_team/logic/team_name_check.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
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
    nameCheck.state.addListener(_onNameState);
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
  int get sizeMin => crewSizeMin(chosenCrew, event);

  /// While a crew is chosen and not being edited, its name, size and phone
  /// are filled in and greyed out; only the consents are left to tick.
  bool editing = false;

  bool get fieldsLocked => chosenCrew != null && !editing;

  /// The values filled in for the chosen crew, which "Anulează" puts back.
  CrewPrefill? _prefill;

  /// Counts the choices, so a slow read for an earlier one is dropped.
  int _choice = 0;

  /// The chosen crew's last sign-up has been read (or found missing).
  bool _lastLoaded = false;

  /// The size filled in before the last sign-up was read.
  int _firstSize = 0;

  /// Signs up [crew] with everything from its last sign-up, or goes back to
  /// an empty new team.
  void chooseCrew(Crew? crew) {
    final choice = ++_choice;
    chosenCrew = crew;
    editing = false;
    _lastLoaded = false;
    if (crew == null) {
      _prefill = null;
      _fill((name: '', size: _startSize(event), phone: ''));
      notifyListeners();
      return;
    }
    final first = crewPrefill(crew: crew, event: event, fallback: _startSize(event));
    _prefill = first;
    _firstSize = first.size;
    _fill(first);
    notifyListeners();
    _loadLastSignUp(crew, choice);
  }

  /// The size and phone of the crew's last sign-up. Edit mode opens when
  /// there is no phone to fill in, so the captain is never stuck.
  Future<void> _loadLastSignUp(Crew crew, int choice) async {
    final link = crew.lastTeamExcept(event.eventId);
    Team? last;
    if (link != null) {
      try {
        last = await _teams.getTeam(link.eventId, link.teamName);
      } catch (_) {
        // The captain types the phone.
      }
    }
    if (_disposed || choice != _choice) return;
    final prefill = crewPrefill(crew: crew, event: event, fallback: _startSize(event), last: last);
    _prefill = prefill;
    _lastLoaded = true;
    if (!editing) {
      _fill(prefill);
    } else {
      // Edit mode opened by itself before the read came back: fill in what
      // the captain has not changed yet.
      if (phoneController.text.trim().isEmpty) phoneController.text = prefill.phone;
      if (size == _firstSize) size = prefill.size;
    }
    _openIfBlocked();
    notifyListeners();
  }

  void _fill(CrewPrefill values) {
    if (nameController.text != values.name) {
      nameController.text = values.name;
      nameCheck.onChanged(values.name);
    }
    size = values.size;
    phoneController.text = values.phone;
  }

  /// "Editează": the captain changes the name, the phone or adds players.
  void startEditing() {
    if (chosenCrew == null || registered || sending) return;
    editing = true;
    notifyListeners();
  }

  /// "Anulează": back to the values filled in for the crew, locked. It stays
  /// locked even when they block the sign-up (the status line says why), so
  /// the button always does what it says.
  void cancelEditing() {
    final values = _prefill;
    if (chosenCrew == null || values == null || registered || sending) return;
    editing = false;
    _fill(values);
    notifyListeners();
  }

  /// A taken name, or one that could not be checked, opens edit mode for a
  /// chosen crew; so does a missing phone.
  void _openIfBlocked() {
    if (chosenCrew == null || editing || registered) return;
    final values = _prefill;
    if (nameStatus == FieldStatus.problem || (_lastLoaded && values != null && values.phone.isEmpty)) {
      editing = true;
    }
  }

  void _onNameState() {
    _openIfBlocked();
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
  bool dataAccepted = false;
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
    if (!dataAccepted) return 'Acceptă folosirea datelor personale';
    if (!photoConsent) return 'Acceptă fotografiile și video-urile';
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

  void setDataAccepted(bool value) {
    dataAccepted = value;
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
        dataAccepted: dataAccepted,
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

  /// The cross in the bar and "Gata": back to the event page, which
  /// reloads the team when sign-up closes.
  void close() => Navigator.of(context).maybePop();

  @override
  void dispose() {
    _disposed = true;
    nameCheck.state.removeListener(_onNameState);
    nameCheck.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
