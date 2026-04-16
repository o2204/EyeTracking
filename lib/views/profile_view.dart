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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileHeader(theme),
              const SizedBox(height: 40),
              _buildProfileOptions(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.primaryColor.withOpacity(0.1),
            border: Border.all(
              color: theme.primaryColor.withOpacity(0.3),
              width: 3,
            ),
          ),
          child: Icon(Icons.person, size: 60, color: theme.primaryColor),
        ),
        const SizedBox(height: 20),
        Text(
          'Omar Atef',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'EyeIntelligent@Omar.com',
          style: TextStyle(fontSize: 16, color: theme.disabledColor),
        ),
      ],
    );
  }

  Widget _buildProfileOptions(ThemeData theme) {
    return Column(
      children: [
        _buildProfileItem(
          theme,
          Icons.person_outline,
          'Edit Profile',
          Icons.arrow_forward_ios,
          () {},
        ),
        _buildProfileItem(
          theme,
          Icons.notifications_outlined,
          'Notifications',
          Icons.arrow_forward_ios,
          () {},
        ),
        _buildProfileItem(
          theme,
          Icons.security_outlined,
          'Privacy & Security',
          Icons.arrow_forward_ios,
          () {},
        ),
        _buildProfileItem(
          theme,
          isDarkMode ? Icons.light_mode : Icons.dark_mode,
          'Dark Mode',
          Switch(
            value: isDarkMode,
            onChanged: onDarkModeToggle,
            activeColor: AppColors.success,
          ),
          () {},
        ),
        _buildProfileItem(
          theme,
          Icons.help_outline,
          'Help & Support',
          Icons.arrow_forward_ios,
          () {},
        ),
        _buildProfileItem(
          theme,
          Icons.info_outline,
          'About App',
          Icons.arrow_forward_ios,
          () {},
        ),
        _buildProfileItem(
          theme,
          Icons.logout,
          'Logout',
          null,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isLogout
                ? Colors.red.withOpacity(0.1)
                : theme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isLogout ? Colors.red : theme.primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isLogout ? Colors.red : theme.primaryColor,
          ),
        ),
        trailing: trailing is Widget
            ? trailing
            : Icon(
                Icons.arrow_forward_ios,
                color: theme.disabledColor,
                size: 16,
              ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        tileColor: theme.cardColor,
      ),
    );
  }
}
