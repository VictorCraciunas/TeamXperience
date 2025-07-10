import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/service/team_service/team_service.dart';

import '../../../constants/routes.dart';
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
        Navigator.pushNamed(context, Routes.eventGame, arguments: { 'event' : event, 'team': await teamService.getUserTeamForEvent(event.eventId, currentUser.uid)});
      } else {
        print("wrong code");
      }
    }

  }
}
