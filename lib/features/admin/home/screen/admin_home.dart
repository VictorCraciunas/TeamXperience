import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/constants/padding.dart';
import 'package:teamxperience/features/admin/home/widgets/navigate_card.dart';
import 'package:teamxperience/features/admin/home/widgets/title_carousel.dart';
import 'package:teamxperience/features/event_management/widgets/management_button.dart';
import 'package:teamxperience/widgets/my_appbar.dart';
import 'package:teamxperience/ui/components/buttons/my_button.dart';
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
      backgroundColor: MyColors.backgroundColor,
      appBar: MyAppBar(
        appBarText: "TeamXperience",
        trailing: GestureDetector(
          onTap: controller.logout,
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: MyColors.transparentLightBlue,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Center(
              child: Icon(Icons.logout_rounded, size: 22, color: MyColors.lightBlue),
            ),
          ),
        ),
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
                    vertical: MyPaddings.topPaddingHome
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: NavigateCard(
                              text1: "Creează",
                              text2: "eveniment",
                              onTap: controller.navigateToCreateEvent,
                            ),
                          ),
                          const SizedBox(width: 25),
                          Expanded(
                            child: NavigateCard(
                              text1: "Adaugă",
                              text2: "știre",
                              onTap: controller.navigateToCreateNews,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Center(
                        child: NavigateCard(
                          text1: "Trimite",
                          text2: "notificare",
                          onTap: () {controller.navigateToNotification();},
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (eventList.liveEvents.isNotEmpty) ...[
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE53935),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Eveniment live",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFE53935),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        ...eventList.liveEvents.map(
                          (event) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: const Color(0x1AE53935),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: const Color(0xFFE53935),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.name ?? "",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: MyColors.blackColor,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ManagementButton(
                                    text: "Gestionează eveniment",
                                    icon: 'assets/images/incepe_jocul.svg',
                                    enabled: true,
                                    onTap: () => controller
                                        .navigateToEventManagement(event),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Events Section
                      TitleCarousel(
                        text: "Evenimente",
                        onTap: controller.navigateToEventDashboard,
                      ),
                      const SizedBox(height: 20),
                      AnimatedBuilder(
                        animation: controller,
                        builder:(context,child){return EventsCarousel(
                          events: eventList.upcomingEvents,
                          onEventTap: controller.navigateToEventDetails,
                          isAdmin: true,
                          eventStats: controller.eventStats,
                        );}
                      ),
                      const SizedBox(height: 20),

                      // News Section
                      TitleCarousel(
                        text: "Știri",
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
