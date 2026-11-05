import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';
import '../route/waypoint_dot.dart';

/// A heading over a group of cards, as the mockups' `.hd`: a small route
/// ring (`.hd:before`), a 14 px title and,
/// at the right, a muted count or an accent link. 14 px above and to the
/// sides ([top]), 8 below.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing, this.link, this.onLink, this.top = 14});

  final String title;

  /// A count or note at the right, muted.
  final String? trailing;

  /// A link at the right ("Vezi toate"), used instead of [trailing].
  final String? link;
  final VoidCallback? onLink;

  /// The space above: 14 on the Evenimente tab, 16 on Home (mockup 02).
  final double top;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final note = trailing;
    final action = link;
    return Padding(
      padding: EdgeInsets.fromLTRB(14, top, 14, 8),
      child: Row(
        children: [
          const WaypointDot(key: ValueKey('hd-dot')),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.45, color: colors.text),
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onLink,
              behavior: HitTestBehavior.opaque,
              child: Text(
                action,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.45, color: colors.accent),
              ),
            )
          else if (note != null)
            Text(note, style: TextStyle(fontSize: 11, height: 1.45, color: colors.muted)),
        ],
      ),
    );
  }
}
