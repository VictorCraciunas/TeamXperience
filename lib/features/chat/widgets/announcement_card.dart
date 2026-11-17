import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/ui.dart';

/// The organiser's "Anunț" in a team's chat: amber, a loudspeaker,
/// "Anunț pentru toate echipele · 10:30" and the text.
class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({super.key, required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.warningSoft,
        border: Border.all(color: colors.amber),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(TablerIcons.speakerphone, size: 20, color: colors.warning),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.warning)),
                const SizedBox(height: 2),
                Text(text, style: TextStyle(fontSize: 14, height: 1.45, color: colors.text)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
