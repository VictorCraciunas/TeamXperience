import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/app_svg_icon.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/utils/image_helper.dart';
import 'package:teamxperience/utils/calendar_helper.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/event/event_image.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final bool isAdmin;
  final int nrTeams;
  final int nrPerson;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    required this.isAdmin,
    required this.nrTeams,
    required this.nrPerson,
  });

  @override
  Widget build(BuildContext context) {
    // Use CalendarHelper for date formatting
    final dateFormatted = CalendarHelper.formatEventCardDate(event.dateEvent);
    final month = dateFormatted['month'] ?? 'IAN';
    final day = dateFormatted['day'] ?? '01';

    return Card(
      shadowColor: const Color(0xFF0B2F63).withValues(alpha: 0.1),
      color: context.colors.panel,
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
                nrTeams: nrTeams,
                nrPerson: nrPerson,
              ),
            ),

            // Event Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: context.colors.iconButtonBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: 60,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          month,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: context.colors.text,
                          ),
                        ),
                        Text(
                          day,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: context.colors.text,
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
                            AppSvgIcon(
                              'assets/images/location.svg',
                              width: 14,
                              height: 14,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                event.location ?? "No Location",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: context.colors.muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          event.name ?? "No Title",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.colors.text,
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
