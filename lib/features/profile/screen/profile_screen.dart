import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/backend/repo/user_repo.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/features/profile/controller/profile_controller.dart';
import 'package:teamxperience/features/profile/logic/notification_access.dart';
import 'package:teamxperience/features/profile/logic/profile_texts.dart';
import 'package:teamxperience/features/profile/widgets/badge_sheet.dart';
import 'package:teamxperience/features/profile/widgets/profile_view.dart';
import 'package:teamxperience/service/FCMService.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/ui/components/misc/theme_mode_sheet.dart';
import 'package:teamxperience/ui/components/navigation/tab_header.dart';

import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/ui/ui.dart';

/// The Profil tab (mockup 08), in both the player's and the organiser's shell:
/// the role decides what shows.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey _settings = GlobalKey();
  ProfileController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final users = context.read<UserProvider>();
    final user = users.currentUser;
    if (user == null) return;
    final repo = UserRepo();
    final uid = profileDocId(users.firebaseUser?.uid, user.uid);
    _controller = ProfileController(
      context,
      user: user,
      userStream: uid == null ? const Stream.empty() : repo.streamUser(uid),
      memoriesStream: uid == null || user.role == Role.ADMIN ? const Stream.empty() : repo.streamMemories(uid),
      notifications: NotificationAccess(),
      onFreshUser: users.updateProfile,
      findTeam: uid == null ? null : (eventId) => TeamService().getUserTeamForEvent(eventId, uid),
      saveToken: uid == null
          ? null
          : () async {
              final token = await FCMService.getFCMToken();
              if (token != null) await repo.updateFCMToken(uid, token);
            },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _scrollToSettings() {
    final target = _settings.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(target, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final controller = _controller;
    final mode = context.watch<ThemeController>().mode;
    return Scaffold(
      backgroundColor: colors.page,
      body: Column(
        children: [
          TabHeader(
            title: 'Profil',
            trailing: Semantics(
              button: true,
              label: 'Setări',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _scrollToSettings,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: colors.iconButtonBg, shape: BoxShape.circle),
                  child: SizedBox.square(
                    dimension: 32,
                    child: Center(child: Icon(TablerIcons.settings, size: 17, color: colors.text)),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: controller == null
                ? const SizedBox.shrink()
                : ListenableBuilder(
                    listenable: controller,
                    builder: (context, _) {
                      final user = controller.user;
                      return SingleChildScrollView(
                        child: ProfileView(
                          settingsKey: _settings,
                          player: user.role != Role.ADMIN,
                          name: '${user.firstName} ${user.lastName}'.trim(),
                          email: user.email,
                          xp: user.xp,
                          stats: user.stats,
                          badges: user.badges,
                          memories: controller.memories,
                          memoriesFailed: controller.memoriesFailed,
                          themeLabel: themeLabel(mode),
                          notificationsLabel: controller.notificationsLabel,
                          onTheme: () => showModalBottomSheet<void>(
                            context: context,
                            builder: (_) => const ThemeModeSheet(),
                          ),
                          onNotifications: controller.onNotificationsTap,
                          onLogout: controller.logout,
                          onOpenBadges: () => showBadgeSheet(context, earned: user.badges),
                          onOpenMemory: controller.openMemory,
                          onAllMemories: controller.openAllMemories,
                          albumOf: controller.albumOf,
                          pictureOf: controller.pictureOf,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
