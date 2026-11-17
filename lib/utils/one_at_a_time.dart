/// Runs a task one at a time: a call while one is running is ignored (a
/// double tap on "Deconectare", say).
class OneAtATime {
  bool _running = false;

  bool get running => _running;

  Future<void> run(Future<void> Function() task) async {
    if (_running) return;
    _running = true;
    try {
      await task();
    } finally {
      _running = false;
    }
  }
}
