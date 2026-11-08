import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/live_board.dart';
import '../logic/live_status.dart';
import '../logic/live_texts.dart';
import 'board_segments.dart';

/// One team on the board: its place, its name and status, and its missions; a
/// team that has not started gets "Sună căpitanul" instead.
class BoardRowTile extends StatelessWidget {
  const BoardRowTile({
    super.key,
    required this.row,
    required this.missionCount,
    required this.now,
    this.last = false,
    required this.onTap,
    required this.onCall,
  });

  final BoardRow row;
  final int missionCount;
  final DateTime now;

  /// The last row has no line under it.
  final bool last;
  final VoidCallback onTap;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final waiting = row.state == LiveState.waitingPhoto;
    final notStarted = row.state == LiveState.notStarted;
    final stuck = row.state == LiveState.stuck;
    final place = row.place;
    final status = TextStyle(fontSize: 11, height: 1.45, color: stuck ? colors.warning : colors.muted);
    final content = Row(
      children: [
        SizedBox(
          width: 16,
          child: Text(
            place == null ? '–' : '$place',
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
            style: TextStyle(fontSize: 12, height: 1.45, fontWeight: FontWeight.w500, color: colors.text),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 92,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.team.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, height: 1.45, fontWeight: FontWeight.w500, color: colors.text),
              ),
              Text.rich(
                TextSpan(children: [
                  if (waiting)
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 3),
                        child: Icon(TablerIcons.photo, size: 11, color: colors.muted),
                      ),
                    ),
                  TextSpan(text: boardStatusText(row, now)),
                ]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: status,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: notStarted
              ? Align(
                  alignment: Alignment.centerRight,
                  child: Semantics(
                    button: true,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onCall,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          'Sună căpitanul',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 11, height: 1.45, fontWeight: FontWeight.w500, color: colors.accent),
                        ),
                      ),
                    ),
                  ),
                )
              : BoardSegments(total: missionCount, done: row.done, flagCurrent: stuck || waiting),
        ),
      ],
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: waiting ? colors.navActivePill : null,
          border: last ? null : Border(bottom: BorderSide(color: colors.insetBorder)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: notStarted ? Opacity(opacity: .55, child: content) : content,
        ),
      ),
    );
  }
}
