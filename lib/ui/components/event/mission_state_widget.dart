import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/enums/missions_state.dart';

import 'package:teamxperience/constants/colors.dart';

class MissionStateWidget extends StatelessWidget {
  final MissionState missionState;
  final VoidCallback? onTap;
  final int nr;

  const MissionStateWidget({
    super.key,
    required this.missionState,
    required this.onTap,
    required this.nr,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: missionState == MissionState.deblcata ? onTap : (){},
      child: Opacity(
        opacity: missionState == MissionState.blocata ? 0.4 : 1.0,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            border: Border.all(color: Color(0xFFE4E4E4), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color:
                              missionState == MissionState.finalizata
                                  ? MyColors.lightBlue
                                  : missionState == MissionState.deblcata
                                  ? MyColors.transparentLightBlue
                                  : Color(0xFFFFC4C4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          // Add padding inside container
                          child: Center(
                            child: SvgPicture.asset(
                              missionState == MissionState.finalizata
                                  ? 'assets/images/done.svg'
                                  : missionState == MissionState.deblcata
                                  ? 'assets/images/unlock.svg'
                                  : 'assets/images/lock.svg',
                              width: 34, // Reasonable size for the icon
                              height: 34,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Misiunea $nr",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: MyColors.blackColor,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            missionState == MissionState.finalizata ? "Finalizată" : missionState == MissionState.deblcata ? "Deblocată" : "Blocată",
                            style: TextStyle(fontSize: 12, color: Color(0xFF858493)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if(missionState == MissionState.deblcata || missionState == MissionState.finalizata)
                    SvgPicture.asset(
                       'assets/images/arrow.svg',
                    width: 24, // Reasonable size for the icon
                    height: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
