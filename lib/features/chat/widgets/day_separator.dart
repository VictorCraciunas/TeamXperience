import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';

class DaySeparator extends StatelessWidget {
  final String label;

  const DaySeparator({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: MyColors.transparentLightBlue,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: MyColors.lightBlue,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }
}
