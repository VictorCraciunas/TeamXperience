import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/join_team/logic/join_state.dart';
import 'package:teamxperience/model/team_member.dart';
import 'package:teamxperience/service/team_service/invite_preview.dart';

InvitePreview _preview({int count = 2, int size = 4}) => InvitePreview(
  crewId: 'c1',
  crewName: 'Vulpile',
  captainName: 'Victor',
  members: const [
    TeamMember(uid: 'u1', displayName: 'Victor C', initials: 'VC'),
    TeamMember(uid: 'u2', displayName: 'Ana M', initials: 'AM'),
  ],
  alreadyMember: false,
  event: InviteEvent(
    eventId: 'e1',
    name: 'Moștenirea Cartografului',
    dateEvent: DateTime(2026, 11, 14, 10),
    teamName: 'Vulpile',
    size: size,
    count: count,
  ),
);

FirebaseFunctionsException _failure(String reason) =>
    FirebaseFunctionsException(
      message: reason,
      code: 'failed-precondition',
      details: {'reason': reason},
    );

class _Fakes {
  final previewed = <String>[];
  final joined = <String>[];
  InvitePreview result = _preview();
  Object? previewFailure;
  Object? joinFailure;
  List<String> joinResult = ['e1'];
  Completer<void>? holdPreview;
  Completer<void>? holdJoin;

  late final JoinFlow flow = JoinFlow(
    preview: (code) async {
      previewed.add(code);
      await holdPreview?.future;
      final error = previewFailure;
      if (error != null) throw error;
      return result;
    },
    join: (code) async {
      joined.add(code);
      await holdJoin?.future;
      final error = joinFailure;
      if (error != null) throw error;
      return joinResult;
    },
  );

  JoinState get state => flow.state.value;

  String? get problemText {
    final s = state;
    return s is Problem ? s.text : null;
  }
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  test('starts as Typing, and five characters stay Typing', () async {
    final f = _Fakes();
    expect(f.state, isA<Typing>());
    f.flow.codeChanged('VLP48');
    await _settle();
    expect(f.state, isA<Typing>());
    expect(f.previewed, isEmpty);
  });

  test('a complete code goes Looking and then Found', () async {
    final f = _Fakes();
    f.holdPreview = Completer<void>();
    f.flow.codeChanged('vlp482');
    expect(f.state, isA<Looking>());
    f.holdPreview?.complete();
    await _settle();
    final state = f.state;
    expect(state is Found ? state.preview.crewName : null, 'Vulpile');
    expect(f.previewed, ['VLP482']);
  });

  test(
    'a code that is not three letters and three digits is refused without asking',
    () async {
      final f = _Fakes();
      f.flow.codeChanged('VLP48A');
      await _settle();
      expect(f.problemText, 'Codul nu există');
      expect(f.previewed, isEmpty);
    },
  );

  test('an unknown code is a Problem with the error text', () async {
    final f = _Fakes()..previewFailure = _failure('codeUnknown');
    f.flow.codeChanged('VLP482');
    await _settle();
    expect(f.problemText, 'Codul nu există');
  });

  test('editing the code after a Problem goes back to Typing', () async {
    final f = _Fakes()..previewFailure = _failure('codeUnknown');
    f.flow.codeChanged('VLP482');
    await _settle();
    f.flow.codeChanged('VLP48');
    expect(f.state, isA<Typing>());
  });

  test('a late answer for an earlier code is ignored', () async {
    final f = _Fakes();
    f.holdPreview = Completer<void>();
    f.flow.codeChanged('VLP482');
    f.flow.codeChanged('VLP48');
    f.holdPreview?.complete();
    await _settle();
    expect(f.state, isA<Typing>());
  });

  test('confirm joins and ends Joined with the event ids', () async {
    final f = _Fakes()..joinResult = ['e1', 'e2'];
    f.flow.codeChanged('VLP482');
    await _settle();
    await f.flow.confirm();
    final state = f.state;
    expect(state is Joined ? state.eventIds : null, ['e1', 'e2']);
    expect(f.joined, ['VLP482']);
  });

