import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/service/location_filter.dart';

/// A reading: a name to tell them apart and its accuracy in metres.
typedef Fix = ({String name, double accuracy});

void main() {
  final t0 = DateTime(2026, 11, 16, 12);
  DateTime at(int seconds) => t0.add(Duration(seconds: seconds));

  group('LocationFilter', () {
    test('the first reading is always shown, however poor', () {
      final filter = LocationFilter<String>();
      expect(filter.offer('first', 120, at(0)), 'first');
    });

    test('keeps good readings', () {
      final filter = LocationFilter<String>();
      expect(filter.offer('a', 8, at(0)), 'a');
      expect(filter.offer('b', 30, at(1)), 'b');
      expect(filter.offer('c', 12, at(2)), 'c');
    });

    test('drops a poor reading while a better one is recent', () {
      final filter = LocationFilter<String>();
      filter.offer('good', 6, at(0));
      expect(filter.offer('bad', 45, at(2)), isNull);
      expect(filter.offer('worse', 80, at(5)), isNull);
      expect(filter.offer('good again', 10, at(6)), 'good again');
    });

    test('a good reading clears what was held', () {
      final filter = LocationFilter<String>();
      filter.offer('good', 6, at(0));
      filter.offer('bad', 45, at(2));
      filter.offer('good again', 10, at(4));
      expect(filter.dueAt, isNull);
      expect(filter.due(at(30)), isNull);
    });

    test('shows a poor reading that is no worse than the one shown', () {
      final filter = LocationFilter<String>();
      filter.offer('first', 90, at(0));
      expect(filter.offer('better', 50, at(1)), 'better');
      expect(filter.offer('worse', 70, at(2)), isNull);
    });

    test('after the wait, the best of the poor readings is shown', () {
      final filter = LocationFilter<String>();
      filter.offer('good', 6, at(0));
      expect(filter.offer('bad 60', 60, at(3)), isNull);
      expect(filter.offer('bad 40', 40, at(6)), isNull);
      expect(filter.offer('bad 90', 90, at(10)), 'bad 40');
    });

    test('due gives the best held reading once the wait has passed', () {
      final filter = LocationFilter<String>();
      filter.offer('good', 6, at(0));
      filter.offer('bad 50', 50, at(2));
      filter.offer('bad 35', 35, at(4));
      expect(filter.dueAt, at(10));
      expect(filter.due(at(9)), isNull);
      expect(filter.due(at(10)), 'bad 35');
      expect(filter.dueAt, isNull);
    });

    test('the wait starts again from the reading shown last', () {
      final filter = LocationFilter<String>();
      filter.offer('good', 6, at(0));
      filter.offer('bad', 50, at(2));
      expect(filter.due(at(10)), 'bad');
      expect(filter.offer('worse', 70, at(12)), isNull);
      expect(filter.dueAt, at(20));
    });

    test('a reading without an accuracy (0) is shown, as before', () {
      final filter = LocationFilter<String>();
      filter.offer('good', 6, at(0));
      expect(filter.offer('unknown', 0, at(1)), 'unknown');
    });
  });

  group('filterFixes', () {
    test('passes good readings, drops poor ones and shows the best after the wait', () {
      fakeAsync((async) {
        final source = StreamController<Fix>();
        final shown = <String>[];
        filterFixes<Fix>(
          source.stream,
          accuracyOf: (fix) => fix.accuracy,
          now: () => t0.add(async.elapsed),
        ).listen((fix) => shown.add(fix.name));

        source.add((name: 'first', accuracy: 8));
        async.elapse(const Duration(seconds: 2));
        source.add((name: 'bad 60', accuracy: 60));
        async.elapse(const Duration(seconds: 2));
        source.add((name: 'bad 40', accuracy: 40));
        async.flushMicrotasks();
        expect(shown, ['first']);

        // Nothing better arrives: at 10 s the best poor one is shown.
        async.elapse(const Duration(seconds: 6));
        expect(shown, ['first', 'bad 40']);

        source.add((name: 'good', accuracy: 5));
        async.flushMicrotasks();
        expect(shown, ['first', 'bad 40', 'good']);
        source.close();
      });
    });

    test('forwards errors and stops its timer when cancelled', () {
      fakeAsync((async) {
        final source = StreamController<Fix>();
        final errors = <Object>[];
        final shown = <String>[];
        final sub = filterFixes<Fix>(
          source.stream,
          accuracyOf: (fix) => fix.accuracy,
          now: () => t0.add(async.elapsed),
        ).listen((fix) => shown.add(fix.name), onError: errors.add);

        source.add((name: 'first', accuracy: 8));
        source.add((name: 'bad', accuracy: 60));
        source.addError('location off');
        async.flushMicrotasks();
        expect(errors, ['location off']);

        sub.cancel();
        async.elapse(const Duration(seconds: 20));
        expect(shown, ['first']);
        expect(source.hasListener, isFalse);
      });
    });
  });
}
