import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/dashboard_models.dart';

class QuickActionsSection extends StatelessWidget {
  final List<QuickActionModel> actions;
  final ThemeData theme;
  final bool isDark;

  final Function(String) onAction;

  const QuickActionsSection({
    super.key,
    required this.actions,
    required this.theme,
    required this.isDark,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: actions.map((a) {
        return GestureDetector(
          onTap: () => onAction(a.label),
          child: Container(
            width: 100, // Fixed width for wrap children to behave like a responsive grid
            height: 100,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: a.color.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(color: a.color.withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: a.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: Icon(a.icon, color: a.color, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  a.label,
                  style: TextStyle(color: textPrimary, fontSize: 11, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
