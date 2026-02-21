import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';

class InfoRowWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRowWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: MyColors.greyText),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: MyColors.greyText,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: MyColors.blackColor,
            ),
          ),
        ),
      ],
    );
  }
}
