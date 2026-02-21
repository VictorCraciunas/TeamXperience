import 'package:flutter/material.dart';
import 'package:teamxperience/backend/repo/teamRepo.dart';
import 'package:teamxperience/model/user.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/utils/snackbars.dart';

import '../../../model/event.dart';
import '../../../model/team.dart';
import '../../../service/share_service.dart';

class TeamControllerDetails {
  late Event event;
  late AppUser? user;
  TeamService teamService = TeamService();
  late List<Team> teams;

  ShareService shareService = ShareService();
  Team? team;
  bool isLoading = true;
  bool isEditing = false;
  bool isSaving = false;

  // Text editing controllers for edit mode
  late TextEditingController nameController;
  late TextEditingController membersController;
  late TextEditingController captainNameController;
  late TextEditingController captainEmailController;
  late TextEditingController phoneController;

  TeamControllerDetails(this.user, this.event) {
    nameController = TextEditingController();
    membersController = TextEditingController();
    captainNameController = TextEditingController();
    captainEmailController = TextEditingController();
    phoneController = TextEditingController();
    initializeTeam();
  }

  void populateControllers() {
    final currentTeam = team;
    if (currentTeam == null) return;

    nameController.text = currentTeam.name;
    membersController.text = currentTeam.teamMembers;
    captainNameController.text = currentTeam.captainName;
    captainEmailController.text = currentTeam.captainEmail;
    phoneController.text = currentTeam.phoneNumber;
  }

  void disposeControllers() {
    nameController.dispose();
    membersController.dispose();
    captainNameController.dispose();
    captainEmailController.dispose();
    phoneController.dispose();
  }

  Future<bool> saveChanges(BuildContext context) async {
    final currentTeam = team;
    if (currentTeam == null) return false;

    final oldTeamName = currentTeam.name;
    final newName = nameController.text.trim();

    // Check for duplicate name if the name changed
    if (newName != oldTeamName) {
      final isTaken = await teamService.teamRepo.isTeamNameTaken(event.eventId, newName);
      if (isTaken) {
        MySnackBars.warningSnackBar(
          context,
          title: 'Numele echipei este deja folosit',
          message: 'Alege un alt nume pentru echipă.',
        );
        return false;
      }
    }

    final updatedTeam = Team(
      name: newName,
      teamMembers: membersController.text.trim(),
      captainName: captainNameController.text.trim(),
      captainEmail: captainEmailController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      missionProgress: currentTeam.missionProgress,
      puzzleNumber: currentTeam.puzzleNumber,
      userIds: currentTeam.userIds,
      hasStarted: currentTeam.hasStarted,
      latitude: currentTeam.latitude,
      longitude: currentTeam.longitude,
    );

    try {
      await teamService.updateTeamDetails(event.eventId, oldTeamName, updatedTeam);
      team = updatedTeam;
      return true;
    } catch (e) {
      MySnackBars.errorSnackBar(context, title: 'Eroare la salvare', message: 'Nu s-au putut salva modificările.');
      return false;
    }
  }

  Future<void> initializeTeam() async {
    team = await _getTeam();
    await loadTeams();
    isLoading = false;
  }

  Future<Team?> _getTeam() async {
    final currentUser = user;
    if (currentUser != null) {
      return await teamService.getUserTeamForEvent(event.eventId, currentUser.uid);
    }
    return null;
  }



  /// Shares team registration using general share sheet
  Future<void> shareTeamRegistration(BuildContext context) async {
    final currentTeam = team;
    if (currentTeam == null) {
      MySnackBars.warningSnackBar(
          context,
          title: 'Nu există echipă de partajat',
          message: 'Echipa nu a fost găsită sau nu există.'
      );
      return;
    }

    final success = await shareService.shareTeamRegistration(currentTeam, event, context);
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
          MySnackBars.successSnackBar(context, title: 'Mesaj partajat cu succes!');
          break;
        case 'whatsapp':
          MySnackBars.successSnackBar(context, title: 'Partajat pe WhatsApp');
          break;
        case 'email':
          MySnackBars.successSnackBar(context, title: 'Email deschis cu succes');
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
              message: 'WhatsApp nu este disponibil pe acest dispozitiv'
          );
          break;
        case 'email':
          MySnackBars.errorSnackBar(
              context,
              title: 'Email indisponibil',
              message: 'Nu s-a putut deschide aplicația de email'
          );
          break;
        case 'sms':
          MySnackBars.errorSnackBar(
              context,
              title: 'SMS indisponibil',
              message: 'Nu s-a putut deschide aplicația de SMS'
          );
          break;
      }
    }
  }

}