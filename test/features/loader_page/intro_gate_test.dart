import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/loader_page/logic/intro_gate.dart';

void main() {
  test('opens when the intro ends', () {
    fakeAsync((time) {
      final intro = Completer<void>();
      var open = false;
      introGate(intro.future).then((_) => open = true);
      time.elapse(const Duration(seconds: 1));
      expect(open, isFalse);
      intro.complete();
      time.flushMicrotasks();
      expect(open, isTrue);
    });
  });

  test('opens anyway when the animation never plays', () {
    fakeAsync((time) {
      var open = false;
      introGate(Completer<void>().future).then((_) => open = true);
      time.elapse(introGateMax - const Duration(milliseconds: 1));
      expect(open, isFalse);
      time.elapse(const Duration(milliseconds: 2));
      expect(open, isTrue);
    });
  });
}
