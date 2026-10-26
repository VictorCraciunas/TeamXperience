import 'package:flutter/material.dart';
import 'package:teamxperience/features/admin/create_event/start/create_event_start.dart';
import 'package:teamxperience/features/admin/create_event/start/old_event_picker_sheet.dart';
import 'package:teamxperience/features/admin/home/widgets/admin_draft_row.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/theme/app_radius.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// "Eveniment nou": how to begin. Resolves to the choice, or null when closed.
Future<CreateEventStart?> showCreateEventStartSheet(
  BuildContext context, {
  required List<Event> drafts,
  required List<Event> oldEvents,
}) {
  return showModalBottomSheet<CreateEventStart>(
    context: context,
    isScrollControlled: true,
    builder: (_) => CreateEventStartSheet(drafts: drafts, oldEvents: oldEvents),
  );
}

class CreateEventStartSheet extends StatelessWidget {
  const CreateEventStartSheet({
    super.key,
    required this.drafts,
    required this.oldEvents,
  });

  final List<Event> drafts;
  final List<Event> oldEvents;

  Future<void> _fromOldEvent(BuildContext context) async {
    final navigator = Navigator.of(context);
    final picked = await showOldEventPicker(context, oldEvents);
    if (picked != null) navigator.pop(StartFromEvent(picked));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasOldEvents = oldEvents.isNotEmpty;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          children: [
            Text(
              'Eveniment nou',
              style: TextStyle(
                color: colors.text,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _Option(
              icon: Icons.add_circle_outline,
              title: 'De la zero',
              subtitle: 'Un eveniment gol',
              onTap: () => Navigator.of(context).pop(const StartFromScratch()),
            ),
            const SizedBox(height: 8),
            _Option(
              icon: Icons.copy_outlined,
              title: 'Dintr-un eveniment vechi',
              subtitle: hasOldEvents ? 'Pornești de la misiunile lui' : 'Nu ai evenimente vechi',
              onTap: hasOldEvents ? () => _fromOldEvent(context) : null,
            ),
            const SizedBox(height: 8),
            _Option(
              icon: Icons.data_object,
              title: 'Din JSON',
              subtitle: 'Lipești un eveniment scris în afara aplicației',
              onTap: () => Navigator.of(context).pop(const StartFromJson()),
            ),
            if (drafts.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Ciorne',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              for (final draft in drafts) ...[
                AdminDraftRow(
                  draft: draft,
                  onTap: () => Navigator.of(context).pop(StartFromDraft(draft)),
                ),
                const SizedBox(height: 6),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onTap != null;

    return Material(
      color: colors.inset,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: colors.insetBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: enabled ? colors.text : colors.muted),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: enabled ? colors.text : colors.muted,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: colors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
