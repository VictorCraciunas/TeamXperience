import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:teamxperience/backend/storage/storage_images.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/user.dart';
import 'package:teamxperience/service/message_service.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/utils/image_helper.dart';

/// Sends a photo puzzle's picture: uploads it, marks the try as waiting for the
/// organiser (with the picture's link) and posts it in the team's chat. Each
/// upload is its own try, named by its time, so two phones never share one.
/// The writes can be passed in (tests); by default they go to Firebase.
class ImageUploadPuzzleController extends ChangeNotifier {
  ImageUploadPuzzleController({
    required this.eventId,
    required this.teamName,
    required this.missionIndex,
    required this.puzzleIndex,
    required this.user,
    Stream<Team>? teamStream,
    Future<File?> Function()? pick,
    Future<String?> Function(File file, String path)? upload,
    Future<void> Function(String key, String url)? markPending,
    Future<void> Function(String url, String key)? sendMessage,
    DateTime Function()? clock,
  })  : _pick = pick ?? ImageHelper.pickImage,
        _clock = clock ?? DateTime.now {
    this.teamStream = teamStream ?? _teamService.getStreamTeam(eventId, teamName);
    _upload = upload ?? ((file, path) => ImageRepo().uploadImage(file, eventId, path));
    _markPending = markPending ??
        ((key, url) => _teamService.setPhotoApproval(eventId, teamName, key, PhotoApprovalStatus.pending, url: url));
    _sendMessage = sendMessage ??
        ((url, key) => MessageService().sendImageMessage(eventId, teamName, url, user, approvalKey: key));
  }

  static const String failedLine = 'Poza nu s-a trimis. Încearcă din nou.';

  final String eventId;
  final String teamName;
  final int missionIndex;
  final int puzzleIndex;
  final AppUser user;

  late final TeamService _teamService = TeamService();
  final Future<File?> Function() _pick;
  final DateTime Function() _clock;
  late final Future<String?> Function(File file, String path) _upload;
  late final Future<void> Function(String key, String url) _markPending;
  late final Future<void> Function(String url, String key) _sendMessage;

  late final Stream<Team> teamStream;

  File? _selectedImage;
  bool _isUploading = false;
  String? _error;
  bool _disposed = false;

  File? get selectedImage => _selectedImage;
  bool get isUploading => _isUploading;

  /// Set when the last photo did not go out.
  String? get error => _error;

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  /// Takes a photo and sends it. "Sending" lasts until the try is marked and
  /// the chat message is written, so the old state never shows meanwhile.
  Future<void> pickAndUpload() async {
    if (_isUploading) return;
    final file = await _pick();
    if (file == null || _disposed) return;

    _selectedImage = file;
    _isUploading = true;
    _error = null;
    _changed();

    final time = _clock().millisecondsSinceEpoch;
    final key = Team.approvalKey(missionIndex, puzzleIndex, time);
    final path = 'team_photos/${teamName}_mission_${missionIndex}_puzzle_${puzzleIndex}_$time';
    try {
      final url = await _upload(file, path);
      if (url == null) {
        _error = failedLine;
        return;
      }
      await _markPending(key, url);
      await _sendMessage(url, key);
    } catch (_) {
      _error = failedLine;
    } finally {
      _isUploading = false;
      _changed();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
