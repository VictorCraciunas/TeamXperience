import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/features/notification/controller/notification_controller.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
import 'package:teamxperience/ui/components/inputs/app_text_field.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late NotificationController controller;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final event = ModalRoute.of(context)?.settings.arguments as Event?;
      controller = NotificationController(context, event: event);
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBarText =
        controller.event != null
            ? "Trimite notificare — ${controller.event!.name ?? ''}"
            : "Trimite notificare";

    return Scaffold(
      appBar: MyAppBar(appBarText: appBarText),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            children: [
              const SizedBox(height: 10),
              if (controller.event != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.iconButtonBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Această notificare va fi trimisă doar participanților înscriși la acest eveniment.",
                    style: TextStyle(fontSize: 15, color: context.colors.text),
                  ),
                ),
                const SizedBox(height: 15),
              ],
              AppTextField(
                label: "Titlu",
                hint: "Titlu notificare...",
                controller: controller.titluNotificareController,
                validator: requiredValidator("Titlu"),
              ),
              const SizedBox(height: 15),
              AppTextField(
                label: "Descriere",
                hint: "Descriere notificare...",
                maxLines: null,
                keyboardType: TextInputType.multiline,
                controller: controller.descriereNotificareController,
                validator: requiredValidator("Descriere"),
              ),
              const SizedBox(height: 30),
              AppButton(
                label: "Trimite",
                onPressed: () {
                  controller.sendNotification();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
