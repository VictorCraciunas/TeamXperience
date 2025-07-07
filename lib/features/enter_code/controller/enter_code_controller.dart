import 'package:flutter/cupertino.dart';
import 'package:teamxperience/model/event.dart';

import '../../../constants/routes.dart';

class EnterCodeController{
  late BuildContext context;
  TextEditingController codeController = TextEditingController();
  late Event event;

  EnterCodeController(this.event, this.context);

  void navigateToGame(){
    if(codeController.text == event.startCode){
      Navigator.pushNamed(
          context,
          Routes.eventGame,
          arguments: event
      );
    }
    else{
      print("wrong code");
    }
  }
}