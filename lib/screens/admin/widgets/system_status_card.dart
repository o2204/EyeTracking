import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/dashboard_models.dart';

class SystemStatusCard extends StatelessWidget {
  final List<SystemStatusModel> systems;
  final ThemeData theme;
  final bool isDark;

  const SystemStatusCard({
    super.key,
    required this.systems,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.15)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monitor_heart_rounded, color: AppTheme.accent, size: 18),
              const SizedBox(width: 8),
              Text('System Status', style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 14),
          ...systems.map((sys) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: sys.online ? AppTheme.primary : Colors.redAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (sys.online ? AppTheme.primary : Colors.redAccent).withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      sys.name,
                      style: TextStyle(
                        color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    sys.online ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: sys.online ? AppTheme.primary : Colors.redAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
