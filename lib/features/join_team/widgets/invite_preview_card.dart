import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/service/team_service/invite_preview.dart';
import 'package:teamxperience/ui/components/layout/outline_card.dart';
import 'package:teamxperience/ui/components/misc/avatar_stack.dart';
import 'package:teamxperience/ui/theme/app_text_styles.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';
import 'package:teamxperience/utils/event_formats.dart';

/// Who is behind an invite code, as in mockup 04: the event on a coloured
/// strip, the team with its captain, and the places with the one that is the
/// player's own. Without an event the strip and the date are left out.
class InvitePreviewCard extends StatelessWidget {
  const InvitePreviewCard({super.key, required this.preview});

  final InvitePreview preview;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final event = preview.event;
    final slotLine = preview.slotLine;
    final subtitle =
        event == null
            ? 'Căpitan: ${preview.captainName}'
            : 'Căpitan: ${preview.captainName} · ${shortDateTime(event.dateEvent)}';

    return OutlineCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (event != null)
            Container(
              height: 64,
              color: colors.accent,
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
              child: Text(
                event.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.cardTitle(
                  context,
                ).copyWith(color: colors.onNavy),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.tick,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        TablerIcons.paw,
                        size: 22,
                        color: colors.onTick,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            preview.crewName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.trailHeading(context),
                          ),
                          Text(
                            subtitle,
                            style: AppTextStyles.smallMuted(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    AvatarStack(
                      initials: [for (final m in preview.members) m.initials],
                      total: event?.size ?? preview.members.length,
                      highlightNext: event != null,
                    ),
                    if (slotLine != null) ...[
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          slotLine,
                          style: AppTextStyles.smallMuted(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
