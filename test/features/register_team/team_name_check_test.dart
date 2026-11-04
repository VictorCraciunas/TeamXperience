import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/register_team/logic/team_name_check.dart';
import 'package:teamxperience/ui/components/feedback/field_status_line.dart';

const _debounce = Duration(milliseconds: 400);

void main() {
  late List<String> asked;
  late Future<bool?> Function(String) isFree;

  TeamNameCheck check() => TeamNameCheck(isFree: (name) => isFree(name));

  setUp(() {
    asked = [];
    isFree = (name) async {
      asked.add(name);
      return true;
    };
  });

  test(
    'typing three times inside the debounce asks once, for the last name',
    () {
      fakeAsync((async) {
        final c = check();
        c.onChanged('Vu');
        async.elapse(const Duration(milliseconds: 100));
        c.onChanged('Vul');
        async.elapse(const Duration(milliseconds: 100));
        c.onChanged('Vulpile');
        async.elapse(_debounce);
        async.flushMicrotasks();
        expect(asked, ['Vulpile']);
        c.dispose();
      });
    },
  );

  test('an empty name is neutral with no text', () {
    fakeAsync((async) {
      final c = check();
      c.onChanged('   ');
      expect(c.state.value, (FieldStatus.neutral, ''));
      async.elapse(_debounce);
      expect(asked, isEmpty);
      c.dispose();
    });
  });

  test('a local problem shows at once and never asks', () {
    fakeAsync((async) {
      final c = check();
      c.onChanged('A');
      expect(c.state.value, (
        FieldStatus.problem,
        'Numele are 2–30 de litere, fără /',
      ));
      c.onChanged('A/B');
      expect(c.state.value, (
        FieldStatus.problem,
        'Numele are 2–30 de litere, fără /',
      ));
      async.elapse(_debounce);
      async.flushMicrotasks();
      expect(asked, isEmpty);
      c.dispose();
    });
  });

  test('checking, then free', () {
    fakeAsync((async) {
      final c = check();
      c.onChanged('Vulpile');
      expect(c.state.value, (FieldStatus.checking, 'Verificăm numele…'));
      async.elapse(_debounce);
      async.flushMicrotasks();
      expect(c.state.value, (FieldStatus.ok, 'Numele e liber'));
      c.dispose();
    });
  });

  test('taken', () {
    fakeAsync((async) {
      isFree = (_) async => false;
      final c = check();
      c.onChanged('Vulpile');
      async.elapse(_debounce);
      async.flushMicrotasks();
      expect(c.state.value, (FieldStatus.problem, 'Numele e luat'));
      c.dispose();
    });
  });

  test('no network answer is neutral', () {
    fakeAsync((async) {
      isFree = (_) async => null;
      final c = check();
      c.onChanged('Vulpile');
      async.elapse(_debounce);
      async.flushMicrotasks();
      expect(c.state.value, (
        FieldStatus.neutral,
        'Nu am putut verifica numele',
      ));
      c.dispose();
    });
  });

  test('the name is cleaned before it is asked', () {
    fakeAsync((async) {
      final c = check();
      c.onChanged('  Lupii   de  Cetate ');
      async.elapse(_debounce);
      async.flushMicrotasks();
      expect(asked, ['Lupii de Cetate']);
      c.dispose();
    });
  });

  test('an earlier answer that arrives after a later one is ignored', () {
    fakeAsync((async) {
      final answers = <String, Completer<bool?>>{};
      isFree = (name) => (answers[name] = Completer<bool?>()).future;
      final c = check();

      c.onChanged('Vulpile');
      async.elapse(_debounce);
      c.onChanged('Vulpile2');
      async.elapse(_debounce);
      expect(answers.keys, ['Vulpile', 'Vulpile2']);

      answers['Vulpile2']?.complete(true);
      async.flushMicrotasks();
      expect(c.state.value, (FieldStatus.ok, 'Numele e liber'));

      answers['Vulpile']?.complete(false);
      async.flushMicrotasks();
      expect(c.state.value, (FieldStatus.ok, 'Numele e liber'));
      c.dispose();
    });
  });

  test('an answer for a name that was since emptied is ignored', () {
    fakeAsync((async) {
      final answer = Completer<bool?>();
      isFree = (_) => answer.future;
      final c = check();
      c.onChanged('Vulpile');
      async.elapse(_debounce);
      c.onChanged('');
      answer.complete(false);
      async.flushMicrotasks();
      expect(c.state.value, (FieldStatus.neutral, ''));
      c.dispose();
    });
  });

  test('an answer after dispose does not throw', () {
    fakeAsync((async) {
      final answer = Completer<bool?>();
      isFree = (_) => answer.future;
      final c = check();
      c.onChanged('Vulpile');
      async.elapse(_debounce);
      c.dispose();
      answer.complete(true);
      async.flushMicrotasks();
    });
  });

  test('markTaken shows the name as taken and drops a pending answer', () {
    fakeAsync((async) {
      final answer = Completer<bool?>();
      isFree = (_) => answer.future;
      final c = check();
      c.onChanged('Vulpile');
      async.elapse(_debounce);
      c.markTaken();
      expect(c.state.value, (FieldStatus.problem, 'Numele e luat'));
      answer.complete(true);
      async.flushMicrotasks();
      expect(c.state.value, (FieldStatus.problem, 'Numele e luat'));
      c.dispose();
    });
  });

  test('an isFree that throws is treated like no network answer', () {
    fakeAsync((async) {
      isFree = (_) async => throw StateError('callable missing');
      final c = check();
      c.onChanged('Vulpile');
      async.elapse(_debounce);
      async.flushMicrotasks();
      expect(c.state.value, (
        FieldStatus.neutral,
        'Nu am putut verifica numele',
      ));
      c.dispose();
    });
  });

  test('a throw from an earlier call is ignored after a later one', () {
    fakeAsync((async) {
      final answers = <String, Completer<bool?>>{};
      isFree = (name) => (answers[name] = Completer<bool?>()).future;
      final c = check();

      c.onChanged('Vulpile');
      async.elapse(_debounce);
      c.onChanged('Vulpile2');
      async.elapse(_debounce);

      answers['Vulpile2']?.complete(true);
      async.flushMicrotasks();
      answers['Vulpile']?.completeError(StateError('late failure'));
      async.flushMicrotasks();
      expect(c.state.value, (FieldStatus.ok, 'Numele e liber'));
      c.dispose();
    });
  });

  test('a throw after dispose does not throw', () {
    fakeAsync((async) {
      final answer = Completer<bool?>();
      isFree = (_) => answer.future;
      final c = check();
      c.onChanged('Vulpile');
      async.elapse(_debounce);
      c.dispose();
      answer.completeError(StateError('late failure'));
      async.flushMicrotasks();
    });
  });
}
