import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamxperience/ui/theme/theme_controller.dart';
import 'package:teamxperience/ui/theme/theme_mode_store.dart';

class _FakeStore implements ThemeModeStore {
  _FakeStore({this.stored, this.failReads = false, this.failWrites = false});

  ThemeMode? stored;
  final bool failReads;
  final bool failWrites;
  int writes = 0;

  @override
  Future<ThemeMode?> read() async {
    if (failReads) throw Exception('read failed');
    return stored;
  }

  @override
  Future<void> write(ThemeMode mode) async {
    if (failWrites) throw Exception('write failed');
    writes++;
    stored = mode;
  }
}

void main() {
  group('ThemeController', () {
    test('defaults to light before load', () {
      expect(ThemeController(_FakeStore()).mode, ThemeMode.light);
    });

    test('load restores the stored mode', () async {
      final controller = ThemeController(_FakeStore(stored: ThemeMode.dark));
      await controller.load();
      expect(controller.mode, ThemeMode.dark);
    });

    test('load restores system mode', () async {
      final controller = ThemeController(_FakeStore(stored: ThemeMode.system));
      await controller.load();
      expect(controller.mode, ThemeMode.system);
    });

    test('load keeps light when nothing is stored', () async {
      final controller = ThemeController(_FakeStore());
      await controller.load();
      expect(controller.mode, ThemeMode.light);
    });

    test('load keeps light when the store throws', () async {
      final controller = ThemeController(_FakeStore(failReads: true));
      await controller.load();
      expect(controller.mode, ThemeMode.light);
    });

    test('setMode persists and notifies once', () async {
      final store = _FakeStore();
      final controller = ThemeController(store);
      var notifications = 0;
      controller.addListener(() => notifications++);
      await controller.setMode(ThemeMode.dark);
      expect(controller.mode, ThemeMode.dark);
      expect(store.stored, ThemeMode.dark);
      expect(notifications, 1);
    });

    test('setMode to the current mode does nothing', () async {
      final store = _FakeStore();
      final controller = ThemeController(store);
      var notifications = 0;
      controller.addListener(() => notifications++);
      await controller.setMode(ThemeMode.light);
      expect(store.writes, 0);
      expect(notifications, 0);
    });

    test('setMode still updates the mode when writing fails', () async {
      final controller = ThemeController(_FakeStore(failWrites: true));
      var notifications = 0;
      controller.addListener(() => notifications++);
      await controller.setMode(ThemeMode.dark);
      expect(controller.mode, ThemeMode.dark);
      expect(notifications, 1);
    });
  });

  group('SharedPrefsThemeModeStore', () {
    test('reads a stored mode', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
      expect(await SharedPrefsThemeModeStore().read(), ThemeMode.dark);
    });

    test('returns null when nothing is stored', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await SharedPrefsThemeModeStore().read(), isNull);
    });

    test('returns null for an unknown stored value', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'purple'});
      expect(await SharedPrefsThemeModeStore().read(), isNull);
    });

    test('writes the mode so it can be read back', () async {
      SharedPreferences.setMockInitialValues({});
      final store = SharedPrefsThemeModeStore();
      await store.write(ThemeMode.system);
      expect(await store.read(), ThemeMode.system);
    });
  });
}
