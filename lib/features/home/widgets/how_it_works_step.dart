import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// One numbered step of how the game works.
class HowItWorksStep extends StatelessWidget {
  const HowItWorksStep({super.key, required this.number, required this.title, required this.line});

  final int number;
  final String title;
  final String line;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: colors.navy, shape: BoxShape.circle),
          child: SizedBox.square(
            dimension: 24,
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.onNavy),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.45, color: colors.text)),
              Text(line, style: TextStyle(fontSize: 13, height: 1.45, color: colors.muted)),
            ],
          ),
        ),
      ],
    );
  }
}
