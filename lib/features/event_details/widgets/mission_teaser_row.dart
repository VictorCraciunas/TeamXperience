import 'package:flutter/material.dart';
import 'package:teamxperience/features/event_details/logic/event_page_content.dart';
import 'package:teamxperience/ui/ui.dart';

/// One public mission: its number in a teal circle, its title and teaser.
class MissionTeaserRow extends StatelessWidget {
  const MissionTeaserRow({super.key, required this.teaser, required this.divider});

  final MissionTeaser teaser;

  /// A line under the row, between missions.
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: divider ? Border(bottom: BorderSide(color: colors.insetBorder)) : null,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 9, 12, divider ? 10 : 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: colors.tick),
              child: Text('${teaser.number}', style: AppTextStyles.cardTitle(context).copyWith(color: colors.onTick)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(teaser.title, style: AppTextStyles.cardTitle(context)),
                  if (teaser.teaser.isNotEmpty) Text(teaser.teaser, style: AppTextStyles.smallMuted(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
