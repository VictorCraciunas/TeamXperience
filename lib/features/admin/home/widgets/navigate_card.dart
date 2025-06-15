import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants/colors.dart';

class NavigateCard extends StatelessWidget {
  final String text1;
  final String text2;

  final VoidCallback? onTap;

  const NavigateCard({super.key, required this.text1, required this.text2, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 154,
        height: 115,
        decoration: BoxDecoration(
          color: const Color(0x2453C4C7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/add_icon.svg',
              width: 32,
              height: 32,
            ),
            const SizedBox(height: 15,),
            Text(text1,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: MyColors.blackColor),),
            Text(text2,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: MyColors.blackColor),)

          ],
        ),
      ),
    );
  }
}
