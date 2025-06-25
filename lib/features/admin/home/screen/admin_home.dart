import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/constants/padding.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/admin/home/widgets/navigate_card.dart';
import 'package:teamxperience/features/admin/home/widgets/title_carousel.dart';
import '../../../../backend/authentication/AuthenticationRepository.dart';
import '../../../../model/event.dart';
import '../../../../model/stire.dart';
import '../../../../widgets/event_card/events_carousel.dart';
import '../../../../widgets/stire_card/stiri_carousel.dart';
import '../controller/admin_controller.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  late AdminHomeController controller;
  final AuthenticationRepository authenticationRepository =
  AuthenticationRepository();

  @override
  void initState() {
    super.initState();
    controller = AdminHomeController();

    // Set the callback to trigger setState
    controller.setStateCallback(() {
      if (mounted) {
        setState(() {});
      }
    });

    // Load both events and stiri when the page initializes
    controller.loadAll();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _logout() {
    authenticationRepository.logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.splash,
          (Route<dynamic> route) => false,
    );
  }

  void _navigateToCreateEvent({Event? event}) {
    Navigator.pushNamed(
      context,
      Routes.createEvent,
      arguments: {'event': event, 'isBlueprint': true},
    );
  }

  void _navigateToEventDetails(Event event) {
    Navigator.pushNamed(
      context,
      Routes.eventDetails,
      arguments: {
        'event': event,
        'isAdmin': true,
      },
    );
  }

  void _navigateToStireDetails(Stire stire) {
    // Add navigation to stire details page when you create it
    // For now, just print or show a snackbar
    Navigator.pushNamed(
      context,
      Routes.newsDetails,
      arguments: stire
    );
  }

  void _navigateToCreateNews() {
    Navigator.pushNamed(context, Routes.createNews);
  }

  void _navigateToEventDashboard() {
    Navigator.pushNamed(
      context,
      Routes.eventDashboard,
      arguments: controller.events,
    );
  }

  void _navigateToStiriDashboard() {
    Navigator.pushNamed(
      context,
      Routes.newsDashboard,
      arguments: controller.stiri,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Admin Home"),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: SafeArea(
        child: controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                        text2: "evenimennt",
                        onTap: _navigateToCreateEvent,
                      ),
                    ),
                    const SizedBox(width: 25),
                    Expanded(
                      child: NavigateCard(
                        text1: "Adauga",
                        text2: "stire",
                        onTap: _navigateToCreateNews,
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
                TitleCarousel(text: "Evenimente", onTap: _navigateToEventDashboard),
                const SizedBox(height: 20),
                EventsCarousel(
                  events: controller.events,
                  onEventTap: _navigateToEventDetails,
                  isAdmin: true,
                ),
                const SizedBox(height: 20),

                // News Section
                TitleCarousel(text: "Stiri", onTap: _navigateToStiriDashboard),
                const SizedBox(height: 20),
                StiriCarousel(
                  stiri: controller.stiri,
                  onStireTap: _navigateToStireDetails,
                  isAdmin: true,
                  showBadge: false,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}