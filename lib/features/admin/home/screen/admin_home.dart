import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/constants/padding.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/admin/home/widgets/navigate_card.dart';
import '../../../../backend/authentication/AuthenticationRepository.dart';
import '../../../../model/event.dart';
import '../../../../widgets/event_card/events_slider.dart';
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

    // Load events when the page initializes
    controller.loadEvents();
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
        'isAdmin': true, // or false
      },
    );
  }
  void _navigateToCreateNews() {
    Navigator.pushNamed(
      context,
      Routes.createNews,
    );
  }

  void _navigateToEventDashboard() {
    Navigator.pushNamed(
      context,
      Routes.eventDashboard,
      arguments: controller.events,
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
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Evenimente",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: MyColors.blackColor,
                      ),
                    ),
                    InkWell(
                      splashFactory: InkSplash.splashFactory,
                      onTap: () => _navigateToEventDashboard(),
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          "Vezi mai multe >",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: MyColors.lightBlue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                EventsSlider(
                  events: controller.events,
                  onEventTap: _navigateToEventDetails,
                  isAdmin: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
