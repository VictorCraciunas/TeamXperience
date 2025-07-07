import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/widgets/my_button.dart';

import '../../constants/colors.dart';
import '../../utils/calendar_helper.dart';

class RegisteredEventCard extends StatelessWidget {
  final Event event;
  final Function(Event) onEventTap;
  final bool upComingRegisteredEvent;

  const RegisteredEventCard({
    super.key,
    required this.event,
    required this.onEventTap,
    this.upComingRegisteredEvent = false
  });

  @override
  Widget build(BuildContext context) {
    // Use CalendarHelper for date formatting
    final dateFormatted = CalendarHelper.formatEventCardDate(event.dateEvent);
    final month = dateFormatted['month']!;
    final day = dateFormatted['day']!;

    return Card(
      shadowColor: const Color(0xFF0B2F63).withValues(alpha: 0.1),
      color: upComingRegisteredEvent ? const Color(0xFF222F62) : Colors.white,
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
                  width: 63,
                  decoration: BoxDecoration(
                    color: upComingRegisteredEvent ? Colors.white : MyColors.transparentLightBlue,
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
                              upComingRegisteredEvent ? Colors.white70 : Color(0xFF545454),
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              event.location ?? "No Location",
                              style:  TextStyle(
                                fontSize: 13,
                                color: upComingRegisteredEvent ? Colors.white70 : const Color(0xFF545454),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.name ?? "No Title",
                        style:  TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: upComingRegisteredEvent ? Colors.white : MyColors.blackColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            MyButton(
              buttonText: upComingRegisteredEvent ? "Începe jocul" : "Detalii inscriere",
              textColor: upComingRegisteredEvent ? const Color(0xFF222F62) : MyColors.blackColor,
              buttonOnTap: () => onEventTap(event),
              withBorder: false,
              buttonColor: upComingRegisteredEvent ? Colors.white : MyColors.transparentLightBlue,
              leading: SvgPicture.asset(
                upComingRegisteredEvent ? 'assets/images/incepe_jocul.svg' : 'assets/images/user_icon.svg',
                width: 19,
                height: 19,
                colorFilter:  ColorFilter.mode(
                  upComingRegisteredEvent ? const Color(0xFF222F62) : MyColors.blackColor,
                  BlendMode.srcIn,
                ),
              ),
              buttonTextSize: 15,
            ),
          ],
        ),
      ),
    );
  }
}
