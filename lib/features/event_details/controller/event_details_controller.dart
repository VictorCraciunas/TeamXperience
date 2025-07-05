import 'package:provider/provider.dart';
import 'package:teamxperience/model/user.dart';

import '../../../model/event.dart';
import '../../../state_management/user_provider.dart';

class EventDetailsController{
  late Event  event;
  late AppUser? user;

  EventDetailsController(this.event, context){
    user = Provider.of<UserProvider>(context, listen: false).currentUser;
  }

}