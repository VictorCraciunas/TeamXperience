import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:teamxperience/backend/storage/storage_images.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/features/live_room/controller/live_room_controller.dart' show CallResult, phoneUri;
import 'package:teamxperience/features/live_room/logic/live_map_focus.dart';
import 'package:teamxperience/features/live_room/logic/live_map_points.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/message.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/user.dart';
import 'package:teamxperience/service/event_service/event_service.dart';
import 'package:teamxperience/service/message_service.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/utils/image_helper.dart';
import 'package:url_launcher/url_launcher.dart';

import '../logic/chat_texts.dart';
import '../logic/chat_timeline.dart';

/// What sending a photo from the chat came to.
enum ChatPhotoResult { sent, cancelled, failed, busy }

/// One team's chat, for the organiser or one of its players: the team, the
/// event and the messages as they change, and what can be done from it.
/// Dialogs, snackbars and navigation stay in the screen. Every write and
/// stream can be passed in (tests); by default they go to Firebase.
class ChatController extends ChangeNotifier {
  ChatController({
    required this.eventId,
    required Team team,
    required this.user,
    Stream<Team>? teamStream,
    Stream<Event>? eventStream,
    Stream<List<ChatMessageDoc>>? messageStream,
    Future<void> Function(String key, PhotoApprovalStatus status, {String? reason, String? url})? writeApproval,
    Future<void> Function(String text)? sendText,
    Future<File?> Function()? pickPhoto,
    Future<String?> Function(File file, String path)? uploadPhoto,
    Future<void> Function(String url)? sendPhotoMessage,
    Future<void> Function()? clearUnread,
    Future<bool> Function(Uri uri)? openPhone,
    DateTime Function()? clock,
  })  : _team = team,
        _clock = clock ?? DateTime.now,
        _pickPhoto = pickPhoto ?? ImageHelper.pickImage,
        _openPhone = openPhone ?? launchUrl {
    _writeApproval = writeApproval ??
        (key, status, {reason, url}) =>
            TeamService().setPhotoApproval(eventId, _team.name, key, status, reason: reason, url: url);
    _sendText = sendText ?? (text) => MessageService().sendMessage(eventId, _team.name, text, user);
    _uploadPhoto = uploadPhoto ?? (file, path) => ImageRepo().uploadImage(file, eventId, path);
    _sendPhotoMessage = sendPhotoMessage ??
        (url) => MessageService().sendImageMessage(eventId, _team.name, url, user, text: 'Fotografie');
    _clearUnread = clearUnread ?? () => TeamService().clearUnread(eventId, _team.name);

    _subscriptions = [
      (teamStream ?? TeamService().getStreamTeam(eventId, team.name)).listen((fresh) {
        _team = fresh;
        notifyListeners();
      }, onError: (Object _) {}),
      (eventStream ?? EventService().streamEvent(eventId)).listen((fresh) {
        _event = fresh;
        notifyListeners();
      }, onError: (Object _) {}),
      (messageStream ?? _firestoreMessages(eventId, team.name)).listen((fresh) {
        _messages = fresh;
        notifyListeners();
      }, onError: (Object _) {
        _messages ??= const [];
        notifyListeners();
      }),
    ];
  }

  static const String photoFailedLine = 'Poza nu s-a trimis. Încearcă din nou.';

  final String eventId;
  final AppUser user;
  final TextEditingController chatTextField = TextEditingController();

  final DateTime Function() _clock;
  final Future<File?> Function() _pickPhoto;
  final Future<bool> Function(Uri uri) _openPhone;
  late final Future<void> Function(String key, PhotoApprovalStatus status, {String? reason, String? url})
      _writeApproval;
  late final Future<void> Function(String text) _sendText;
  late final Future<String?> Function(File file, String path) _uploadPhoto;
  late final Future<void> Function(String url) _sendPhotoMessage;
  late final Future<void> Function() _clearUnread;
  late final List<StreamSubscription<Object?>> _subscriptions;

