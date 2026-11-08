import 'package:flutter/material.dart';
import 'package:teamxperience/features/home/logic/home_texts.dart';
import 'package:teamxperience/features/profile/logic/profile_texts.dart';
import 'package:teamxperience/ui/ui.dart';

/// The top of Profil (mockup 08): a 54 px avatar in a 3 px ring (60 across),
/// the name and, for a player, the level with the XP bar and the next level.
/// Without a [level] (an organiser) the email takes their place.
class ProfileAccountCard extends StatelessWidget {
  const ProfileAccountCard({super.key, required this.name, required this.email, this.level});

  final String name;
  final String email;
  final LevelInfo? level;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final info = level;
    final small = TextStyle(fontSize: 11, height: 1.45, color: colors.muted);
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          DecoratedBox(
            key: const ValueKey('profile-avatar'),
            decoration: BoxDecoration(
              color: colors.navy,
              shape: BoxShape.circle,
              border: Border.all(color: colors.tick, width: 3),
            ),
            child: SizedBox.square(
              dimension: 60,
              child: Center(
                child: Text(
                  initialsOf(name),
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: colors.onNavy),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, height: 1.45, fontWeight: FontWeight.w500, color: colors.text),
                ),
                if (info == null)
                  Text(email, maxLines: 1, overflow: TextOverflow.ellipsis, style: small)
                else ...[
                  Text(
                    levelLine(info),
                    style: TextStyle(fontSize: 11, height: 1.45, fontWeight: FontWeight.w500, color: colors.accent),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: SizedBox(
                      key: const ValueKey('xp-bar'),
                      height: 5,
                      child: ColoredBox(
                        color: colors.insetBorder,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            key: const ValueKey('xp-fill'),
                            widthFactor: info.share,
                            heightFactor: 1,
                            child: ColoredBox(color: colors.tick),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(nextLevelLine(info), style: small),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
