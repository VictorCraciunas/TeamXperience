import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/event_game/logic/photo_state.dart';
import 'package:teamxperience/model/team.dart';

Team _team(Map<String, dynamic> approvals) => Team.fromMap({'name': 'Vulpile', 'photoApprovals': approvals});

void main() {
  group('photoState', () {
    test('no tries: nothing sent yet', () {
      expect(photoState(_team({}), 2, 0, uploading: false).step, PhotoStep.none);
    });

    test('the latest try decides: a new pending try after a rejection', () {
      final state = photoState(
        _team({
          '2_0_0': {'status': 'denied', 'reason': 'Nu se vede ceasul'},
          '2_0_1': {'status': 'pending', 'url': 'https://x/2.jpg'},
        }),
        2,
        0,
        uploading: false,
      );
      expect(state.step, PhotoStep.waiting);
      expect(state.detail?.url, 'https://x/2.jpg');
      expect(state.detail?.reason, isNull);
    });

    test('approved and rejected', () {
      expect(photoState(_team({'2_0_0': 'approved'}), 2, 0, uploading: false).step, PhotoStep.approved);
      final rejected = photoState(_team({'2_0_0': {'status': 'denied', 'reason': 'Prea întuneric'}}), 2, 0, uploading: false);
      expect(rejected.step, PhotoStep.rejected);
      expect(rejected.detail?.reason, 'Prea întuneric');
    });

    test('an approved try wins over a later pending one (a teammate\'s late upload)', () {
      final state = photoState(
        _team({
          '2_0_1731580000000': {'status': 'approved', 'url': 'https://x/a.jpg'},
          '2_0_1731580009000': {'status': 'pending', 'url': 'https://x/b.jpg'},
        }),
        2,
        0,
        uploading: false,
      );
      expect(state.step, PhotoStep.approved);
      expect(state.detail?.url, 'https://x/a.jpg');
    });

    test('try keys made from the upload time order by time', () {
      expect(
        photoState(_team({'2_0_1731580009000': 'pending', '2_0_1731580000000': 'denied'}), 2, 0, uploading: false).step,
        PhotoStep.waiting,
      );
    });

    test('try 10 comes after try 9', () {
      expect(photoState(_team({'2_0_9': 'denied', '2_0_10': 'approved'}), 2, 0, uploading: false).step, PhotoStep.approved);
    });

    test('an upload in progress wins', () {
      expect(photoState(_team({'2_0_0': 'denied'}), 2, 0, uploading: true).step, PhotoStep.uploading);
    });

    test('another puzzle\'s tries are not this one\'s', () {
      expect(photoState(_team({'2_1_0': 'approved', '12_0_0': 'approved'}), 2, 0, uploading: false).step, PhotoStep.none);
    });
  });

  test('how long ago it was sent', () {
    final now = DateTime(2026, 11, 14, 10, 30);
    expect(sentAgo(now.subtract(const Duration(seconds: 30)), now), 'chiar acum');
    expect(sentAgo(now.subtract(const Duration(minutes: 4)), now), 'acum 4 min');
    expect(sentAgo(now.subtract(const Duration(minutes: 75)), now), 'acum 1 h');
    expect(sentAgo(null, now), '');
    expect(sentAgo(now.add(const Duration(seconds: 5)), now), 'chiar acum');
  });

  test('the rejected line', () {
    expect(rejectedLine('Nu se vede ceasul'), 'Respinsă: „Nu se vede ceasul”');
    expect(rejectedLine('  '), 'Respinsă');
    expect(rejectedLine(null), 'Respinsă');
  });
}
