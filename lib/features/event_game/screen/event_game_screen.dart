import 'package:flutter/material.dart';
import 'package:teamxperience/constants/padding.dart';

import '../../../constants/routes.dart';
import '../../../model/event.dart';
import '../controller/event_game_controller.dart';

class EventGameScreen extends StatefulWidget {
  const EventGameScreen({super.key});

  @override
  State<EventGameScreen> createState() => _EventGameScreenState();
}

class _EventGameScreenState extends State<EventGameScreen> {
  late EventGameController controller;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (!_initialized) {
      final event = ModalRoute.of(context)!.settings.arguments as Event;

      controller = EventGameController(event,context);
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MyPaddings.appHorizontalPadding,
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.event.nrMissions ,
                  itemBuilder: (context, index) {
                    return ElevatedButton(
                        onPressed: ()  {
                            Navigator.pushNamed(
                              context,
                              Routes.puzzleGame,
                              arguments: {
                                'mission': controller.event.missions[index],
                                'background': controller.background,
                              },
                            );
                        }, child: Text("Missiune $index"));
                  },

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
