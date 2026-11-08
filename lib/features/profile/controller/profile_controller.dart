import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/backend/authentication/AuthenticationRepository.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/profile/logic/notification_access.dart';
import 'package:teamxperience/model/event.dart';
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
    Event? Function(String eventId)? findEvent,
    Future<void> Function()? saveToken,
  })  : _user = user,
        _access = notifications,
        _onFreshUser = onFreshUser,
        _findEvent = findEvent,
        _saveToken = saveToken {
    _userWatch = userStream.listen(_onUser, onError: (Object _) {});
    _memoriesWatch = memoriesStream.listen(_onMemories, onError: (Object _) {
      _memoriesFailed = true;
      _changed();
    });
    // The phone's settings may have changed while the player was away.
    _lifecycle = AppLifecycleListener(onResume: _readNotifications);
    _readNotifications();
  }

  final BuildContext context;
  final NotificationAccess _access;
  final void Function(AppUser fresh) _onFreshUser;
  final Event? Function(String eventId)? _findEvent;
  final Future<void> Function()? _saveToken;
  late final AppLifecycleListener _lifecycle;
  bool _tokenSent = false;
  late final AuthenticationRepository _authRepo = AuthenticationRepository();
  StreamSubscription<AppUser?>? _userWatch;
  StreamSubscription<List<Memory>>? _memoriesWatch;
  bool _disposed = false;

  AppUser _user;
  AppUser get user => _user;

  List<Memory> _memories = const [];
  List<Memory> get memories => _memories;

  bool _memoriesFailed = false;

  /// The memories could not be read; the list may just be empty for that.
  bool get memoriesFailed => _memoriesFailed;

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
    _memoriesFailed = false;
    _changed();
  }

  Future<void> _readNotifications() async {
    _setNotifications(await _access.status());
  }

  /// The row's tap: ask for permission, or open the phone's settings.
  Future<void> onNotificationsTap() async {
    _setNotifications(await _access.askOrOpenSettings());
  }

  void _setNotifications(NotifStatus status) {
    if (_disposed) return;
    _notifications = status;
    _changed();
    if (status == NotifStatus.allowed) _sendToken();
  }

  /// The token is only fetched at sign-in, and only if notifications were
  /// allowed then: a player who allows them later must get one now, or no push
  /// ever reaches them. Sent at most once; a failure is tried at the next sign-in.
  Future<void> _sendToken() async {
    final save = _saveToken;
    if (save == null || _tokenSent || _user.fcmToken.isNotEmpty) return;
    _tokenSent = true;
    try {
      await save();
    } catch (_) {}
  }

  /// Opens the page of a past game's event, when that event is loaded.
  void openMemory(Memory memory) {
    final find = _findEvent;
    final event = find != null ? find(memory.eventId) : _loadedEvent(memory.eventId);
    if (event == null) return;
    Navigator.pushNamed(context, Routes.eventDetails, arguments: {'event': event, 'isAdmin': false});
  }

  Event? _loadedEvent(String eventId) {
    for (final event in context.read<EventList>().events) {
      if (event.eventId == eventId) return event;
    }
    return null;
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
    _lifecycle.dispose();
    _userWatch?.cancel();
    _memoriesWatch?.cancel();
    super.dispose();
  }
}
