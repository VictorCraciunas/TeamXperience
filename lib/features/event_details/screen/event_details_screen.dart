import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/constants/padding.dart';
import 'package:teamxperience/features/event_details/controller/event_details_controller.dart';
import 'package:teamxperience/features/event_details/widgets/detail_widget.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/utils/calendar_helper.dart';
import 'package:teamxperience/utils/image_helper.dart';
import 'package:teamxperience/widgets/EventImage.dart';
import 'package:teamxperience/widgets/my_appbar.dart';
import 'package:teamxperience/widgets/my_button.dart';

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late EventDetailsController controller;
  late bool isAdmin;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (!_initialized) {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final event = arguments['event'] as Event;
      isAdmin = arguments['isAdmin'] as bool? ?? false;

      controller = EventDetailsController(event);
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventDateTime = CalendarHelper.formatEventDateTime(
      controller.event.dateEvent,
    );

    return Scaffold(
      appBar: MyAppBar(
        appBarText: "Detalii Eveniment",
        iconString: 'assets/images/menu.svg',
        showDropdown: true,
        event: controller.event,
      ),
      bottomNavigationBar:
          isAdmin == true
              ? SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: MyButton(
                    buttonText: "Vezi echipele inscrise",
                    textColor: Colors.white,
                    buttonOnTap: () {},
                    withBorder: false,
                    gradient: MyColors.myGradient,
                    buttonTextSize: 15,
                  ),
                ),
              )
              : SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: MyButton(
                    buttonText: "Inscrie-ti echipa",
                    textColor: Colors.white,
                    buttonOnTap: () {},
                    withBorder: false,
                    gradient: MyColors.myGradient,
                    buttonTextSize: 15,
                  ),
                ),
              ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MyPaddings.appHorizontalPadding,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                EventImage(
                  event: controller.event,
                  eventImageCache: ImageHelper.eventImageCache,
                  isAdmin: isAdmin,
                  height: 194,
                ),
                const SizedBox(height: 10),
                Text(
                  controller.event.name ?? "Nu avem nume eveniment",
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: MyColors.blackColor,
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
                  text2: 'Punct de start: ${controller.event.punctDeStart ?? "No starting point"}',
                  iconPath: 'assets/images/location_map.svg',
                ),
                const SizedBox(height: 30),
                Text(
                  controller.event.description ?? "No description",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),

                // ------ Detalii ------
                const Text(
                  "Detalii",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: MyColors.blackColor,
                  ),
                ),
                const SizedBox(height: 12),
                DetailWidget(
                  text1: "Lungime traseu",
                  text2: controller.event.lungimeTraseu ?? "No track length",
                  iconPath: 'assets/images/traseu.svg',
                ),
                const SizedBox(height: 10),
                DetailWidget(
                  text1: "Durata",
                  text2: controller.event.durata ?? "No duration",
                  iconPath: 'assets/images/timer.svg',
                ),
                const SizedBox(height: 10),
                DetailWidget(
                  text1: "Dificultate",
                  text2: controller.event.dificultate ?? "No dificulty ",
                  iconPath: 'assets/images/location_map.svg',
                ),
                const SizedBox(height: 20),
                if (isAdmin == true)
                  MyButton(
                    buttonText: "Trimite notificare",
                    textColor: MyColors.blackColor,
                    buttonOnTap: () {},
                    withBorder: false,
                    buttonColor: MyColors.transparentLightBlue,
                    leading: SvgPicture.asset(
                      'assets/images/notification2.svg',
                      width: 24,
                      height: 24,
                    ),
                  ),
                const SizedBox(height: 10),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
