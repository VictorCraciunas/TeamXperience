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

  TeamControllerDetails(this.user, this.event) {
    initializeTeam();
  }

  Future<void> initializeTeam() async {
    team = await _getTeam();
    await loadTeams();
    isLoading = false;
  }

  Future<Team?> _getTeam() async {
    if (user != null) {
      return await teamService.getUserTeamForEvent(event.eventId, user!.uid);
    }
    return null;
  }



  /// Shares team registration using general share sheet
  Future<void> shareTeamRegistration(BuildContext context) async {
    if (team == null) {
      MySnackBars.warningSnackBar(
          context,
          title: 'Nu există echipă de partajat',
          message: 'Echipa nu a fost găsită sau nu există.'
      );
      return;
    }

    final success = await shareService.shareTeamRegistration(team!, event, context);
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