
import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:flutter_svg/flutter_svg.dart';


class DetailWidget extends StatelessWidget {
  final String text1;
  final String text2;
  final String iconPath;

  const DetailWidget({
    super.key,
    required this.text1,
    required this.text2,
    required this.iconPath
  });


  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 51,
          decoration: BoxDecoration(
            color: context.colors.iconButtonBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: SvgPicture.asset(
              iconPath,
              width: 36,
              height: 36,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text1,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.colors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text2,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: Colors.black
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}