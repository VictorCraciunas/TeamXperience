import 'package:flutter/material.dart';
import 'package:teamxperience/features/event_details/controller/event_details_controller.dart';
import 'package:teamxperience/model/event.dart';

import '../../../constants/routes.dart';

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late EventDetailsController controller;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (!_initialized) {
      final event = ModalRoute.of(context)!.settings.arguments as Event;

      controller = EventDetailsController(event);
      _initialized = true;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(controller.event.name ?? "Nu avem nume eveniment"),
          Text(controller.event.description ?? "NU avem descriere eveniment"),
          TextButton(onPressed: (){
            Navigator.pushNamed(
              context,
              Routes.createEvent,
              arguments: {'event': controller.event, 'isBlueprint': false},
            );
          }, child: Text("Edit")),
          TextButton(onPressed: (){
            Navigator.pushNamed(
              context,
              Routes.createEvent,
              arguments: {'event': controller.event, 'isBlueprint': true},
            );
          }, child: Text("Duplicate")),
          TextButton(onPressed: (){
            Navigator.pushNamed(
              context,
              Routes.eventGame,
              arguments: controller.event
            );
          }, child: Text("see event")),

        ],
      )),
    );
  }
}
