import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/constants/padding.dart';
import 'package:teamxperience/model/user.dart';
import 'package:teamxperience/widgets/my_appbar.dart';
import 'package:teamxperience/widgets/my_button.dart';

import '../../../constants/colors.dart';
import '../../../model/event.dart';
import '../../../utils/calendar_helper.dart';
import '../../../utils/image_helper.dart';
import '../../../widgets/EventImage.dart';
import '../../event_details/widgets/detail_widget.dart';
import '../controller/team_details_controller.dart';
import '../widgets/team_detail_widget.dart';

class TeamDetailsScreen extends StatefulWidget {
  const TeamDetailsScreen({super.key});

  @override
  State<TeamDetailsScreen> createState() => _TeamDetailsScreenState();
}

class _TeamDetailsScreenState extends State<TeamDetailsScreen> {
  late TeamControllerDetails controller;
  bool isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!isInitialized) {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final event = arguments['event'] as Event;
      final user = arguments['user'] as AppUser;

      controller = TeamControllerDetails(user, event);
      isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final eventDateTime = CalendarHelper.formatEventDateTime(
      controller.event.dateEvent,
    );

    return Scaffold(
      appBar: const MyAppBar(appBarText: "Confirmare înscriere"),
      body: SafeArea(
        child: FutureBuilder(
          future: controller.initializeTeam(),
          builder: (context, snapshot) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.team == null) {
              return const Center(child: Text('No team found for this event'));
            }

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MyPaddings.appHorizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EventImage(
                      event: controller.event,
                      eventImageCache: ImageHelper.eventImageCache,
                      isAdmin: false,
                      height: 194,
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        controller.event.name ?? "Nu avem nume eveniment",
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: MyColors.blackColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DetailWidget(
                      text1: eventDateTime['date']!,
                      text2: eventDateTime['time']!,
                      iconPath: 'assets/images/calendar_icon.svg',
                    ),
                    const SizedBox(height: 10),
                    DetailWidget(
                      text1: controller.event.location ?? "No Location",
                      text2:
                          'Punct de start: ${controller.event.punctDeStart ?? "No starting point"}',
                      iconPath: 'assets/images/location_map.svg',
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Detalii inscriere",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: MyColors.blackColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TeamDetailWidget(
                      text1: "Nume echipă",
                      text2:
                          controller
                              .team!
                              .name, // Safe to use ! here because we checked above
                    ),
                    const SizedBox(height: 15),
                    TeamDetailWidget(
                      text1: "Componență echipă",
                      text2: controller.team!.teamMembers,
                    ),
                    const SizedBox(height: 15),
                    TeamDetailWidget(
                      text1: "Nume căpitan",
                      text2: controller.team!.captainName,
                    ),
                    const SizedBox(height: 15),
                    TeamDetailWidget(
                      text1: "Email capitan",
                      text2: controller.team!.captainEmail,
                    ),
                    const SizedBox(height: 15),
                    TeamDetailWidget(
                      text1: "Telefon",
                      text2: controller.team!.phoneNumber,
                    ),

                    const SizedBox(height: 30),
                    MyButton(
                      buttonText: "Distribuie detaliile",
                      textColor: Colors.white,
                      buttonOnTap: () => controller.shareTeamRegistration(context),
                      withBorder: false,
                      gradient: MyColors.myGradient,
                      buttonTextSize: 15,
                      leading: SvgPicture.asset(
                        'assets/images/download.svg',
                        width: 19,
                        height: 19,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
