import 'package:app/src/core/storage/prefs.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

part 'theme_controller.g.dart';

/// User-selected app-wide [ThemeMode], persisted to [SharedPreferences].
///
/// Reads/writes go through [PrefsKeys.themeMode]. Default is
/// [ThemeMode.system].
@riverpod
class ThemeController extends _$ThemeController {
  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getString(PrefsKeys.themeMode);
    return _decode(stored);
  }

  Future<void> set(ThemeMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(PrefsKeys.themeMode, _encode(mode));
    state = mode;
  }

  Future<void> toggle() async {
    final next = switch (state) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };
    await set(next);
  }

  static String _encode(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };

  static ThemeMode _decode(String? raw) => switch (raw) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}
