import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AuthCard extends StatelessWidget {
  final Widget child;

  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.inputBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadow.withOpacity(0.6),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.04),
            blurRadius: 80,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
      child: child,
    );
  }
}
