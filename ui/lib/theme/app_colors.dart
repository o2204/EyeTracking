import 'package:flutter/material.dart';

/// Central colour palette for the Eye Intelligence app.
/// All screens must import this file instead of defining ad-hoc colours.
class AppColors {
  AppColors._(); // prevent instantiation

  // ── Deep backgrounds ──────────────────────────────────────────────────────
  static const Color bgDeep        = Color(0xFF060E1C);
  static const Color bgMid         = Color(0xFF091524);
  static const Color bgDark        = Color(0xFF050D18);

  // Convenience gradient list used by dashboard & other screens
  static const List<Color> bgGradient = [bgDeep, bgMid, bgDark];

  // ── Glass / card layer ────────────────────────────────────────────────────
  static const Color bgCard        = Color(0xFF0B1A2E);
  static const Color bgGlass       = Color(0xB30E1C32); // ~70% opaque
  static const Color bgGlassBorder = Color(0x1AFFFFFF); // ~10% white

  // ── Accent — Teal (login / primary) ──────────────────────────────────────
  static const Color teal    = Color(0xFF00E5C8);
  static const Color tealDim = Color(0xFF00B89E);
  static const Color tealGlow = Color(0x2E00E5C8);

  // ── Accent — Amber (signup / secondary) ──────────────────────────────────
  static const Color amber    = Color(0xFFF5A623);
  static const Color amberDim = Color(0xFFD4861A);
  static const Color amberGlow = Color(0x2EF5A623);

  static const Color red = Color(0xFFFF4D6A);
  static const Color redGlow = Color(0x2EFF4D6A);
  static const Color blue = Color(0xFF3B8EEA);
  static const Color blueGlow = Color(0x2E3B8EEA);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFE8EEFF);
  static const Color textSecondary = Color(0xFF8A9BB5);
  static const Color textMuted     = Color(0xFF5A6A8A);
}
