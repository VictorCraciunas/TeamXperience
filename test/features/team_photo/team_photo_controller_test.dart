import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/team_photo_slot.dart';
import 'package:teamxperience/features/team_photo/controller/team_photo_controller.dart';

void main() {
  final file = File('poza.jpg');

  TeamPhotoController controller({
    Future<File?> Function()? take,
    Future<String?> Function(File, String)? upload,
    Future<void> Function(String)? save,
    TeamPhotoSlot slot = TeamPhotoSlot.start,
  }) =>
      TeamPhotoController(
        eventId: 'e',
        teamName: 'Vulpile',
        slot: slot,
        uid: 'u1',
        take: take ?? () async => file,
        upload: upload ?? (_, __) async => 'link',
        save: save ?? (_) async {},
      );

  test('uploads under the team and slot, then saves the link', () async {
    String? path;
    String? saved;
    final c = controller(
      slot: TeamPhotoSlot.finish,
      upload: (_, p) async {
        path = p;
        return 'link';
      },
      save: (url) async => saved = url,
    );
    await c.takeAndSend();
    expect(path, 'team_photos/Vulpile_finish');
    expect(saved, 'link');
    expect(c.error, isNull);
    expect(c.busy, isFalse);
  });

  test('cancelling the camera changes nothing', () async {
    var uploads = 0;
    final c = controller(
      take: () async => null,
      upload: (_, __) async {
        uploads++;
        return 'link';
      },
    );
    await c.takeAndSend();
    expect(uploads, 0);
    expect(c.error, isNull);
    expect(c.busy, isFalse);
  });

  test('a camera error shows the line', () async {
    final c = controller(take: () async => throw Exception('no camera'));
    await c.takeAndSend();
    expect(c.error, TeamPhotoController.failedLine);
    expect(c.busy, isFalse);
  });

  test('a failed upload shows the line and saves nothing', () async {
    var saves = 0;
    final c = controller(upload: (_, __) async => null, save: (_) async => saves++);
    await c.takeAndSend();
    expect(saves, 0);
    expect(c.error, TeamPhotoController.failedLine);
  });

  test('a failed save shows the line', () async {
    final c = controller(save: (_) async => throw Exception('offline'));
    await c.takeAndSend();
    expect(c.error, TeamPhotoController.failedLine);
    expect(c.busy, isFalse);
  });

  test('a second tap while sending does nothing', () async {
    var takes = 0;
    final gate = Completer<File?>();
    final c = controller(take: () {
      takes++;
      return gate.future;
    });
    final first = c.takeAndSend();
    await c.takeAndSend();
    gate.complete(file);
    await first;
    expect(takes, 1);
  });

  test('a retake clears the old error', () async {
    var fail = true;
    final c = controller(upload: (_, __) async => fail ? null : 'link');
    await c.takeAndSend();
    expect(c.error, isNotNull);
    fail = false;
    await c.takeAndSend();
    expect(c.error, isNull);
  });

  test('closing the screen during an upload does not throw', () async {
    final gate = Completer<String?>();
    final c = controller(upload: (_, __) => gate.future);
    final sending = c.takeAndSend();
    await Future<void>.delayed(Duration.zero);
    c.dispose();
    gate.complete('link');
    await sending;
  });
}
