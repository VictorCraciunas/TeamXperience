import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/buttons/navy_button.dart';
import 'package:teamxperience/ui/components/layout/outline_card.dart';
import 'package:teamxperience/ui/ui.dart';

/// One card of the Joacă tab: an optional small heading, a title, a line and
/// one button.
class PlayCard extends StatelessWidget {
  const PlayCard({
    super.key,
    this.heading,
    this.title,
    required this.line,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String? heading;
  final String? title;
  final String line;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final top = heading;
    final name = title;
    return OutlineCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (top != null) Text(top, style: AppTextStyles.smallMuted(context)),
          if (name != null) Text(name, style: AppTextStyles.trailHeading(context)),
          Text(line, style: AppTextStyles.pageBody(context)),
          const SizedBox(height: 12),
          NavyButton(label: buttonLabel, onPressed: onPressed),
        ],
      ),
    );
  }
}
