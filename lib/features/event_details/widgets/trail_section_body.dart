import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// A heading on the route trail with its content below ("Povestea").
class TrailSectionBody extends StatelessWidget {
  const TrailSectionBody({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: AppTextStyles.trailHeading(context)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
