import 'package:flutter/cupertino.dart';
import 'package:teamxperience/backend/network/NetworkAPI.dart';
import 'package:teamxperience/backend/network/NotificationDTO.dart';
import 'package:teamxperience/backend/network/NotificationResponseDTO.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/utils/snackbars.dart';

class NotificationController{
  final titluNotificareController = TextEditingController();
  final descriereNotificareController = TextEditingController();
  final BuildContext context;
  final Event? event;

  NotificationController(this.context, {this.event});


  Future<void> sendNotification() async {
    NotificationDTO notificationDTO = NotificationDTO(
      title: titluNotificareController.text,
      description: descriereNotificareController.text,
      eventId: event?.eventId,
    );
    NotificationDTOResponse response = await NetworkAPI.sendNotification(notificationDTO);
    if (response.success) {
      MySnackBars.successSnackBar(context, title: "Notificarea a fost trimisă cu succes");
    } else {
      MySnackBars.errorSnackBar(context, title: response.message);
    }
  }
}