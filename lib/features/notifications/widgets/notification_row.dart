import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/notifications/logic/notification_view.dart';
import 'package:teamxperience/model/app_notification.dart';
import 'package:teamxperience/ui/components/layout/outline_card.dart';
import 'package:teamxperience/ui/ui.dart';

/// One notification: its icon, title, text and time; an unread one is tinted
/// with a red dot. The whole row is the tap target.
class NotificationRow extends StatelessWidget {
  const NotificationRow({super.key, required this.item, required this.now, required this.onTap});

  final AppNotification item;
  final DateTime now;
  final VoidCallback onTap;

  static IconData iconOf(NotificationKind kind) => switch (kind) {
        NotificationKind.announcement => TablerIcons.speakerphone,
        NotificationKind.chat => TablerIcons.message_circle,
        NotificationKind.team => TablerIcons.users_group,
        NotificationKind.results => TablerIcons.trophy,
        NotificationKind.other => TablerIcons.bell,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final time = notificationTime(item.createdAt, now);
    final unread = !item.read;
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: unread ? colors.navActivePill : null,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: OutlineCard(
            borderColor: unread ? colors.tick : null,
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(color: colors.iconButtonBg, shape: BoxShape.circle),
                  child: SizedBox.square(
                    dimension: 40,
                    child: Icon(iconOf(item.kind), size: 20, color: colors.accent),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.35, color: colors.text),
                      ),
                      if (item.body.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            item.body,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, height: 1.4, color: colors.muted),
                          ),
                        ),
                      if (time.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(time, style: TextStyle(fontSize: 13, height: 1.45, color: colors.muted)),
                        ),
                    ],
                  ),
                ),
                if (unread) ...[
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      key: const ValueKey('notification-unread'),
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(color: colors.live, shape: BoxShape.circle),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
