import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/service/team_service/team_service.dart';

import '../../../constants/routes.dart';
import '../../../model/team.dart';
import '../../../model/user.dart';
import '../../../state_management/user_provider.dart';

class EnterCodeController {
  late BuildContext context;
  TextEditingController codeController = TextEditingController();
  TeamService teamService = TeamService();
  late Event event;

  EnterCodeController(this.event, this.context);

  void navigateToGame() async{
    AppUser? currentUser = context.read<UserProvider>().currentUser;
    if(currentUser!= null){
      if (codeController.text == event.startCode) {
        Team? team = await teamService.getUserTeamForEvent(event.eventId, currentUser.uid);
        teamService.startTeam(event.eventId, team!.name);
        Navigator.pushNamed(context, Routes.eventGame, arguments: { 'event' : event, 'team': team});
      } else {
        print("wrong code");
      }
    }

  }
}
