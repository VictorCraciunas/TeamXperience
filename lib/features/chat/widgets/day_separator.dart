import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

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
            color: context.colors.iconButtonBg,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: context.colors.accent,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }
}
