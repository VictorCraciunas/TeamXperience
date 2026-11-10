import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teamxperience/model/user.dart';
import 'package:teamxperience/service/team_service/team_errors.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/ui/components/feedback/snackbars.dart';
import 'package:teamxperience/utils/invite_code.dart';
import 'package:teamxperience/utils/team_names.dart';

import '../../../model/event.dart';
import '../../../model/team.dart';
import '../../../service/share_service.dart';

class TeamControllerDetails {
  late Event event;
  late AppUser? user;
  final TeamService teamService;
  late List<Team> teams;

  ShareService shareService = ShareService();
  Team? team;
  bool isLoading = true;
  bool isEditing = false;
  bool isSaving = false;

  /// The captain's phone, and the team's name while [canRename].
  late TextEditingController phoneController;
  late TextEditingController nameController;

  TeamControllerDetails(this.user, this.event, {TeamService? teamService})
    : teamService = teamService ?? TeamService() {
    phoneController = TextEditingController();
    nameController = TextEditingController();
    initializeTeam();
  }

  /// Its crew's, stored there because anyone signed in can read a team.
  String? _inviteCode;

  /// As shown, "VLP-482"; null when there is none to show.
  String? get displayInviteCode {
    final code = _inviteCode;
    return code == null ? null : displayCode(code);
  }

  /// The invite code is for the captain to pass on.
  bool get showsInviteCode => _inviteCode != null;

  Future<void> _loadInviteCode() async {
    final current = team;
    final player = user;
    final crewId = current?.crewId;
    if (current == null || player == null || crewId == null || current.captainUid != player.uid) return;
    try {
      _inviteCode = await teamService.crewInviteCode(crewId);
    } catch (_) {
      // The rest of the page still works.
    }
  }

  void populateControllers() {
    final currentTeam = team;
    if (currentTeam == null) return;
    phoneController.text = currentTeam.phoneNumber;
    nameController.text = currentTeam.name;
  }

  void disposeControllers() {
    phoneController.dispose();
    nameController.dispose();
  }

  /// The captain may rename the team until the game starts.
  bool canRename([DateTime? now]) {
    final current = team;
    final player = user;
    if (current == null || player == null || current.captainUid != player.uid || current.hasStarted) return false;
    final start = event.dateEvent;
    return start == null || (now ?? DateTime.now()).isBefore(start);
  }

  /// Saves the edits: a new name first (the server moves the team), then the
  /// phone under the name the team has now. Null once saved, else what to say.
  Future<String?> save() async {
    final currentTeam = team;
    if (currentTeam == null) return 'Nu s-au putut salva modificările.';

    var name = currentTeam.name;
    var renamed = false;
    final wanted = cleanTeamName(nameController.text);
    if (canRename() && wanted != name) {
      if (teamNameProblem(wanted) != null) return teamErrorText(TeamError.nameInvalid);
      try {
        name = await teamService.renameTeam(event.eventId, name, wanted);
        renamed = true;
      } catch (e) {
        // It may have gone through before the answer was lost: show the team
        // as it is now, so a retry starts from the right name.
        team = await _fresh(currentTeam);
        return teamErrorText(TeamError.fromException(e));
      }
    }

    final phone = phoneController.text.trim();
    if (phone != currentTeam.phoneNumber) {
      try {
        await teamService.updateTeamPhone(event.eventId, name, phone);
      } catch (e) {
        team = await _fresh(currentTeam);
        return renamed ? 'Numele s-a schimbat, dar telefonul nu s-a salvat.' : 'Nu s-au putut salva modificările.';
      }
    }
    team = await _fresh(currentTeam);
    return null;
  }

  /// The team as saved now, or [fallback] when it cannot be read.
  Future<Team> _fresh(Team fallback) async {
    try {
      return await _getTeam() ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  Future<void> initializeTeam() async {
    team = await _getTeam();
    await _loadInviteCode();
    await loadTeams();
    isLoading = false;
  }

  Future<Team?> _getTeam() async {
    final currentUser = user;
    if (currentUser != null) {
      return await teamService.getUserTeamForEvent(
        event.eventId,
        currentUser.uid,
      );
    }
    return null;
  }

  /// Passes the invite code on through the share sheet.
  void shareInvite(BuildContext context) {
    final current = team;
    final code = displayInviteCode;
    if (current == null || code == null) return;
    shareService.shareInvite(
      context,
      code: code,
      teamName: current.name,
      eventName: event.name ?? '',
    );
  }

  Future<void> copyInvite(BuildContext context) async {
    final code = displayInviteCode;
    if (code == null) return;
    await Clipboard.setData(ClipboardData(text: code));
    if (context.mounted) {
      MySnackBars.successSnackBar(context, title: 'Cod copiat');
    }
  }

  /// Shares team registration using general share sheet
  Future<void> shareTeamRegistration(BuildContext context) async {
    final currentTeam = team;
    if (currentTeam == null) {
      MySnackBars.warningSnackBar(
        context,
        title: 'Nu există echipă de partajat',
        message: 'Echipa nu a fost găsită sau nu există.',
      );
      return;
    }

    final success = await shareService.shareTeamRegistration(
      currentTeam,
      event,
      context,
    );
    _handleShareResult(context, success, 'general');
  }

  Future<void> loadTeams() async {
    teams = await teamService.getTeams(event.eventId);
  }

  /// Handles the result of sharing operations
  void _handleShareResult(BuildContext context, bool success, String method) {
    if (success) {
      switch (method) {
        case 'general':
          MySnackBars.successSnackBar(
            context,
            title: 'Mesaj partajat cu succes!',
          );
          break;
        case 'whatsapp':
          MySnackBars.successSnackBar(context, title: 'Partajat pe WhatsApp');
          break;
        case 'email':
          MySnackBars.successSnackBar(
            context,
            title: 'Email deschis cu succes',
          );
          break;
        case 'sms':
          MySnackBars.successSnackBar(context, title: 'SMS deschis cu succes');
          break;
      }
    } else {
      switch (method) {
        case 'general':
          MySnackBars.errorSnackBar(context, title: 'Eroare la partajare');
          break;
        case 'whatsapp':
          MySnackBars.errorSnackBar(
            context,
            title: 'WhatsApp indisponibil',
            message: 'WhatsApp nu este disponibil pe acest dispozitiv',
          );
          break;
        case 'email':
          MySnackBars.errorSnackBar(
            context,
            title: 'Email indisponibil',
            message: 'Nu s-a putut deschide aplicația de email',
          );
          break;
        case 'sms':
          MySnackBars.errorSnackBar(
            context,
            title: 'SMS indisponibil',
            message: 'Nu s-a putut deschide aplicația de SMS',
          );
          break;
      }
    }
  }
}
