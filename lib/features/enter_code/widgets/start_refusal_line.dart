import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/ui.dart';

/// Why the code was refused, under the boxes (mockup 05): a 14 px alert
/// icon and the message, light red w500 on navy.
class StartRefusalLine extends StatelessWidget {
  const StartRefusalLine({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.dangerTextOnNavy;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(TablerIcons.alert_circle, size: 14, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.45, color: color),
          ),
        ),
      ],
    );
  }
}
