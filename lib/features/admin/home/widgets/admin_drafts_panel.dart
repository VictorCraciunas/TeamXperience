import 'package:flutter/material.dart';
import 'package:teamxperience/features/admin/home/widgets/admin_draft_row.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/layout/section_card.dart';

/// Events the organiser started but has not published. Draws nothing when there are none.
class AdminDraftsPanel extends StatelessWidget {
  const AdminDraftsPanel({super.key, required this.drafts, required this.onTap});

  final List<Event> drafts;
  final void Function(Event draft) onTap;

  @override
  Widget build(BuildContext context) {
    if (drafts.isEmpty) return const SizedBox.shrink();

    return SectionCard(
      title: 'Ciorne',
      count: drafts.length,
      child: Column(
        children: [
          for (var i = 0; i < drafts.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            AdminDraftRow(draft: drafts[i], onTap: () => onTap(drafts[i])),
          ],
        ],
      ),
    );
  }
}
