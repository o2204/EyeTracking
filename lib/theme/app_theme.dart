import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceVariant = Color(0xFF1C2128);
  static const Color cardBackground = Color(0xFF161B22);
  static const Color inputFill = Color(0xFF0D1117);
  static const Color inputBorder = Color(0xFF30363D);
  static const Color inputBorderFocus = Color(0xFF4A8CFF);

  static const Color primary = Color(0xFF4A8CFF);
  static const Color primaryHover = Color(0xFF3B7AFF);
  static const Color primaryLight = Color(0xFF6BA3FF);

  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF6E7681);
  static const Color textLink = Color(0xFF4A8CFF);
  static const Color textError = Color(0xFFFF6B6B);

  static const Color divider = Color(0xFF21262D);
  static const Color shadow = Color(0xFF010409);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        surface: surface,
        error: textError,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
    );
  }
}
