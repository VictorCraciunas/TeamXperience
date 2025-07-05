import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/service/team_service/team_service.dart';

import '../../../state_management/user_provider.dart';

class RegisterTeamController {
  late BuildContext context;
  late Event event;

  RegisterTeamController(this.context, this.event);

  TeamService teamService = TeamService();
  bool secondStep = false;
  bool thirdStep = false;

  bool checkBox1 = false;
  bool checkBox2 = false;
  bool checkBox3 = false;

  final numeEchipaController = TextEditingController();
  final componentaEchipeiController = TextEditingController();
  final numeCapitanController = TextEditingController();
  final numarDeTelefonController = TextEditingController();
  final emailCapitanController = TextEditingController();

  void buttonOnTap() {
    if (secondStep == false) {
      secondStep = true;
      return;
    } else if (thirdStep == false) {
      thirdStep = true;
      return;
    } else {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      if (user != null) {
        teamService.addTeam(
          numeEchipaController.text,
          componentaEchipeiController.text,
          numeCapitanController.text,
          numarDeTelefonController.text,
          emailCapitanController.text,
          user,
          event,
        );
      }
    }
  }
}
