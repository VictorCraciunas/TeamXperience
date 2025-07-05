import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/features/home/controller/home_controller.dart';

import '../../../constants/colors.dart';
import '../../../constants/padding.dart';
import '../../../state_management/events_state_management.dart';
import '../../../state_management/news_state_management.dart';
import '../../../widgets/event_card/events_carousel.dart';
import '../../../widgets/stire_card/stiri_carousel.dart';
import '../../admin/home/widgets/title_carousel.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late  HomeController controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     controller = HomeController(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadInitialData();
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
                      // News Section
                      StiriCarousel(
                        stiri: newsList.getLatestNews(5), // Show latest 5 news
                        onStireTap: controller.navigateToStireDetails,
                        showBadge: false,
                      ),
                      const SizedBox(height: 30),

                      // Events Section
                      TitleCarousel(
                        text: "Evenimente",
                        onTap: controller.navigateToEventDashboard,
                      ),
                      const SizedBox(height: 20),
                      EventsCarousel(
                        events: eventList.upcomingEvents,
                        onEventTap: controller.navigateToEventDetails,
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
