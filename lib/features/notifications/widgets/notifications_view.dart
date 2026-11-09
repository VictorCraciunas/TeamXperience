import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/notifications/logic/notification_view.dart';
import 'package:teamxperience/model/app_notification.dart';
import 'package:teamxperience/ui/ui.dart';

import 'notification_row.dart';

/// The player's notifications under "Azi" and "Mai devreme", or a line saying
/// there are none or they could not be read.
class NotificationsView extends StatelessWidget {
  const NotificationsView({
    super.key,
    required this.items,
    required this.failed,
    required this.now,
    required this.onOpen,
  });

  final List<AppNotification> items;
  final bool failed;
  final DateTime now;
  final ValueChanged<AppNotification> onOpen;

  Widget _group(BuildContext context, String title, List<AppNotification> rows) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
            child: Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.45, color: context.colors.muted),
            ),
          ),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: NotificationRow(item: row, now: now, onTap: () => onOpen(row)),
            ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (items.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (failed)
                Text(
                  'Nu am putut încărca notificările.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, height: 1.45, color: colors.muted),
                )
              else ...[
                DecoratedBox(
                  decoration: BoxDecoration(color: colors.iconButtonBg, shape: BoxShape.circle),
                  child: SizedBox.square(dimension: 64, child: Icon(TablerIcons.bell, size: 30, color: colors.accent)),
                ),
                const SizedBox(height: 14),
                Text(
                  'Nicio notificare încă',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, height: 1.45, color: colors.text),
                ),
                const SizedBox(height: 4),
                Text(
                  'Aici apar mesajele organizatorului, noutățile echipei tale și rezultatele jocurilor.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, height: 1.45, color: colors.muted),
                ),
              ],
            ],
          ),
        ),
      );
    }
    final groups = groupNotifications(items, now);
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        if (groups.today.isNotEmpty) _group(context, 'Azi', groups.today),
        if (groups.earlier.isNotEmpty) _group(context, 'Mai devreme', groups.earlier),
      ],
    );
  }
}
