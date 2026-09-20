import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class ThemeNotifier extends Notifier<AppThemeMode> {
  static const String _key = 'theme_mode';

  @override
  AppThemeMode build() {
    _loadFromPrefs();
    return AppThemeMode.light;
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_key);
      if (saved != null) {
        state = AppThemeMode.values.firstWhere(
          (e) => e.name == saved,
          orElse: () => AppThemeMode.light,
        );
      }
    } catch (_) {}
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.name);
    } catch (_) {}
  }

  ThemeMode get themeMode {
    switch (state) {
      case AppThemeMode.light: return ThemeMode.light;
      case AppThemeMode.dark: return ThemeMode.dark;
      case AppThemeMode.system: return ThemeMode.system;
    }
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, AppThemeMode>(() => ThemeNotifier());
