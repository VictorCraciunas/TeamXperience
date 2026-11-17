import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/chat_texts.dart';

/// "De aprobat" (amber), "Aprobată" (green, a tick) or "Respinsă" (red, an x).
class PhotoStatusPill extends StatelessWidget {
  const PhotoStatusPill({super.key, required this.status});

  final PhotoApprovalStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (Color background, Color foreground, IconData? icon) = switch (status) {
      PhotoApprovalStatus.pending => (colors.warningSoft, colors.warning, null),
      PhotoApprovalStatus.approved => (colors.successSoft, colors.success, TablerIcons.check),
      PhotoApprovalStatus.denied => (colors.dangerSoft, colors.danger, TablerIcons.x),
    };
    final shownIcon = icon;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (shownIcon != null) ...[
            Icon(shownIcon, size: 12, color: foreground),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              photoStatusLabel(status),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
