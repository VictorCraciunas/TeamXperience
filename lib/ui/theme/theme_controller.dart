import 'package:flutter/material.dart';

import 'theme_mode_store.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._store);

  final ThemeModeStore _store;
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  Future<void> load() async {
    try {
      final stored = await _store.read();
      if (stored != null && stored != _mode) {
        _mode = stored;
        notifyListeners();
      }
    } catch (_) {
      // Keep the default light mode when the stored choice cannot be read.
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    try {
      await _store.write(mode);
    } catch (_) {
      // The choice still applies for this session if saving fails.
    }
  }
}
