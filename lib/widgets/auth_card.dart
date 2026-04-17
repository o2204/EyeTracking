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
                ? theme.cardColor.withOpacity(0.6) 
                : Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : AppTheme.primary.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              // Core shadow
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.4)
                    : AppTheme.primary.withOpacity(0.08),
                blurRadius: 40,
                spreadRadius: -5,
                offset: const Offset(0, 12),
              ),
              // Emerald glow emulation
              if (!isDark)
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.04),
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
