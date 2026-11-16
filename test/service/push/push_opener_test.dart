import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/service/push/push_opener.dart';

void main() {
  late List<Map<String, dynamic>> opened;
  late PushOpener opener;

  setUp(() {
    opened = [];
    opener = PushOpener(go: opened.add);
  });

  const chat = {'type': 'chat_message', 'eventId': 'e1', 'teamName': 'Vulpile'};

  test('a tap before the first screen waits for it', () {
    opener.open(chat);
    expect(opened, isEmpty);
    opener.landed(signedIn: true);
    expect(opened, [chat]);
  });

  test('it is opened once only', () {
    opener.open(chat);
    opener.landed(signedIn: true);
    opener.landed(signedIn: true);
    expect(opened, [chat]);
  });

  test('a start with nobody signed in drops what was waiting', () {
    opener.open(chat);
    opener.landed(signedIn: false);
    expect(opened, isEmpty);
    opener.landed(signedIn: true);
    expect(opened, isEmpty);
  });

  test('once the app is up, a tap opens at once', () {
    opener.landed(signedIn: true);
    opener.open(chat);
    expect(opened, [chat]);
  });

  test('signed out, a tap is dropped: it was for the account that left', () {
    opener.landed(signedIn: false);
    opener.open(chat);
    opener.landed(signedIn: true);
    expect(opened, isEmpty);
    opener.open(chat);
    expect(opened, [chat]);
  });
}
