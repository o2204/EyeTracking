import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'isDarkMode';

  /// Loads the saved theme mode from SharedPreferences.
  /// Returns ThemeMode.dark if saved as dark or default. Returns ThemeMode.light otherwise.
  static Future<ThemeMode> getSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? true;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  /// Saves the specified ThemeMode to SharedPreferences.
  static Future<void> saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, mode == ThemeMode.dark);
  }
}
