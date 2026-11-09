import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/backend/repo/notification_repo.dart';
import 'package:teamxperience/backend/repo/user_repo.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/notifications/controller/notifications_controller.dart';
import 'package:teamxperience/features/notifications/logic/notification_view.dart';
import 'package:teamxperience/features/notifications/widgets/notifications_view.dart';
import 'package:teamxperience/features/shell/logic/player_tabs.dart';
import 'package:teamxperience/model/app_notification.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/components/navigation/shell_controller.dart';
import 'package:teamxperience/ui/ui.dart';

/// The player's notifications, opened from the bell on Acasă.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationsController? _controller;
  String? _uid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final uid = context.read<UserProvider>().currentUser?.uid;
    _uid = uid;
    final repo = NotificationRepo();
    _controller = NotificationsController(
      stream: uid == null || uid.isEmpty ? Stream.value(const []) : repo.stream(uid),
      markRead: (id) async {
        if (uid != null && uid.isNotEmpty) await repo.markRead(uid, id);
      },
      markAllRead: (ids) async {
        if (uid != null && uid.isNotEmpty) await repo.markAllRead(uid, ids);
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Event? _loadedEvent(String eventId) {
    for (final event in context.read<EventList>().events) {
      if (event.eventId == eventId) return event;
    }
    return null;
  }

  /// Marks the row read, then opens what it is about. Anything that cannot be
  /// found leaves the player on this page.
  Future<void> _open(AppNotification n) async {
    final controller = _controller;
    if (controller == null) return;
    await controller.open(n);
    if (!mounted) return;
    final target = notificationTarget(n, eventLoaded: (id) => _loadedEvent(id) != null);
    final uid = _uid;
    try {
      switch (target) {
        case OpenChat(:final eventId, :final teamName):
          if (uid == null) return;
          final team = await TeamService().getUserTeamForEvent(eventId, uid);
          if (!mounted || team == null || team.name != teamName) return;
          await Navigator.pushNamed(context, Routes.chatScreen, arguments: {'eventId': eventId, 'team': team});
        case OpenMemory(:final eventId):
          if (uid == null) return;
          final memory = await UserRepo().getMemory(uid, eventId);
          if (!mounted || memory == null) return;
          await Navigator.pushNamed(context, Routes.memory, arguments: {'memory': memory});
        case OpenEvent(:final eventId):
          final event = _loadedEvent(eventId);
          if (event == null) return;
          await Navigator.pushNamed(context, Routes.eventDetails, arguments: {'event': event, 'isAdmin': false});
        case OpenTeams():
          context.read<ShellController?>()?.select(PlayerTab.teams);
          Navigator.of(context).pop();
        case StayHere():
          return;
      }
    } catch (_) {
      // A read that fails leaves the player here.
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final controller = _controller;
    return Scaffold(
      backgroundColor: colors.page,
      appBar: MyAppBar(
        appBarText: 'Notificări',
        trailing: controller == null
            ? null
            : ListenableBuilder(
                listenable: controller,
                builder: (context, _) => controller.hasUnread
                    ? TextButton(
                        onPressed: controller.markAll,
                        style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
                        child: Text(
                          'Marchează citite',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.accent),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
      ),
      body: controller == null
          ? const SizedBox.shrink()
          : ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                if (controller.loading) return const Center(child: CircularProgressIndicator());
                return NotificationsView(
                  items: controller.items,
                  failed: controller.failed,
                  now: DateTime.now(),
                  onOpen: _open,
                );
              },
            ),
    );
  }
}
