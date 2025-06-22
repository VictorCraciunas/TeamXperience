import 'package:flutter/material.dart';

import '../../../../constants/colors.dart';

class TitleCarousel extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const TitleCarousel({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: MyColors.blackColor,
          ),
        ),
        InkWell(
          splashFactory: InkSplash.splashFactory,
          onTap:onTap,
          child: Container(
            padding: const EdgeInsets.all(5),
            child: const Text(
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
    );
  }
}