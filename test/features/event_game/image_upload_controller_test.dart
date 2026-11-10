import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/features/event_game/controller/image_upload_puzzle_controller.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/user.dart';

AppUser _user() => AppUser(uid: 'vc', firstName: 'Victor', lastName: 'C', email: 'v@x.ro', role: Role.USER, fcmToken: '');

void main() {
  final now = DateTime(2026, 11, 14, 10, 31);
  late List<String> calls;
  late Completer<void> messageSent;

  ImageUploadPuzzleController controller({String? url = 'https://x/p.jpg', bool failWrite = false}) {
    calls = [];
    messageSent = Completer<void>();
    return ImageUploadPuzzleController(
      eventId: 'e1',
      teamName: 'Vulpile',
      missionIndex: 2,
      puzzleIndex: 0,
      user: _user(),
      teamStream: const Stream<Team>.empty(),
      clock: () => now,
      pick: () async => File('poza.jpg'),
      upload: (file, path) async {
        calls.add('upload');
        return url;
      },
      markPending: (key, url) async {
        calls.add('pending $key $url');
        if (failWrite) throw Exception('offline');
      },
      sendMessage: (url, key) async {
        calls.add('message $key');
        await messageSent.future;
      },
    );
  }

  test('each upload is its own try, named by its time', () async {
    final c = controller();
    final done = c.pickAndUpload();
    await Future<void>.delayed(Duration.zero);
    messageSent.complete();
    await done;
    final key = Team.approvalKey(2, 0, now.millisecondsSinceEpoch);
    expect(calls, ['upload', 'pending $key https://x/p.jpg', 'message $key']);
  });

  test('it stays "sending" until the approval and the message are written', () async {
    final c = controller();
    final done = c.pickAndUpload();
    await Future<void>.delayed(Duration.zero);
    expect(c.isUploading, isTrue, reason: 'the message is still on its way');
    messageSent.complete();
    await done;
    expect(c.isUploading, isFalse);
    expect(c.error, isNull);
  });

  test('a failed upload says so and stops sending', () async {
    final c = controller(url: null);
    await c.pickAndUpload();
    expect(c.isUploading, isFalse);
    expect(c.error, 'Poza nu s-a trimis. Încearcă din nou.');
    expect(calls, ['upload']);
  });

  test('a failed write says so too', () async {
    final c = controller(failWrite: true);
    await c.pickAndUpload();
    expect(c.isUploading, isFalse);
    expect(c.error, 'Poza nu s-a trimis. Încearcă din nou.');
  });

  test('closing the puzzle mid-upload does not throw', () async {
    final c = controller();
    final done = c.pickAndUpload();
    await Future<void>.delayed(Duration.zero);
    c.dispose();
    messageSent.complete();
    await done;
  });
}
