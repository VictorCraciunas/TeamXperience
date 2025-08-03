import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/constants/padding.dart';
import 'package:teamxperience/features/notification/controller/notification_controller.dart';
import 'package:teamxperience/widgets/my_appbar.dart';
import 'package:teamxperience/widgets/my_button.dart';
import 'package:teamxperience/widgets/my_text_field.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    NotificationController controller = NotificationController(context);


    return Scaffold(
      appBar: MyAppBar(appBarText: "Trimite notificare"),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MyPaddings.appHorizontalPadding,
          ),
          child: Column(
            children: [
              SizedBox(height: 10),
              MyTextField(
                labelText: "Titlu",
                borderColor: MyColors.lightBlue,
                hintText: "Titlu notificare...",
                controller: controller.titluNotificareController,
              ),
              SizedBox(height: 15),
              MyTextField(
                labelText: "Descriere",
                borderColor: MyColors.lightBlue,
                hintText: "Descriere notificare...",
                maxLines: null,
                keyboardType: TextInputType.multiline,
                controller: controller.descriereNotificareController,

              ),
              SizedBox(height: 30),
              MyButton(
                buttonText: "Trimite",
                textColor: Colors.white,
                buttonOnTap: () {
                  controller.sendNotification();
                },
                withBorder: false,
                gradient: MyColors.myGradient,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
