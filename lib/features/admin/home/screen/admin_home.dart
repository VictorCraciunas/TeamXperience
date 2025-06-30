import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/constants/padding.dart';
import 'package:teamxperience/features/admin/home/widgets/navigate_card.dart';
import 'package:teamxperience/features/admin/home/widgets/title_carousel.dart';
import 'package:teamxperience/widgets/stire_card/stiri_carousel.dart';
import '../../../../state_management/events_state_management.dart';
import '../../../../state_management/news_state_management.dart';
import '../../../../widgets/event_card/events_carousel.dart';
import '../controller/admin_controller.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  late AdminHomeController controller;

  @override
  void initState() {
    super.initState();
    controller = AdminHomeController(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Admin Home"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: controller.logout,
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer2<EventList, NewsList>(
          builder: (context, eventList, newsList, child) {
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
                      Row(
                        children: [
                          Expanded(
                            child: NavigateCard(
                              text1: "Creeaza",
                              text2: "eveniment",
                              onTap: controller.navigateToCreateEvent,
                            ),
                          ),
                          const SizedBox(width: 25),
                          Expanded(
                            child: NavigateCard(
                              text1: "Adauga",
                              text2: "stire",
                              onTap: controller.navigateToCreateNews,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: NavigateCard(
                              text1: "Trimite",
                              text2: "notificare",
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 25),
                          Expanded(
                            child: NavigateCard(
                              text1: "Acceseaza",
                              text2: "chat",
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Events Section
                      TitleCarousel(
                        text: "Evenimente",
                        onTap: controller.navigateToEventDashboard,
                      ),
                      const SizedBox(height: 20),
                      EventsCarousel(
                        events: eventList.upcomingEvents,
                        onEventTap: controller.navigateToEventDetails,
                        isAdmin: true,
                      ),
                      const SizedBox(height: 20),

                      // News Section
                      TitleCarousel(
                        text: "Stiri",
                        onTap: controller.navigateToStiriDashboard,
                      ),
                      const SizedBox(height: 20),
                      StiriCarousel(
                        stiri: newsList.getLatestNews(5), // Show latest 5 news
                        onStireTap: controller.navigateToStireDetails,
                        showBadge: false,
                      ),
                      const SizedBox(height: 30),
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