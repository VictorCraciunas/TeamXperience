import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';

/// One try of a photo puzzle, as stored under `photoApprovals.{key}`: its
/// status, the organiser's reason for a rejection, the picture and when it
/// was last set. Older teams store only the status as text.
class PhotoDetail {
  const PhotoDetail({required this.status, this.reason, this.url, this.at});

  final PhotoApprovalStatus status;
  final String? reason;
  final String? url;

  /// Server time of the last change; null for old data or a pending write.
  final DateTime? at;

  static PhotoApprovalStatus? _status(Object? value) {
    for (final status in PhotoApprovalStatus.values) {
      if (status.name == value) return status;
    }
    return null;
  }

  /// A plain status, or `{status, reason?, url?, at?}`; null when the status
  /// cannot be read.
  static PhotoDetail? fromValue(Object? value) {
    if (value is String) {
      final status = _status(value);
      return status == null ? null : PhotoDetail(status: status);
    }
    if (value is Map) {
      final status = _status(value['status']);
      if (status == null) return null;
      final at = value['at'];
      final reason = value['reason'];
      final url = value['url'];
      return PhotoDetail(
        status: status,
        reason: reason is String ? reason : null,
        url: url is String ? url : null,
        at: switch (at) {
          Timestamp() => at.toDate(),
          DateTime() => at,
          _ => null,
        },
      );
    }
    return null;
  }

  /// The stored form, without the time (the server sets it).
  Map<String, dynamic> toJson() => {
        'status': status.name,
        if (reason != null) 'reason': reason,
        if (url != null) 'url': url,
      };
}
