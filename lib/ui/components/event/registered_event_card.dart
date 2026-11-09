import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';

import 'package:teamxperience/utils/calendar_helper.dart';

class RegisteredEventCard extends StatelessWidget {
  final Event event;
  final Function(Event) onEventTap;
  final bool upComingRegisteredEvent;

  const RegisteredEventCard({
    super.key,
    required this.event,
    required this.onEventTap,
    this.upComingRegisteredEvent = false,
  });

  @override
  Widget build(BuildContext context) {
    // Use CalendarHelper for date formatting
    final dateFormatted = CalendarHelper.formatEventCardDate(event.dateEvent);
    final month = dateFormatted['month'] ?? 'IAN';
    final day = dateFormatted['day'] ?? '01';

    return Card(
      shadowColor: const Color(0xFF0B2F63).withValues(alpha: 0.1),
      color:
          upComingRegisteredEvent ? context.colors.navy : context.colors.panel,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color:
                        upComingRegisteredEvent
                            ? Colors.white
                            : context.colors.iconButtonBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                const SizedBox(width: 15),
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
                            colorFilter: ColorFilter.mode(
                              upComingRegisteredEvent
                                  ? Colors.white70
                                  : context.colors.muted,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              event.location ?? "No Location",
                              style: TextStyle(
                                fontSize: 15,
                                color:
                                    upComingRegisteredEvent
                                        ? Colors.white70
                                        : context.colors.muted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.name ?? "No Title",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              upComingRegisteredEvent
                                  ? Colors.white
                                  : context.colors.text,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            AppButton(
              label:
                  upComingRegisteredEvent
                      ? 'Începe jocul'
                      : 'Detalii înscriere',
              onPressed: () => onEventTap(event),
              backgroundColor: upComingRegisteredEvent ? Colors.white : null,
              foregroundColor:
                  upComingRegisteredEvent ? context.colors.navy : null,
              leading: SvgPicture.asset(
                upComingRegisteredEvent
                    ? 'assets/images/incepe_jocul.svg'
                    : 'assets/images/user_icon.svg',
                width: 19,
                height: 19,
                colorFilter: ColorFilter.mode(
                  upComingRegisteredEvent ? context.colors.navy : Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
