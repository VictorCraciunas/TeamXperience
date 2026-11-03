import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/layout/outline_card.dart';
import 'package:teamxperience/ui/ui.dart';

/// One card of "Cum jucați": an icon, a short title and a line under it.
class PlayFactCard extends StatelessWidget {
  const PlayFactCard({super.key, required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return OutlineCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 18 * 1.45, child: Icon(icon, size: 18, color: context.colors.accent)),
          Text(title, style: AppTextStyles.cardTitle(context)),
          Text(text, style: AppTextStyles.smallMuted(context)),
        ],
      ),
    );
  }
}
