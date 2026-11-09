import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:teamxperience/model/memory.dart';

/// The list of all the player's memories.
class MemoriesController extends ChangeNotifier {
  MemoriesController({required Stream<List<Memory>> stream}) {
    _watch = stream.listen((value) {
      _memories = value;
      _loading = false;
      _failed = false;
      notifyListeners();
    }, onError: (Object _) {
      _loading = false;
      _failed = true;
      notifyListeners();
    });
  }

  late final StreamSubscription<List<Memory>> _watch;
  List<Memory> _memories = const [];
  bool _loading = true;
  bool _failed = false;

  List<Memory> get memories => _memories;
  bool get loading => _loading;
  bool get failed => _failed;

  @override
  void dispose() {
    _watch.cancel();
    super.dispose();
  }
}
