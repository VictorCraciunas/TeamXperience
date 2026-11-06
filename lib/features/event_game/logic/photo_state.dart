import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/model/photo_detail.dart';
import 'package:teamxperience/model/team.dart';

/// Where a photo puzzle stands for the team.
enum PhotoStep { none, uploading, waiting, approved, rejected }

/// The photo puzzle [puzzle] of mission [mission]: an upload in progress
/// wins; then any approved try (a teammate's later upload cannot undo an
/// approval); otherwise the latest try (highest try number) decides.
({PhotoStep step, PhotoDetail? detail}) photoState(Team team, int mission, int puzzle, {required bool uploading}) {
  final prefix = Team.approvalKeyPrefix(mission, puzzle);
  PhotoDetail? latest;
  PhotoDetail? approved;
  var latestTry = -1;
  team.photoDetails.forEach((key, detail) {
    if (!key.startsWith(prefix)) return;
    if (detail.status == PhotoApprovalStatus.approved) approved ??= detail;
    final number = int.tryParse(key.substring(prefix.length));
    if (number != null && number > latestTry) {
      latestTry = number;
      latest = detail;
    }
  });
  if (uploading) return (step: PhotoStep.uploading, detail: latest);
  final done = approved;
  if (done != null) return (step: PhotoStep.approved, detail: done);
  final detail = latest;
  if (detail == null) return (step: PhotoStep.none, detail: null);
  return (
    step: switch (detail.status) {
      PhotoApprovalStatus.pending => PhotoStep.waiting,
      PhotoApprovalStatus.approved => PhotoStep.approved,
      PhotoApprovalStatus.denied => PhotoStep.rejected,
    },
    detail: detail,
  );
}

/// "chiar acum", "acum 4 min", "acum 1 h"; "" without a time.
String sentAgo(DateTime? at, DateTime now) {
  if (at == null) return '';
  final minutes = now.difference(at).inMinutes;
  if (minutes < 1) return 'chiar acum';
  if (minutes < 60) return 'acum $minutes min';
  return 'acum ${minutes ~/ 60} h';
}

/// "Respinsă: „Nu se vede ceasul”", or "Respinsă" without a reason.
String rejectedLine(String? reason) {
  final text = reason?.trim() ?? '';
  return text.isEmpty ? 'Respinsă' : 'Respinsă: „$text”';
}
