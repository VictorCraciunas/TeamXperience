import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:teamxperience/backend/storage/storage_images.dart';
import 'package:teamxperience/enums/team_photo_slot.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/utils/image_helper.dart';

/// Takes and sends a team's optional start or final photo. Nothing here can
/// stop a game: a cancelled camera changes nothing and a failure only shows a
/// line. A retake replaces the file. The writes can be passed in (tests); by
/// default they go to Firebase.
class TeamPhotoController extends ChangeNotifier {
  TeamPhotoController({
    required this.eventId,
    required this.teamName,
    required this.slot,
    required this.uid,
    Future<File?> Function()? take,
    Future<String?> Function(File file, String path)? upload,
    Future<void> Function(String url)? save,
  })  : _take = take ?? ImageHelper.takePhoto,
        _upload = upload ?? ((file, path) => ImageRepo().uploadImage(file, eventId, path)),
        _save = save ?? ((url) => TeamService().setTeamPhoto(eventId, teamName, slot, url, uid));

  static const String failedLine = 'Poza nu s-a trimis. Încearcă din nou.';

  final String eventId;
  final String teamName;
  final TeamPhotoSlot slot;
  final String uid;

  final Future<File?> Function() _take;
  final Future<String?> Function(File file, String path) _upload;
  final Future<void> Function(String url) _save;

  bool _busy = false;
  String? _error;
  bool _disposed = false;

  bool get busy => _busy;

  /// Set when the last photo did not go out.
  String? get error => _error;

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  /// Opens the camera and sends what it took.
  Future<void> takeAndSend() async {
    if (_busy) return;
    _busy = true;
    _error = null;
    _changed();
    try {
      final file = await _take();
      if (file == null || _disposed) return;
      final url = await _upload(file, 'team_photos/${teamName}_${slot.name}');
      if (url == null) {
        _error = failedLine;
        return;
      }
      await _save(url);
    } catch (_) {
      _error = failedLine;
    } finally {
      _busy = false;
      _changed();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
