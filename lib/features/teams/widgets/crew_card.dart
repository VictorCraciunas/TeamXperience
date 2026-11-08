import 'package:teamxperience/features/home/logic/home_texts.dart';
import 'package:teamxperience/features/teams/logic/season_rows.dart';
import 'package:teamxperience/features/teams/widgets/crew_stat_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/teams/widgets/crew_code_row.dart';
import 'package:teamxperience/model/crew.dart';
import 'package:teamxperience/ui/components/misc/avatar_stack.dart';
import 'package:teamxperience/ui/theme/app_radius.dart';
import 'package:teamxperience/ui/theme/app_text_styles.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// One of the player's crews on the Echipe screen: a navy card with the name,
/// who the captain is, the first members and the invite code.
class CrewCard extends StatelessWidget {
  const CrewCard({
    super.key,
    required this.crew,
    required this.onShare,
    required this.onCopy,
  });

  final Crew crew;
  final VoidCallback onShare;
  final VoidCallback onCopy;

  static const int _avatars = 4;

  /// "Căpitan: Victor · 4 membri"; without a known captain just "4 membri".
  String get _subtitle {
    final count = crew.members.length;
    final members = count == 1 ? '1 membru' : '$count membri';
    final captain = crew.captain;
    return captain == null
        ? members
        : 'Căpitan: ${captain.displayName} · $members';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shown = crew.members.take(_avatars).map((m) => m.initials).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: DecoratedBox(
        key: const ValueKey('crew-card'),
        decoration: BoxDecoration(
          color: colors.navy,
          borderRadius: BorderRadius.circular(AppRadius.hero),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.tickOnNavy,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(
                        TablerIcons.paw,
                        size: 24,
                        color: colors.onTick,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crew.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.trailHeading(
                            context,
                          ).copyWith(fontSize: 15, color: colors.onNavy),
                        ),
                        Text(
                          _subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.smallMuted(context).copyWith(
                            color: colors.onNavy.withValues(alpha: .8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: AvatarStack(
                  initials: shown,
                  total: shown.length,
                  size: 28,
                  onDark: true,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: CrewStatTile(value: '${crew.stats.games}', label: gamesLabel(crew.stats.games))),
                  const SizedBox(width: 6),
                  Expanded(child: CrewStatTile(value: '${crew.stats.wins}', label: winsLabel(crew.stats.wins))),
                  const SizedBox(width: 6),
                  Expanded(
                    child: CrewStatTile(value: kmStat(crew.stats.distanceMeters), label: 'împreună'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CrewCodeRow(
                code: crew.displayCode,
                onShare: onShare,
                onCopy: onCopy,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
