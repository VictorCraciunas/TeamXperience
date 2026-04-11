import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/features/home/controller/home_controller.dart';

import '../../../constants/colors.dart';
import '../../../constants/padding.dart';
import '../../../constants/routes.dart';
import '../../../model/team.dart';
import '../../../model/user.dart';
import '../../../state_management/events_state_management.dart';
import '../../../state_management/news_state_management.dart';
import '../../../state_management/user_provider.dart';
import '../../../state_management/user_registered_events.dart'; // Add this import
import '../../../widgets/event_card/events_carousel.dart';
import '../../../widgets/registered_events/registered_event_card.dart';
import '../../../widgets/registered_events/registered_events_carousel.dart';
import '../../../widgets/stire_card/stiri_carousel.dart';
import '../../admin/home/widgets/title_carousel.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late HomeController controller;

  @override
  void initState() {
    super.initState();
    controller = HomeController(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadInitialData();
      context.read<UserEventsProvider>().loadActiveEvent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("User Home"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: controller.logout,
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer3<EventList, NewsList, UserEventsProvider>(
          builder: (context, eventList, newsList, userEventsProvider, child) {
            final nextEvent = userEventsProvider.nextEventWithinHour;
            if ((eventList.isLoading && !eventList.hasData) ||
                (newsList.isLoading && !newsList.hasData)) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: controller.refreshData,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MyPaddings.appHorizontalPadding,
                  ),
                  child: Column(
                    children: [
                      // News Section
                      StiriCarousel(
                        stiri: newsList.getLatestNews(5),
                        onStireTap: controller.navigateToStireDetails,
                        showBadge: false,
                      ),
                      const SizedBox(height: 30),
                      if (nextEvent != null)
                        RegisteredEventCard(
                          event: nextEvent,
                          onEventTap: (event) async {
                            // Use cached active team if available
                            Team? team = userEventsProvider.activeTeam;
                            if (team == null) {
                              AppUser? currentUser =
                                  context.read<UserProvider>().currentUser;
                              team = await controller.teamService
                                  .getUserTeamForEvent(
                                    event.eventId,
                                    currentUser!.uid,
                                  );
                            }
                            if (team == null) {
                              print("nu trebuia sa ajunga aci wtf");
                            } else if (!team.hasStarted) {
                              controller.navigateToEnterCodeScreen(event);
                            } else {
                              Navigator.pushNamed(
                                context,
                                Routes.eventGame,
                                arguments: {'event': event, 'team': team},
                              );
                            }
                          },
                          upComingRegisteredEvent: true,
                        ),
                      const SizedBox(height: 30),

                      // Registered Events Section (show only if user has registered events)
                      if (userEventsProvider
                          .upcomingRegisteredEvents
                          .isNotEmpty) ...[
                        TitleCarousel(
                          text: "Înscrierile tale",
                          onTap: controller.navigateToEventDashboard,
                        ),
                        const SizedBox(height: 20),
                        RegisteredEventsCarousel(
                          events: userEventsProvider.upcomingRegisteredEvents,
                          onEventTap:
                              (event) =>
                                  controller.navigateToTeamDetails(event),
                        ),
                        const SizedBox(height: 30),
                      ],

                      // All Events Section
                      TitleCarousel(
                        text: "Evenimente",
                        onTap: controller.navigateToEventDashboard,
                      ),
                      const SizedBox(height: 20),
                      EventsCarousel(
                        events: eventList.upcomingEvents,
                        onEventTap: controller.navigateToEventDetails,
                        isAdmin: false,
                        eventStats: const {},
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
