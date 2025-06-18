import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/constants/padding.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/widgets/event_card/events_list.dart';
import 'package:teamxperience/widgets/my_appbar.dart';

import '../../constants/routes.dart';

class EventsDashboard extends StatelessWidget {
  const EventsDashboard({super.key});

  void navigateToEventDetails(BuildContext context, Event event) {
    Navigator.pushNamed(
      context,
      Routes.eventDetails,
      arguments: {
        'event': event,
        'isAdmin': true, // or false
      },
    );
  }

  void _navigateToCreateEvent(BuildContext context, {Event? event}) {
    Navigator.pushNamed(
      context,
      Routes.createEvent,
      arguments: {'event': event, 'isBlueprint': true},
    );
  }

  void _navigateToFilter(BuildContext context) {
    Navigator.pushNamed(
      context,
      Routes.filter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = ModalRoute.of(context)!.settings.arguments as List<Event>;

    return Scaffold(
      appBar: MyAppBar(appBarText: "Evenimente"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MyPaddings.appHorizontalPadding,
            vertical: 15,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => _navigateToCreateEvent(context),
                    child: Container(
                      width: 222,
                      height: 45,
                      decoration: BoxDecoration(
                        color: MyColors.transparentLightBlue,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/add_icon.svg',
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Creeza eveniment",
                            style: TextStyle(
                              fontSize: 15,
                              color: MyColors.blackColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    splashFactory: InkSplash.splashFactory,
                    onTap: () => _navigateToFilter(context),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: MyColors.transparentLightBlue,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/images/filter.svg',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: MyColors.transparentLightBlue,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/images/search.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: EventsList(
                  events: events,
                  onEventTap: (event) => navigateToEventDetails(context, event),
                  isAdmin: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
