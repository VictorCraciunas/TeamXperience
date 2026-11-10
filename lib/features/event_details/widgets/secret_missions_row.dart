import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/event_details/logic/event_page_content.dart';
import 'package:teamxperience/ui/ui.dart';

import 'dashed_circle.dart';

/// The last row of the mission card: how many missions stay secret.
class SecretMissionsRow extends StatelessWidget {
  const SecretMissionsRow({super.key, required this.count, this.alone = false});

  final int count;

  /// No public mission above it, so it does not say "Încă".
  final bool alone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ColoredBox(
      color: colors.inset,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashedCircle(
              size: 22,
              color: colors.muted,
              child: Icon(TablerIcons.lock, size: 12, color: colors.muted),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(secretMissionsLine(count, alone: alone), style: AppTextStyles.cardTitle(context)),
                  Text('Se deblochează în ziua jocului', style: AppTextStyles.smallMuted(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
