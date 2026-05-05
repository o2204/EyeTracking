import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AuthCard extends StatelessWidget {
  final Widget child;

  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark
                ? theme.cardColor.withValues(alpha: 0.65)
                : Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? AppTheme.primary.withValues(alpha: 0.12)
                  : AppTheme.primary.withValues(alpha: 0.18),
              width: 1.5,
            ),
            boxShadow: [
              // Core shadow
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.45)
                    : AppTheme.primary.withValues(alpha: 0.06),
                blurRadius: 40,
                spreadRadius: -5,
                offset: const Offset(0, 12),
              ),
              // Subtle green glow
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: isDark ? 0.06 : 0.04),
                blurRadius: 60,
                spreadRadius: 0,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: child,
        ),
      ),
    );
  }
}
