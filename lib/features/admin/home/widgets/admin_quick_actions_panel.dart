import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/layout/action_tile.dart';
import 'package:teamxperience/ui/components/layout/section_card.dart';

class AdminQuickActionsPanel extends StatelessWidget {
  const AdminQuickActionsPanel({
    super.key,
    required this.onCreateEvent,
    required this.onCreateNews,
    required this.onNotify,
  });

  final VoidCallback onCreateEvent;
  final VoidCallback onCreateNews;
  final VoidCallback onNotify;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Acțiuni rapide',
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ActionTile(icon: Icons.add_circle_outline, label: 'Creează eveniment', onTap: onCreateEvent),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ActionTile(icon: Icons.post_add, label: 'Creează știre', onTap: onCreateNews),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ActionTile(icon: Icons.notifications_none, label: 'Trimite notificare', onTap: onNotify),
            ),
          ],
        ),
      ),
    );
  }
}
