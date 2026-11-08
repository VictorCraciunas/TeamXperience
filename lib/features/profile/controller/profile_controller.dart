import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/backend/authentication/AuthenticationRepository.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/profile/logic/notification_access.dart';
import 'package:teamxperience/model/memory.dart';
import 'package:teamxperience/model/user.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/state_management/news_state_management.dart';

/// Holds the Profil screen: the signed-in user kept fresh (their XP, stats and
/// badges change when a game ends), their latest memories and whether
/// notifications are allowed, and signs out. The streams and the permission
/// calls are passed in.
class ProfileController extends ChangeNotifier {
  ProfileController(
    this.context, {
    required AppUser user,
    required Stream<AppUser?> userStream,
    required Stream<List<Memory>> memoriesStream,
    required NotificationAccess notifications,
    required void Function(AppUser fresh) onFreshUser,
  })  : _user = user,
        _access = notifications,
        _onFreshUser = onFreshUser {
    _userWatch = userStream.listen(_onUser, onError: (Object _) {});
    _memoriesWatch = memoriesStream.listen(_onMemories, onError: (Object _) {});
    _readNotifications();
  }

  final BuildContext context;
  final NotificationAccess _access;
  final void Function(AppUser fresh) _onFreshUser;
  late final AuthenticationRepository _authRepo = AuthenticationRepository();
  StreamSubscription<AppUser?>? _userWatch;
  StreamSubscription<List<Memory>>? _memoriesWatch;
  bool _disposed = false;

  AppUser _user;
  AppUser get user => _user;

  List<Memory> _memories = const [];
  List<Memory> get memories => _memories;

  NotifStatus? _notifications;

  /// Null until read.
  NotifStatus? get notifications => _notifications;

  /// "Activate", or "Oprite" (also until the status is known).
  String get notificationsLabel => _notifications == NotifStatus.allowed ? 'Activate' : 'Oprite';

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  void _onUser(AppUser? fresh) {
    if (fresh == null || _disposed) return;
    _user = fresh;
    _onFreshUser(fresh);
    _changed();
  }

  void _onMemories(List<Memory> memories) {
    _memories = memories;
    _changed();
  }

  Future<void> _readNotifications() async {
    _notifications = await _access.status();
    _changed();
  }

  /// The row's tap: ask for permission, or open the phone's settings.
  Future<void> onNotificationsTap() async {
    _notifications = await _access.askOrOpenSettings();
    _changed();
  }

  void logout() {
    context.read<EventList>().clear();
    context.read<NewsList>().clear();
    _authRepo.logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.splash,
      (Route<dynamic> route) => false,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _userWatch?.cancel();
    _memoriesWatch?.cancel();
    super.dispose();
  }
}
