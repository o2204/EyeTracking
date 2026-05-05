import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF00C897); // Primary Accent (Glow)
  static const Color accent = Color(0xFF8C2A0A); // Secondary Accent (Subtle Warm)
  static const Color primaryHover = Color(0xFF00A67E); 
  
  // Background & Surface
  static const Color backgroundPrimary = Color(0xFF0A0F1C);
  static const Color backgroundSecondary = Color(0xFF121A2C);
  static const Color cardBackground = Color(0xFF111827);
  static const Color inputFill = Color(0xFF0A0F1C);
  static const Color inputBorder = Color(0xFF1F2937);

  // Text Colors
  static const Color textPrimary = Color(0xFFE5E7EB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textError = Color(0xFFEF4444);
  static const Color textLink = primary;

  // Legacy Aliases (Enforces Dark Theme globally across older screens without breaking)
  static const Color backgroundDark = backgroundPrimary;
  static const Color backgroundLight = backgroundPrimary;
  static const Color cardBackgroundDark = cardBackground;
  static const Color cardBackgroundLight = cardBackground;
  static const Color inputFillDark = inputFill;
  static const Color inputFillLight = inputFill;
  static const Color inputBorderDark = inputBorder;
  static const Color inputBorderLight = inputBorder;
  static const Color textPrimaryDark = textPrimary;
  static const Color textPrimaryLight = textPrimary;
  static const Color textSecondaryDark = textSecondary;
  static const Color textSecondaryLight = textSecondary;

  // Shadows
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get premiumShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.15),
      blurRadius: 30,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get cardGlow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.08),
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];

  // Gradients
  static const LinearGradient globalBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      backgroundPrimary,
      backgroundSecondary,
    ],
  );

  static const LinearGradient darkBackgroundGradient = globalBackgroundGradient;
  static const LinearGradient lightBackgroundGradient = globalBackgroundGradient;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundPrimary,
      cardColor: cardBackground,
      dividerColor: inputBorder,
      disabledColor: textSecondary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: cardBackground,
        error: textError,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
    );
  }

  // To prevent light mode issues, enforce dark theme even if requested
  static ThemeData get lightTheme => darkTheme;
}
