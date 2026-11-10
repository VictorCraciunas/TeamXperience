import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/model/photo_detail.dart';
import 'package:teamxperience/model/team.dart';

void main() {
  group('PhotoDetail.fromValue', () {
    test('an old plain status', () {
      final detail = PhotoDetail.fromValue('pending');
      expect(detail?.status, PhotoApprovalStatus.pending);
      expect(detail?.reason, isNull);
      expect(detail?.url, isNull);
      expect(detail?.at, isNull);
    });

    test('the new map with every field', () {
      final at = DateTime(2026, 11, 14, 10, 31);
      final detail = PhotoDetail.fromValue({
        'status': 'denied',
        'reason': 'Nu se vede „ceasul”',
        'url': 'https://x/y.jpg',
        'at': Timestamp.fromDate(at),
      });
      expect(detail?.status, PhotoApprovalStatus.denied);
      expect(detail?.reason, 'Nu se vede „ceasul”');
      expect(detail?.url, 'https://x/y.jpg');
      expect(detail?.at, at);
    });

    test('a pending server time reads as no time', () {
      expect(PhotoDetail.fromValue({'status': 'approved', 'at': null})?.at, isNull);
    });

    test('an unknown status reads as nothing', () {
      expect(PhotoDetail.fromValue('maybe'), isNull);
      expect(PhotoDetail.fromValue({'status': 7}), isNull);
      expect(PhotoDetail.fromValue(null), isNull);
    });
  });

  group('Team photos', () {
    final team = Team.fromMap({
      'name': 'Vulpile',
      'photoApprovals': {
        '2_0_0': 'denied',
        '2_0_1': {'status': 'approved', 'url': 'https://x/1.jpg'},
      },
    });

    test('old strings and new maps both read', () {
      expect(team.photoApprovals, {'2_0_0': PhotoApprovalStatus.denied, '2_0_1': PhotoApprovalStatus.approved});
      expect(team.photoDetails['2_0_1']?.url, 'https://x/1.jpg');
      expect(team.photoDetails['2_0_0']?.status, PhotoApprovalStatus.denied);
    });

    test('approval works with the map form', () {
      expect(team.isPuzzleApproved(2, 0), isTrue);
      expect(team.nextTryIndex(2, 0), 2);
    });

    test('toJson writes the map form, without the time', () {
      final json = team.toJson()['photoApprovals'] as Map;
      expect(json['2_0_1'], {'status': 'approved', 'url': 'https://x/1.jpg'});
      expect(json['2_0_0'], {'status': 'denied'});
    });
  });
}
