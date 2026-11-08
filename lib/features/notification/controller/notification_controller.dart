import 'package:flutter/cupertino.dart';
import 'package:teamxperience/backend/functions/notification_functions.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/feedback/snackbars.dart';

import '../logic/notification_failure_text.dart';

class NotificationController{
  final titluNotificareController = TextEditingController();
  final descriereNotificareController = TextEditingController();
  final BuildContext context;
  final Event? event;

  NotificationController(this.context, {this.event});


  Future<void> sendNotification() async {
    try {
      await NotificationFunctions().send(
        title: titluNotificareController.text,
        description: descriereNotificareController.text,
        eventId: event?.eventId,
      );
      if (!context.mounted) return;
      MySnackBars.successSnackBar(context, title: "Notificarea a fost trimisă cu succes");
    } catch (e) {
      if (!context.mounted) return;
      MySnackBars.errorSnackBar(context, title: notificationFailureText(e));
    }
  }
}
