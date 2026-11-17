import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/features/chat/controller/chat_controller.dart';
import 'package:teamxperience/features/chat/logic/chat_timeline.dart';
import 'package:teamxperience/features/live_room/controller/live_room_controller.dart' show CallResult;
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/message.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/user.dart';

Team _team({String phone = '0722 123', double lat = 0, bool started = false}) => Team(
      name: 'Vulpile',
      teamMembers: '',
      captainName: '',
      phoneNumber: phone,
      captainEmail: '',
      latitude: lat,
      longitude: lat,
      hasStarted: started,
    );

AppUser _user(Role role) => AppUser(email: 'a@x.ro', firstName: 'Ana', lastName: 'Pop', uid: 'u1', role: role, fcmToken: '');

class _Rig {
  _Rig({Role role = Role.ADMIN, Team? team, this.pick, this.upload, this.sendFails = false}) {
    controller = ChatController(
      eventId: 'e1',
      team: team ?? _team(),
      user: _user(role),
      teamStream: teams.stream,
      eventStream: events.stream,
      messageStream: messages.stream,
      writeApproval: (key, status, {reason, url}) async => approvals.add((key, status, reason, url)),
      sendText: (text) async {
        if (sendFails) throw StateError('permission-denied');
        sent.add(text);
      },
      pickPhoto: () async => pick?.call(),
      uploadPhoto: (file, path) async {
        paths.add(path);
        return upload?.call();
      },
      sendPhotoMessage: (url) async => photos.add(url),
      clearUnread: () async => cleared++,
      openPhone: (uri) async {
        dialled.add(uri);
        return true;
      },
      clock: () => DateTime(2026, 11, 14, 10, 0),
    );
  }

  final File? Function()? pick;
  final String? Function()? upload;
  final bool sendFails;
  final teams = StreamController<Team>();
  final events = StreamController<Event>();
  final messages = StreamController<List<ChatMessageDoc>>();
  final approvals = <(String, PhotoApprovalStatus, String?, String?)>[];
  final sent = <String>[];
  final paths = <String>[];
  final photos = <String>[];
  final dialled = <Uri>[];
  var cleared = 0;
  late final ChatController controller;
}

void main() {
  test('approving and rejecting keep the photo\'s picture', () async {
    final rig = _Rig();
    await rig.controller.approvePhoto('2_0_1', url: 'https://x/p.jpg');
    await rig.controller.denyPhoto('2_0_2', '  Nu se vede ceasul ', url: 'https://x/q.jpg');
    expect(rig.approvals, [
      ('2_0_1', PhotoApprovalStatus.approved, null, 'https://x/p.jpg'),
      ('2_0_2', PhotoApprovalStatus.denied, 'Nu se vede ceasul', 'https://x/q.jpg'),
    ]);
  });

  test('loads, then follows the team, the event and the messages', () async {
    final rig = _Rig();
    expect(rig.controller.loading, isTrue);
    expect(rig.controller.strip, isNull);
    rig.messages.add([ChatMessageDoc('m', Message(sender: Role.USER, text: 'Hei', timestamp: DateTime(2026, 11, 14, 9)))]);
    rig.events.add(Event(eventId: 'e1', missions: [Mission(id: '0'), Mission(id: '1'), Mission(id: '2')]));
    rig.teams.add(_team(started: true)..missionProgress = 1);
    await pumpEventQueue();
    expect(rig.controller.loading, isFalse);
    expect(rig.controller.entries().whereType<ChatTextEntry>().single.text, 'Hei');
    expect(rig.controller.strip?.text, 'Misiunea 2 din 3');
  });

  test('sends what is typed and empties the field; blank text is not sent', () async {
    final rig = _Rig(role: Role.USER);
    rig.controller.chatTextField.text = '   ';
    await rig.controller.sendMessage();
    rig.controller.chatTextField.text = 'Am ajuns';
    await rig.controller.sendMessage();
    expect(rig.sent, ['Am ajuns']);
    expect(rig.controller.chatTextField.text, isEmpty);
  });

  test('says whether the text went: sent, blank or failed', () async {
    final rig = _Rig(role: Role.USER);
    rig.controller.chatTextField.text = ' ';
    expect(await rig.controller.sendMessage(), ChatSendResult.blank);
    rig.controller.chatTextField.text = 'Am ajuns';
    expect(await rig.controller.sendMessage(), ChatSendResult.sent);
  });

  test('a refused send puts the text back in the field', () async {
    final rig = _Rig(role: Role.USER, sendFails: true);
    rig.controller.chatTextField.text = 'Am ajuns la fântână';
    expect(await rig.controller.sendMessage(), ChatSendResult.failed);
    expect(rig.controller.chatTextField.text, 'Am ajuns la fântână');
    expect(rig.controller.chatTextField.selection.baseOffset, 'Am ajuns la fântână'.length);
  });

  test('a refused send keeps what was typed after it, below the text', () async {
    final rig = _Rig(role: Role.USER, sendFails: true);
    rig.controller.chatTextField.text = 'Prima';
    final sending = rig.controller.sendMessage();
    rig.controller.chatTextField.text = 'A doua';
    expect(await sending, ChatSendResult.failed);
    expect(rig.controller.chatTextField.text, 'Prima\nA doua');
  });

  group('photo button', () {
    test('picks, uploads under chat_photos and posts the picture', () async {
      final rig = _Rig(pick: () => File('p.jpg'), upload: () => 'https://x/p.jpg');
      expect(await rig.controller.sendPhoto(), ChatPhotoResult.sent);
      expect(rig.paths, ['chat_photos/Vulpile_${DateTime(2026, 11, 14, 10).millisecondsSinceEpoch}']);
      expect(rig.photos, ['https://x/p.jpg']);
      expect(rig.controller.sendingPhoto, isFalse);
    });

    test('nothing picked sends nothing; a failed upload says so', () async {
      expect(await _Rig().controller.sendPhoto(), ChatPhotoResult.cancelled);
      final failing = _Rig(pick: () => File('p.jpg'), upload: () => null);
      expect(await failing.controller.sendPhoto(), ChatPhotoResult.failed);
      expect(failing.photos, isEmpty);
    });
  });

  test('the map waits for the event and a position; the call for a number', () async {
    final rig = _Rig();
    expect(rig.controller.mapArgs, isNull);
    rig.events.add(Event(eventId: 'e1'));
    await pumpEventQueue();
    expect(rig.controller.mapArgs, isNull, reason: 'no position yet');
    rig.teams.add(_team(lat: 45.1, started: true));
    await pumpEventQueue();
    expect(rig.controller.mapArgs?.focusTeam, 'Vulpile');

    expect(rig.controller.canCall, isTrue);
    expect(await rig.controller.callCaptain(), CallResult.opened);
    expect(rig.dialled.single.toString(), 'tel:0722123');
    final silent = _Rig(team: _team(phone: ''));
    expect(silent.controller.canCall, isFalse);
    expect(await silent.controller.callCaptain(), CallResult.noPhone);
  });

  test('only the organiser marks the chat read', () {
    final organiser = _Rig()..controller.markRead();
    final player = _Rig(role: Role.USER)..controller.markRead();
    expect(organiser.cleared, 1);
    expect(player.cleared, 0);
  });
}
