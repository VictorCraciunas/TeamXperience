import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';


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
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: context.colors.text,
          ),
        ),
        InkWell(
          splashFactory: InkSplash.splashFactory,
          onTap:onTap,
          child: Container(
            padding: const EdgeInsets.all(5),
            child: Text(
              "Vezi mai multe >",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.colors.accent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}