import 'dart:async';

/// Leaves out poor position readings without ever getting stuck.
///
/// A reading's accuracy is in metres (smaller is better). A reading is shown
/// when it is the first one, at most [worstAccuracy], no worse than the one
/// shown last, or without an accuracy (0, as some platforms report). Any other
/// reading is held back; if nothing better comes within [patience] of the
/// reading shown last, the best of the held ones is shown.
class LocationFilter<T extends Object> {
  LocationFilter({this.worstAccuracy = 30, this.patience = const Duration(seconds: 10)});

  final double worstAccuracy;
  final Duration patience;

  DateTime? _shownAt;
  double? _shownAccuracy;
  T? _held;
  double _heldAccuracy = double.infinity;

  /// The reading to show now ([reading], or a held one that fell due), or
  /// null to skip it.
  T? offer(T reading, double accuracy, DateTime now) {
    if (_keeps(accuracy)) return _show(reading, accuracy, now);
    if (_held == null || accuracy < _heldAccuracy) {
      _held = reading;
      _heldAccuracy = accuracy;
    }
    return due(now);
  }

  /// When the held reading will be shown if nothing better comes; null when
  /// none is held.
  DateTime? get dueAt {
    final shownAt = _shownAt;
    if (_held == null || shownAt == null) return null;
    return shownAt.add(patience);
  }

  /// The best held reading once [patience] has passed since the reading shown
  /// last; otherwise null.
  T? due(DateTime now) {
    final held = _held;
    final at = dueAt;
    if (held == null || at == null || now.isBefore(at)) return null;
    return _show(held, _heldAccuracy, now);
  }

  bool _keeps(double accuracy) {
    final shownAccuracy = _shownAccuracy;
    if (shownAccuracy == null) return true;
    if (!(accuracy > 0)) return true;
    return accuracy <= worstAccuracy || accuracy <= shownAccuracy;
  }

  T _show(T reading, double accuracy, DateTime now) {
    _shownAt = now;
    _shownAccuracy = accuracy > 0 ? accuracy : 0;
    _held = null;
    _heldAccuracy = double.infinity;
    return reading;
  }
}

/// [source] through a [LocationFilter]: poor readings are left out, and a
/// held one is shown when its wait runs out even if no reading follows it.
/// Errors pass through; cancelling stops [source] and the timer.
Stream<T> filterFixes<T extends Object>(
  Stream<T> source, {
  required double Function(T reading) accuracyOf,
  LocationFilter<T>? filter,
  DateTime Function() now = DateTime.now,
}) {
  final keep = filter ?? LocationFilter<T>();
  final out = StreamController<T>();
  StreamSubscription<T>? subscription;
  Timer? timer;

  void schedule() {
    timer?.cancel();
    timer = null;
    final at = keep.dueAt;
    if (at == null) return;
    final wait = at.difference(now());
    timer = Timer(wait.isNegative ? Duration.zero : wait, () {
      final reading = keep.due(now());
      if (reading != null) out.add(reading);
      schedule();
    });
  }

  out.onListen = () {
    subscription = source.listen(
      (reading) {
        final shown = keep.offer(reading, accuracyOf(reading), now());
        if (shown != null) out.add(shown);
        schedule();
      },
      onError: out.addError,
      onDone: () {
        timer?.cancel();
        out.close();
      },
    );
  };
  out.onPause = () => subscription?.pause();
  out.onResume = () => subscription?.resume();
  out.onCancel = () {
    timer?.cancel();
    return subscription?.cancel();
  };
  return out.stream;
}
