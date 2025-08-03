import 'package:flutter/cupertino.dart';
import 'package:teamxperience/backend/network/NetworkAPI.dart';
import 'package:teamxperience/backend/network/NotificationDTO.dart';
import 'package:teamxperience/backend/network/NotificationResponseDTO.dart';
import 'package:teamxperience/utils/snackbars.dart';

class NotificationController{
  final titluNotificareController = TextEditingController();
  final descriereNotificareController = TextEditingController();
  late BuildContext context;

  NotificationController(this.context);


  Future<void> sendNotification()async{
    NotificationDTO notificationDTO = NotificationDTO(title: titluNotificareController.text, description: descriereNotificareController.text);
    NotificationDTOResponse response = await NetworkAPI.sendNotification(notificationDTO);
    if(response.success){
      MySnackBars.successSnackBar(context, title: "Notificarea a fost trimisa cu success");
    }
    else{
      MySnackBars.errorSnackBar(context, title: response.message);
    }
  }
}