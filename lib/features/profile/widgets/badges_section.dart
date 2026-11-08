import 'package:flutter/material.dart';
import 'package:teamxperience/features/profile/logic/badge_catalog.dart';
import 'package:teamxperience/ui/components/misc/section_header.dart';

import 'badge_tile.dart';

/// "Insigne" with how many are earned, and four badges in a row; the header
/// and each badge open the full list.
class BadgesSection extends StatelessWidget {
  const BadgesSection({super.key, required this.earned, required this.onOpenAll});

  final List<String> earned;
  final VoidCallback onOpenAll;

  @override
  Widget build(BuildContext context) {
    final row = badgesRow(earned);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onOpenAll,
          child: SectionHeader(title: 'Insigne', trailing: '${earnedCount(earned)} din ${badgeCatalog.length}'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < row.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(child: BadgeTile(badge: row[i], earned: earned.contains(row[i].id), onTap: onOpenAll)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
