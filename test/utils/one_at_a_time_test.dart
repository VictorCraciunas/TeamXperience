import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/utils/one_at_a_time.dart';

void main() {
  test('a second tap while the first runs is ignored', () async {
    final once = OneAtATime();
    final done = Completer<void>();
    var runs = 0;
    Future<void> task() async {
      runs++;
      await done.future;
    }

    final first = once.run(task);
    expect(once.running, isTrue);
    await once.run(task);
    expect(runs, 1);
    done.complete();
    await first;
    expect(once.running, isFalse);
  });

  test('after it ends, it can run again, even after a failure', () async {
    final once = OneAtATime();
    var runs = 0;
    await expectLater(once.run(() async {
      runs++;
      throw StateError('offline');
    }), throwsStateError);
    await once.run(() async => runs++);
    expect(runs, 2);
  });
}