  test('confirm twice in a row calls join once', () async {
    final f = _Fakes();
    f.holdJoin = Completer<void>();
    f.flow.codeChanged('VLP482');
    await _settle();
    final first = f.flow.confirm();
    expect(f.state, isA<Joining>());
    final second = f.flow.confirm();
    f.holdJoin?.complete();
    await Future.wait([first, second]);
    expect(f.joined, hasLength(1));
    expect(f.state, isA<Joined>());
  });

  test('confirm does nothing before the code is Found', () async {
    final f = _Fakes();
    await f.flow.confirm();
    f.flow.codeChanged('VLP48');
    await f.flow.confirm();
    expect(f.joined, isEmpty);
    expect(f.state, isA<Typing>());
  });

  test(
    'a network error on join is a Problem, and editing the code frees the button',
    () async {
      final f = _Fakes();
      f.flow.codeChanged('VLP482');
      await _settle();
      f.joinFailure = FirebaseFunctionsException(
        message: 'offline',
        code: 'unavailable',
      );
      await f.flow.confirm();
      expect(f.problemText, 'Nu a mers. Verifică internetul.');

      f.flow.codeChanged('VLP48');
      f.flow.codeChanged('VLP482');
      await _settle();
      expect(f.state, isA<Found>());
    },
  );

  test('a network error while looking up is a Problem too', () async {
    final f =
        _Fakes()
          ..previewFailure = FirebaseFunctionsException(
            message: 'offline',
            code: 'unavailable',
          );
    f.flow.codeChanged('VLP482');
    await _settle();
    expect(f.problemText, 'Nu a mers. Verifică internetul.');
  });

  test('a server refusal on join shows its text', () async {
    final f = _Fakes();
    f.flow.codeChanged('VLP482');
    await _settle();
    f.joinFailure = _failure('alreadyMember');
    await f.flow.confirm();
    expect(f.problemText, 'Ești deja în echipă');
  });

  test('a full team is a Problem and join is not called', () async {
    final f = _Fakes()..result = _preview(count: 4, size: 4);
    f.flow.codeChanged('VLP482');
    await _settle();
    await f.flow.confirm();
    expect(f.problemText, 'Echipa e completă');
    expect(f.joined, isEmpty);
  });

  test('editing the code while Joining is ignored', () async {
    final f = _Fakes();
    f.holdJoin = Completer<void>();
    f.flow.codeChanged('VLP482');
    await _settle();
    final joining = f.flow.confirm();
    expect(f.state, isA<Joining>());

    f.flow.codeChanged('VLP48');
    f.flow.codeChanged('ABC123');
    expect(f.state, isA<Joining>());
    expect(f.previewed, ['VLP482']);

    f.holdJoin?.complete();
    await joining;
    expect(f.state, isA<Joined>());
    expect(f.joined, ['VLP482']);
  });

  test(
    'a preview that says already a member is a Problem, not Found',
    () async {
      final f = _Fakes();
      f.result = const InvitePreview(
        crewId: 'c1',
        crewName: 'Vulpile',
        captainName: 'Victor',
        members: [],
        alreadyMember: true,
      );
      f.flow.codeChanged('VLP482');
      await _settle();
      expect(f.problemText, 'Ești deja în echipă');
    },
  );

  test(
    'answers that arrive out of order: only the last complete code counts',
    () async {
      final first = Completer<InvitePreview>();
      final second = Completer<InvitePreview>();
      final answers = {'VLP482': first, 'ABC123': second};
      final flow = JoinFlow(
        preview: (code) => answers[code]!.future,
        join: (code) async => ['e1'],
      );

      flow.codeChanged('VLP482');
      flow.codeChanged('ABC123');
      second.complete(_preview());
      await _settle();
      expect(flow.state.value, isA<Found>());

      first.completeError(_failure('codeUnknown'));
      await _settle();
      expect(flow.state.value, isA<Found>());
    },
  );
}
