import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:teamxperience/backend/storage/storage_images.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/user.dart';
import 'package:teamxperience/service/message_service.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/utils/image_helper.dart';

class ImageUploadPuzzleController extends ChangeNotifier {
  final String eventId;
  final String teamName;
  final int missionIndex;
  final int puzzleIndex;
  final AppUser user;

  final ImageRepo _imageRepo = ImageRepo();
  final MessageService _messageService = MessageService();
  final TeamService _teamService = TeamService();

  File? _selectedImage;
  bool _isUploading = false;

  File? get selectedImage => _selectedImage;
  bool get isUploading => _isUploading;
  String get approvalKeyPrefix => Team.approvalKeyPrefix(missionIndex, puzzleIndex);

  late final Stream<Team> teamStream;

  ImageUploadPuzzleController({
    required this.eventId,
    required this.teamName,
    required this.missionIndex,
    required this.puzzleIndex,
    required this.user,
  }) {
    teamStream = _teamService.getStreamTeam(eventId, teamName);
  }

  PhotoApprovalStatus? statusFor(Team team) {
    final prefix = approvalKeyPrefix;
    PhotoApprovalStatus? latest;
    int latestTry = -1;
    for (final entry in team.photoApprovals.entries) {
      if (entry.key.startsWith(prefix)) {
        final tryStr = entry.key.substring(prefix.length);
        final tryIdx = int.tryParse(tryStr) ?? 0;
        if (tryIdx > latestTry) {
          latestTry = tryIdx;
          latest = entry.value;
        }
      }
    }
    return latest;
  }

  bool isApproved(Team team) => team.isPuzzleApproved(missionIndex, puzzleIndex);

  Future<void> pickAndUpload(Team team) async {
    final file = await ImageHelper.pickImage();
    if (file == null) return;

    _selectedImage = file;
    _isUploading = true;
    notifyListeners();

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path =
        'team_photos/${teamName}_mission_${missionIndex}_puzzle_${puzzleIndex}_$timestamp';
    final url = await _imageRepo.uploadImage(file, eventId, path);

    _isUploading = false;
    notifyListeners();

    if (url == null) return;

    final tryIndex = team.nextTryIndex(missionIndex, puzzleIndex);
    final key = Team.approvalKey(missionIndex, puzzleIndex, tryIndex);

    await _messageService.sendImageMessage(eventId, teamName, url, user, approvalKey: key);
    await _teamService.setPhotoApproval(
      eventId,
      teamName,
      key,
      PhotoApprovalStatus.pending,
    );
  }
}
