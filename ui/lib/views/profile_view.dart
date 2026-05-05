import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileView extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeToggle;

  const ProfileView({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.globalBackgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              children: [
                _buildProfileHeader(theme),
                const SizedBox(height: 45),
                _buildProfileOptions(context, theme), 
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildProfileHeader(ThemeData theme) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withValues(alpha: 0.15),
                  AppTheme.primary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.4),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  blurRadius: 50,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(Icons.person_rounded, size: 65, color: AppTheme.primary),
          ),
          const SizedBox(height: 24),
          Text(
            'Omar Atef',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              'EyeIntelligent@Omar.com',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.disabledColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= OPTIONS =================
  Widget _buildProfileOptions(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      children: [
        _buildProfileItem(
          theme, isDark,
          Icons.person_outline_rounded,
          'Edit Profile',
          null,
          () => Navigator.pushNamed(context, '/edit-profile'),
          0,
        ),
        _buildProfileItem(
          theme, isDark,
          Icons.notifications_outlined,
          'Notifications',
          null,
          () => Navigator.pushNamed(context, '/notifications'),
          1,
        ),
        _buildProfileItem(
          theme, isDark,
          Icons.security_outlined,
          'Privacy & Security',
          null,
          () => Navigator.pushNamed(context, '/privacy-security'),
          2,
        ),
        _buildProfileItem(
          theme, isDark,
          isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          'Dark Mode',
          Switch(
            value: isDarkMode,
            onChanged: onDarkModeToggle,
            activeThumbColor: Colors.white,
            activeTrackColor: AppTheme.primary,
            inactiveThumbColor: AppTheme.textSecondary,
            inactiveTrackColor: Colors.transparent,
          ),
          () {}, // مفيش navigation
          3,
        ),
        _buildProfileItem(
          theme, isDark,
          Icons.help_outline_rounded,
          'Help & Support',
          null,
          () => Navigator.pushNamed(context, '/help-support'),
          4,
        ),
        _buildProfileItem(
          theme, isDark,
          Icons.info_outline_rounded,
          'About App',
          null,
          () => Navigator.pushNamed(context, '/about'),
          5,
        ),
        _buildProfileItem(
          theme, isDark,
          Icons.logout_rounded,
          'Logout',
          const SizedBox(),
          () => _showLogoutDialog(context),
          6,
          isLogout: true,
        ),
      ],
    );
  }

  // ================= ITEM =================
  Widget _buildProfileItem(
    ThemeData theme,
    bool isDark,
    IconData icon,
    String title,
    dynamic trailing,
    VoidCallback onTap,
    int index, {
    bool isLogout = false,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + (index * 60)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isLogout
                  ? Colors.red.withValues(alpha: 0.15)
                  : AppTheme.primary.withValues(alpha: isDark ? 0.08 : 0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isLogout
                    ? Colors.red.withValues(alpha: 0.05)
                    : AppTheme.primary.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              splashColor: isLogout
                  ? Colors.red.withValues(alpha: 0.1)
                  : AppTheme.primary.withValues(alpha: 0.1),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isLogout
                            ? Colors.red.withValues(alpha: 0.1)
                            : AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: isLogout ? Colors.red : AppTheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isLogout
                              ? Colors.red
                              : theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    trailing is Widget
                        ? trailing
                        : Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppTheme.primary.withValues(alpha: 0.4),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= LOGOUT =================
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondaryDark)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}