  Team _team;
  Event? _event;
  List<ChatMessageDoc>? _messages;
  bool _sendingPhoto = false;
  bool _disposed = false;

  static Stream<List<ChatMessageDoc>> _firestoreMessages(String eventId, String teamName) {
    return MessageService().getMessages(eventId, teamName).map((snapshot) {
      final docs = <ChatMessageDoc>[];
      for (final doc in snapshot.docs) {
        try {
          docs.add(ChatMessageDoc(doc.id, Message.fromFirestore(doc.data())));
        } catch (_) {
          // A message that cannot be read is left out rather than the chat.
        }
      }
      return docs;
    });
  }

  /// The team as it is now.
  Team get team => _team;

  /// Null until it arrives.
  Event? get event => _event;

  bool get isOrganiser => user.role == Role.ADMIN;

  /// Null while the messages load.
  bool get loading => _messages == null;
  bool get sendingPhoto => _sendingPhoto;

  /// The chat's lines, oldest first.
  List<ChatEntry> entries() => chatTimeline(
        messages: _messages ?? const [],
        team: _team,
        organiserView: isOrganiser,
        myUid: user.uid,
        now: _clock(),
      );

  /// The organiser's "Misiunea 4 din 6" strip; null without the event's missions.
  ({String text, int done, int? current})? get strip => missionStrip(_team, _event?.missions.length ?? 0);

  /// The live map centred on the team; null until the event is known or
  /// while the team has no position.
  LiveMapArgs? get mapArgs {
    final event = _event;
    if (event == null || !hasPin(_team)) return null;
    return LiveMapArgs(event, focusTeam: _team.name);
  }

  bool get canCall => phoneUri(_team.phoneNumber) != null;

  /// Sends what is typed and empties the field (the keyboard stays up).
  Future<void> sendMessage() async {
    final text = chatTextField.text;
    if (text.trim().isEmpty) return;
    chatTextField.clear();
    await _sendText(text);
  }

  /// Picks a picture from the gallery and posts it in the chat.
  Future<ChatPhotoResult> sendPhoto() async {
    if (_sendingPhoto) return ChatPhotoResult.busy;
    final File? file;
    try {
      file = await _pickPhoto();
    } catch (_) {
      return ChatPhotoResult.failed;
    }
    if (file == null || _disposed) return ChatPhotoResult.cancelled;
    _sendingPhoto = true;
    notifyListeners();
    try {
      final time = _clock().millisecondsSinceEpoch;
      final url = await _uploadPhoto(file, 'chat_photos/${_team.name}_$time');
      if (url == null) return ChatPhotoResult.failed;
      await _sendPhotoMessage(url);
      return ChatPhotoResult.sent;
    } catch (_) {
      return ChatPhotoResult.failed;
    } finally {
      _sendingPhoto = false;
      notifyListeners();
    }
  }

  /// The organiser has seen this chat: the live room stops asking about it.
  /// A failure only leaves the card up.
  void markRead() {
    if (!isOrganiser) return;
    _clearUnread().catchError((Object _) {});
  }

  Future<CallResult> callCaptain() async {
    final uri = phoneUri(_team.phoneNumber);
    if (uri == null) return CallResult.noPhone;
    try {
      return await _openPhone(uri) ? CallResult.opened : CallResult.failed;
    } catch (_) {
      return CallResult.failed;
    }
  }

  /// Approves a photo, keeping its picture ([url]) on the try.
  Future<void> approvePhoto(String approvalKey, {String? url}) async {
    await _writeApproval(approvalKey, PhotoApprovalStatus.approved, url: url);
  }

  /// Rejects a photo with the [reason] the team will read.
  Future<void> denyPhoto(String approvalKey, String reason, {String? url}) async {
    final text = reason.trim();
    await _writeApproval(approvalKey, PhotoApprovalStatus.denied, reason: text.isEmpty ? null : text, url: url);
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    chatTextField.dispose();
    super.dispose();
  }
}
