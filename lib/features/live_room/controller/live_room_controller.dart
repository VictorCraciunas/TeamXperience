import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:teamxperience/backend/network/NetworkAPI.dart';
import 'package:teamxperience/backend/network/NotificationDTO.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/features/admin/home/logic/admin_event_stats.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/service/event_service/event_service.dart';
import 'package:teamxperience/service/message_service.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../logic/attention_queue.dart';
import '../logic/live_board.dart';
import '../logic/live_status.dart';

/// What an announcement managed to do.
enum AnnounceResult { sent, chatsOnly, failed, nothing }

/// What calling a captain managed to do.
enum CallResult { opened, noPhone, failed }

/// A `tel:` link with only the digits and the plus; null without a number.
Uri? phoneUri(String phone) {
  final clean = phone.replaceAll(RegExp(r'[^\d+]'), '');
  return clean.isEmpty ? null : Uri(scheme: 'tel', path: clean);
}

/// The organiser's live room: the event and its teams as they change, and what
/// the organiser can do about them. The room, its board and the big map all
/// read one of these; dialogs, snackbars and navigation stay in the screens.
class LiveRoomController extends ChangeNotifier {
  LiveRoomController({
    required Event event,
    Stream<Event>? eventStream,
    Stream<List<Team>>? teamStream,
    Future<void> Function(Team team, String key, PhotoApprovalStatus status, {String? reason, String? url})? writeApproval,
    Future<void> Function(String eventId)? stopEvent,
    Future<void> Function(List<String> teams, String text)? postToChats,
    Future<bool> Function(String title, String text)? pushNotification,
    Future<bool> Function(Uri uri)? openPhone,
    DateTime Function()? now,
  })  : _event = event,
        _now = now ?? DateTime.now,
        _writeApproval = writeApproval ??
            ((team, key, status, {reason, url}) =>
                TeamService().setPhotoApproval(event.eventId, team.name, key, status, reason: reason, url: url)),
        _stopEvent = stopEvent ?? EventService().stopEvent,
        _postToChats = postToChats ?? ((teams, text) => MessageService().announce(event.eventId, teams, text)),
        _push = pushNotification ?? ((title, text) => _sendPush(event.eventId, title, text)),
        _openPhone = openPhone ?? launchUrl {
    _eventSubscription = (eventStream ?? EventService().streamEvent(event.eventId)).listen((fresh) {
      _event = fresh;
      notifyListeners();
    }, onError: (Object _) {});
    _teamSubscription = (teamStream ?? TeamService().getStreamTeams(event.eventId)).listen((fresh) {
      _teams = fresh;
      _loading = false;
      _error = null;
      notifyListeners();
    }, onError: (Object e) {
      _error = e;
      _loading = false;
      notifyListeners();
    });
  }

  static Future<bool> _sendPush(String eventId, String title, String text) async {
    final response = await NetworkAPI.sendNotification(
      NotificationDTO(title: title, description: text, eventId: eventId),
    );
    return response.success;
  }

  final DateTime Function() _now;
  final Future<void> Function(Team team, String key, PhotoApprovalStatus status, {String? reason, String? url}) _writeApproval;
  final Future<void> Function(String eventId) _stopEvent;
  final Future<void> Function(List<String> teams, String text) _postToChats;
  final Future<bool> Function(String title, String text) _push;
  final Future<bool> Function(Uri uri) _openPhone;

  late final StreamSubscription<Event> _eventSubscription;
  late final StreamSubscription<List<Team>> _teamSubscription;

  Event _event;
  Event get event => _event;

  List<Team> _teams = const [];
  List<Team> get teams => _teams;

  bool _loading = true;
  bool get loading => _loading;

  Object? _error;

  /// The teams could not be read; [teams] holds the last ones that could.
  Object? get error => _error;

  bool _stopping = false;
  final Set<String> _deciding = {};
  bool _announcing = false;

  BoardFilter _filter = BoardFilter.all;
  BoardFilter get filter => _filter;

  int get missionCount => _event.missions.length;
  AdminEventStats get stats => AdminEventStats.fromTeams(_teams);

  bool get ended => eventEnded(_event, _now());

  bool get hasStarted {
    final start = _event.dateEvent;
    return start != null && !_now().isBefore(start);
  }

  bool get canStop => hasStarted && !ended && !_stopping;

  List<AttentionItem> attention(DateTime now) =>
      attentionQueue(_teams, missionCount: missionCount, now: now, eventOver: eventEnded(_event, now));

  List<BoardRow> rows(DateTime now) => boardRows(
        _teams,
        missionCount: missionCount,
        now: now,
        eventOver: eventEnded(_event, now),
        filter: _filter,
      );

  void setFilter(BoardFilter filter) {
    if (filter == _filter) return;
    _filter = filter;
    notifyListeners();
  }

  String _decisionId(PhotoAttention item) => '${item.team.name}/${item.key}';

  bool isDeciding(PhotoAttention item) => _deciding.contains(_decisionId(item));

  /// Approves or rejects a photo from the queue. False when it could not be
  /// saved, or when a decision on it is already on its way.
  Future<bool> decidePhoto(PhotoAttention item, {required bool approve, String? reason}) async {
    final id = _decisionId(item);
    if (!_deciding.add(id)) return false;
    notifyListeners();
    try {
      await _writeApproval(
        item.team,
        item.key,
        approve ? PhotoApprovalStatus.approved : PhotoApprovalStatus.denied,
        reason: approve ? null : reason,
        url: item.url,
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      _deciding.remove(id);
      notifyListeners();
    }
  }

  /// Stops the event for everyone. False when it could not be saved.
  Future<bool> stop() async {
    if (!canStop) return false;
    _stopping = true;
    notifyListeners();
    try {
      await _stopEvent(_event.eventId);
      _event.isStopped = true;
      return true;
    } catch (_) {
      return false;
    } finally {
      _stopping = false;
      notifyListeners();
    }
  }

  /// Posts [text] into every team's chat, then sends the push.
  Future<AnnounceResult> announce(String text) async {
    final message = text.trim();
    if (message.isEmpty || _announcing) return AnnounceResult.nothing;
    if (_loading) return AnnounceResult.failed;
    _announcing = true;
    try {
      if (_teams.isNotEmpty) {
        await _postToChats(_teams.map((t) => t.name).toList(), message);
      }
    } catch (_) {
      _announcing = false;
      return AnnounceResult.failed;
    }
    try {
      final pushed = await _push(_event.name ?? '', message);
      return pushed ? AnnounceResult.sent : AnnounceResult.chatsOnly;
    } catch (_) {
      return AnnounceResult.chatsOnly;
    } finally {
      _announcing = false;
    }
  }

  /// Opens the phone on the number of [team]'s captain.
  Future<CallResult> callCaptain(Team team) async {
    final uri = phoneUri(team.phoneNumber);
    if (uri == null) return CallResult.noPhone;
    try {
      return await _openPhone(uri) ? CallResult.opened : CallResult.failed;
    } catch (_) {
      return CallResult.failed;
    }
  }

  @override
  void dispose() {
    _eventSubscription.cancel();
    _teamSubscription.cancel();
    super.dispose();
  }
}
