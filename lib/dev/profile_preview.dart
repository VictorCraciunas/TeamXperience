import 'package:flutter/material.dart';
import 'package:teamxperience/features/profile/widgets/badge_sheet.dart';
import 'package:teamxperience/features/profile/widgets/profile_view.dart';
import 'package:teamxperience/model/user_stats.dart';
import 'package:teamxperience/ui/components/misc/segmented_switch.dart';
import 'package:teamxperience/ui/components/navigation/tab_header.dart';
import 'package:teamxperience/ui/ui.dart';

import 'sample_event.dart';

/// Mockup 08's Profil: the mockup's player, a brand-new one (what everyone sees
/// until the results function runs), one at the top level, and an organiser.
class ProfilePreview extends StatefulWidget {
  const ProfilePreview({super.key});

  @override
  State<ProfilePreview> createState() => _ProfilePreviewState();
}

class _ProfilePreviewState extends State<ProfilePreview> {
  int _state = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (int xp, UserStats stats, List<String> badges, bool hasMemories) = switch (_state) {
      0 => (640, const UserStats(games: 3, distanceMeters: 12400, missions: 17, podiums: 1), const ['km10', 'noHints', 'night', 'firstGame'], true),
      2 => (3100, const UserStats(games: 24, distanceMeters: 96000, missions: 140, podiums: 9), const ['km10', 'noHints', 'night', 'winner', 'firstGame', 'games5', 'km50'], true),
      _ => (0, const UserStats(), const <String>[], false),
    };
    return Scaffold(
      backgroundColor: colors.page,
      body: Column(
        children: [
          const TabHeader(title: 'Profil'),
          Expanded(
            child: SingleChildScrollView(
              child: ProfileView(
                player: _state != 3,
                name: 'Victor Crăciunaș',
                email: 'victor@example.com',
                xp: xp,
                stats: stats,
                badges: badges,
                memories: hasMemories ? sampleMemories() : const [],
                themeLabel: 'Luminos',
                notificationsLabel: 'Activate',
                onTheme: () {},
                onNotifications: () {},
                onLogout: () {},
                onOpenBadges: () => showBadgeSheet(context, earned: badges),
                onOpenMemory: (_) {},
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: SegmentedSwitch(
                labels: const ['Mockup', 'Nou', 'Legendă', 'Admin'],
                selectedIndex: _state,
                onSelected: (i) => setState(() => _state = i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
