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
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            children: [
              _buildProfileHeader(theme),
              const SizedBox(height: 45),
              _buildProfileOptions(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    final Color accentBlue = theme.colorScheme.secondary;
    
    return Column(
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [accentBlue.withOpacity(0.15), accentBlue.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: accentBlue.withOpacity(0.4),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: accentBlue.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Icon(Icons.person_rounded, size: 65, color: accentBlue),
        ),
        const SizedBox(height: 24),
        Text(
          'Omar Atef',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.secondary, // explicitly blue
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
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
    );
  }

  Widget _buildProfileOptions(ThemeData theme) {
    return Column(
      children: [
        _buildProfileItem(
          theme,
          Icons.person_outline_rounded,
          'Edit Profile',
          null, // uses default arrow
          () {},
        ),
        _buildProfileItem(
          theme,
          Icons.notifications_outlined,
          'Notifications',
          null,
          () {},
        ),
        _buildProfileItem(
          theme,
          Icons.security_outlined,
          'Privacy & Security',
          null,
          () {},
        ),
        _buildProfileItem(
          theme,
          isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          'Dark Mode',
          Switch(
            value: isDarkMode,
            onChanged: onDarkModeToggle,
            activeColor: AppTheme.accent, // Lime Green toggle as requested
          ),
          () {},
        ),
        _buildProfileItem(
          theme,
          Icons.help_outline_rounded,
          'Help & Support',
          null,
          () {},
        ),
        _buildProfileItem(
          theme,
          Icons.info_outline_rounded,
          'About App',
          null,
          () {},
        ),
        _buildProfileItem(
          theme,
          Icons.logout_rounded,
          'Logout',
          const SizedBox(), // Empty widget so no arrow
          () {},
          isLogout: true,
        ),
      ],
    );
  }

  Widget _buildProfileItem(
    ThemeData theme,
    IconData icon,
    String title,
    dynamic trailing,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    final Color accentBlue = theme.colorScheme.secondary;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
             border: Border.all(
            color: isLogout 
               ? Colors.red.withOpacity(0.15) 
               : accentBlue.withOpacity(0.08),
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            splashColor: isLogout ? Colors.red.withOpacity(0.1) : accentBlue.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isLogout
                           ? [Colors.red.withOpacity(0.15), Colors.red.withOpacity(0.05)]
                           : [accentBlue.withOpacity(0.15), accentBlue.withOpacity(0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: isLogout ? Colors.red : theme.colorScheme.secondary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isLogout ? Colors.red : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  trailing is Widget
                      ? trailing
                      : Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: theme.disabledColor,
                            size: 14,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
