import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);

enum ThemePreference { light, dark }

// Extension to convert `ThemePreference` to `ThemeMode`
extension on ThemePreference {
  ThemeMode toThemeMode() {
    switch (this) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
    }
  }
}

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    state = ThemePreference.values[themeIndex].toThemeMode();
  }

  Future<void> setTheme(ThemePreference preference) async {
    final prefs = await SharedPreferences.getInstance();
    state = preference.toThemeMode();
    await prefs.setInt('themeMode', preference.index);
  }
}
