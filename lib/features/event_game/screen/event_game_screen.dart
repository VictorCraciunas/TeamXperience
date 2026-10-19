import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/constants/padding.dart';
import 'package:teamxperience/enums/missions_state.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/widgets/misison_state_widget.dart';
import 'package:teamxperience/ui/components/buttons/my_button.dart';

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
  bool _endedDialogShown = false;

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    controller.dispose();
    super.dispose();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final event = arguments['event'] as Event;
      final team = arguments['team'] as Team?;

      controller = EventGameController(event, team, context);
      controller.addListener(_onControllerChanged);
      _initialized = true;

      if (controller.eventEnded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showEventEndedDialog();
        });
      }
    }
  }

  void _onControllerChanged() {
    if (controller.eventEnded && !_endedDialogShown) {
      _showEventEndedDialog();
    }
  }

  void _showEventEndedDialog() {
    if (_endedDialogShown || !mounted) return;
    _endedDialogShown = true;

    Navigator.popUntil(
      context,
      (route) => route.settings.name == Routes.eventGame || route.isFirst,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Ne pare rău"),
        content: const Text("S-a terminat evenimentul."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  if (controller.event.landingImageUrl != null)
                    Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: controller.event.landingImageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 268,
                        ),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: GestureDetector(
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: const Color(0x90FFFFFF),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: SvgPicture.asset(
                                  'assets/images/back_icon.svg',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  Transform.translate(
                    offset: const Offset(0, -30),
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: MyPaddings.appHorizontalPadding,
                          ),
                          child: Column(
                            children: [
                              ...List.generate(controller.event.nrMissions, (
                                index,
                              ) {
                                return Column(
                                  children: [
                                    MissionStateWidget(
                                      missionState: controller.getMissionState(
                                        index,
                                      ),
                                      onTap: () async {
                                        final updatedTeam =
                                            await Navigator.pushNamed(
                                                  context,
                                                  Routes.puzzleGame,
                                                  arguments: {
                                                    'mission':
                                                        controller
                                                            .event
                                                            .missions[index],
                                                    'background':
                                                        controller.background,
                                                    'event': controller.event,
                                                    'team': controller.team,
                                                    'missionIndex': index,
                                                  },
                                                )
                                                as Team?;

                                        // If team was updated, refresh the mission states
                                        if (updatedTeam != null) {
                                          setState(() {
                                            controller.team = updatedTeam;
                                            controller.initMissionState();
                                          });
                                        }
                                      }, // You'll need to implement this
                                      nr: index + 1,
                                    ),
                                    if (index <
                                        controller.event.nrMissions -
                                            1) // Don't add spacing after last item
                                      SizedBox(height: 10),
                                  ],
                                );
                              }),
                              SizedBox(height: 50),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                      color: MyColors.lightBlue,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5.0,
                                        horizontal: 15,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Ai nevoie de ajutor ?",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        Routes.chatScreen,
                                        arguments: {
                                          'eventId' : controller.event.eventId,
                                          'team': controller.team
                                        },
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                        color: MyColors.lightBlue,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: SvgPicture.asset(
                                          'assets/images/messages.svg',
                                          width: 34,
                                          // Reasonable size for the icon
                                          height: 34,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
