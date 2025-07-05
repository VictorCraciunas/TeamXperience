import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/utils/image_helper.dart';
import 'package:teamxperience/utils/calendar_helper.dart';
import '../../../model/event.dart';
import '../EventImage.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final bool isAdmin;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    // Use CalendarHelper for date formatting
    final dateFormatted = CalendarHelper.formatEventCardDate(event.dateEvent);
    final month = dateFormatted['month']!;
    final day = dateFormatted['day']!;

    return Card(
      shadowColor: const Color(0xFF0B2F63).withValues(alpha: 0.1),
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        splashFactory: InkSplash.splashFactory,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image with Stack
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: EventImage(
                event: event,
                eventImageCache: ImageHelper.eventImageCache,
                isAdmin: isAdmin,
                height: 175,
              ),
            ),

            // Event Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Container(
                    height: 60,
                    width: 63,
                    decoration: BoxDecoration(
                      color: MyColors.transparentLightBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          month,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: MyColors.blackColor,
                          ),
                        ),
                        Text(
                          day,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: MyColors.blackColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/location.svg',
                              width: 14,
                              height: 14,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                event.location ?? "No Location",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF545454),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          event.name ?? "No Title",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: MyColors.blackColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}