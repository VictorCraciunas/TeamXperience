import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/backend/repo/teamRepo.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/user.dart';
import 'package:teamxperience/service/team_service/team_service.dart';

import '../../../constants/routes.dart';
import '../../../model/event.dart';
import '../../../state_management/user_provider.dart';

class EventDetailsController{
  late Event  event;
  late AppUser? user;
  late BuildContext context;
  TeamService service = TeamService();

  EventDetailsController(this.event, this.context){
    user = Provider.of<UserProvider>(context, listen: false).currentUser;
  }

  void navigateToMap() {
    Stream<List<Team>> teams =  service.getStreamTeams(event.eventId);
    if(context.mounted){
      Navigator.pushNamed(
        context,
        Routes.map,
          arguments: {
            'eventId': event.eventId,
            'teams': teams,
          },
      );
    }
  }

}