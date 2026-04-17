import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors (Eye Intelligence Emerald & Blue)
  static const Color primary = Color(0xFF10B981); // Emerald Green (Matched to Image)
  static const Color accent = Color(0xFF3B82F6); // Premium Blue
  static const Color primaryHover = Color(0xFF059669); // Darker Emerald
  static const Color primaryLight = Color(0xFFD1FAE5); // Light Emerald

  // Light Theme Colors (Premium Clean)
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceVariantLight = Color(0xFFF3F4F6);
  static const Color cardBackgroundLight = Color(0xFFFFFFFF);
  static const Color inputFillLight = Color(0xFFF9FAFB);
  static const Color inputBorderLight = Color(0xFFE5E7EB);
  
  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceVariantDark = Color(0xFF334155);
  static const Color cardBackgroundDark = Color(0xFF1E293B);
  static const Color inputFillDark = Color(0xFF0F172A);
  static const Color inputBorderDark = Color(0xFF334155);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1E293B); // Dark Slate (Matched to Image)
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  
  static const Color textLink = Color(0xFF10B981);
  static const Color textError = Color(0xFFEF4444);

  // Premium Shadows
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get premiumShadow => [
    BoxShadow(
      color: primary.withOpacity(0.08),
      blurRadius: 30,
      offset: const Offset(0, 15),
    ),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundLight,
      cardColor: cardBackgroundLight,
      dividerColor: inputBorderLight,
      disabledColor: textSecondaryLight,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: surfaceLight,
        error: textError,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.light().textTheme,
      ).apply(
        bodyColor: textPrimaryLight,
        displayColor: textPrimaryLight,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundDark,
      cardColor: cardBackgroundDark,
      dividerColor: inputBorderDark,
      disabledColor: textSecondaryDark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surfaceDark,
        error: textError,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textPrimaryDark,
        displayColor: textPrimaryDark,
      ),
    );
  }
}
