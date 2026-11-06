import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/service/walk_tracker.dart';

// About one metre north per step of this many degrees of latitude.
const _metre = 1 / 111319.49;
final _start = DateTime(2026, 11, 14, 10);

WalkFix _fix(double northMetres, int seconds, {double accuracy = 5}) =>
    WalkFix(lat: 45.79 + northMetres * _metre, lng: 24.15, accuracy: accuracy, at: _start.add(Duration(seconds: seconds)));

void main() {
  test('good fixes 10 m apart add up; the first counts nothing', () {
    final walk = WalkTracker();
    expect(walk.add(_fix(0, 0)), 0);
    for (var i = 1; i <= 3; i++) {
      walk.add(_fix(i * 10.0, i * 10));
    }
    expect(walk.total, closeTo(30, 0.5));
  });

  test('a fix less accurate than 30 m adds nothing and is not the last point', () {
    final walk = WalkTracker()..add(_fix(0, 0));
    expect(walk.add(_fix(40, 20, accuracy: 60)), 0);
    expect(walk.add(_fix(10, 30)), closeTo(10, 0.5));
  });

  test('a jump of 200 m in 2 s adds nothing; the next fix counts from before it', () {
    final walk = WalkTracker()..add(_fix(0, 0));
    expect(walk.add(_fix(200, 2)), 0);
    expect(walk.add(_fix(12, 15)), closeTo(12, 0.5));
  });

  test('60 m in 30 s is a real walk', () {
    final walk = WalkTracker()..add(_fix(0, 0));
    expect(walk.add(_fix(60, 30)), closeTo(60, 0.5));
  });

  test('pending metres go out in steps of at least 20 m, or all at once at the end', () {
    final walk = WalkTracker()..add(_fix(0, 0));
    walk.add(_fix(15, 15));
    expect(walk.takePending(), 0, reason: '15 m stay pending');
    walk.add(_fix(25, 25));
    expect(walk.takePending(), closeTo(25, 0.5));
    expect(walk.takePending(), 0, reason: 'already sent');
    walk.add(_fix(32, 35));
    expect(walk.takePending(atLeast: 0), closeTo(7, 0.5));
  });
}
