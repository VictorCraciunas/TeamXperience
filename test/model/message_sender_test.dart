import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/message_type.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/model/message.dart';

void main() {
  final at = DateTime(2026, 11, 14, 10, 46);

  test('a player\'s message keeps who sent it', () {
    final message = Message(sender: Role.USER, text: 'Hei', timestamp: at, senderUid: 'u1', senderName: 'Ana');
    final json = message.toJson();
    expect(json['senderUid'], 'u1');
    expect(json['senderName'], 'Ana');

    final back = Message.fromFirestore(json);
    expect(back.senderUid, 'u1');
    expect(back.senderName, 'Ana');
    expect(back.timestamp, at);
  });

  test('an old message without a sender still reads, and writes no sender', () {
    final old = Message.fromFirestore({'sender': 'USER', 'text': 'Alo', 'timestamp': Timestamp.fromDate(at)});
    expect(old.senderUid, isNull);
    expect(old.senderName, isNull);
    expect(old.type, MessageType.text);

    final json = Message(sender: Role.ADMIN, text: 'Da', timestamp: at).toJson();
    expect(json.containsKey('senderUid'), isFalse);
    expect(json.containsKey('senderName'), isFalse);
  });

  test('a blank or odd sender is read as none', () {
    final odd = Message.fromFirestore({
      'sender': 'USER',
      'text': 'Alo',
      'timestamp': Timestamp.fromDate(at),
      'senderUid': '',
      'senderName': 7,
    });
    expect(odd.senderUid, isNull);
    expect(odd.senderName, isNull);
  });

  test('a message whose time is still on its way reads without failing', () {
    final pending = Message.fromFirestore({'sender': 'USER', 'text': 'Alo'});
    expect(pending.text, 'Alo');
  });
}
