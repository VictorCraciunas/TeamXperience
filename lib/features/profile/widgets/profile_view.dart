import 'package:flutter/material.dart';
import 'package:teamxperience/features/home/logic/home_texts.dart';
import 'package:teamxperience/features/team_photo/logic/team_album.dart';
import 'package:teamxperience/model/memory.dart';
import 'package:teamxperience/model/user_stats.dart';

import 'badges_section.dart';
import 'memories_section.dart';
import 'profile_account_card.dart';
import 'profile_settings_card.dart';
import 'profile_stats_row.dart';

/// Profil as mockup 08, from plain values. A [player] sees the level, stats,
/// badges and memories; an organiser sees the account and the settings only.
class ProfileView extends StatelessWidget {
  const ProfileView({
    super.key,
    required this.player,
    required this.name,
    required this.email,
    this.xp = 0,
    this.stats = const UserStats(),
    this.badges = const [],
    this.memories = const [],
    this.memoriesFailed = false,
    required this.themeLabel,
    required this.notificationsLabel,
    required this.onTheme,
    required this.onNotifications,
    required this.onLogout,
    required this.onOpenBadges,
    required this.onOpenMemory,
    this.onAllMemories,
    this.albumOf,
    this.pictureOf,
    this.settingsKey,
  });

  final bool player;
  final String name;
  final String email;
  final int xp;
  final UserStats stats;
  final List<String> badges;
  final List<Memory> memories;
  final bool memoriesFailed;
  final String themeLabel;
  final String notificationsLabel;
  final VoidCallback onTheme;
  final VoidCallback onNotifications;
  final VoidCallback onLogout;
  final VoidCallback onOpenBadges;
  final ValueChanged<Memory> onOpenMemory;
  final VoidCallback? onAllMemories;
  final List<AlbumPhoto> Function(String eventId)? albumOf;
  final String? Function(String eventId)? pictureOf;

  /// On the settings card, so the header's gear can scroll to it.
  final Key? settingsKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileAccountCard(name: name, email: email, level: player ? levelInfo(xp) : null),
        if (player) ...[
          ProfileStatsRow(stats: stats),
          BadgesSection(earned: badges, onOpenAll: onOpenBadges),
          MemoriesSection(
            failed: memoriesFailed,
            memories: memories,
            onOpen: onOpenMemory,
            onAll: onAllMemories,
            albumOf: albumOf,
            pictureOf: pictureOf,
          ),
        ],
        ProfileSettingsCard(
          key: settingsKey,
          themeLabel: themeLabel,
          notificationsLabel: notificationsLabel,
          onTheme: onTheme,
          onNotifications: onNotifications,
          onLogout: onLogout,
        ),
      ],
    );
  }
}
