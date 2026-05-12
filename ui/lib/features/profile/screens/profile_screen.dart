import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../widgets/profile_menu_item.dart';
import '../../../main.dart';
import '../../../services/theme_service.dart';
import '../../../services/user_service.dart';
import '../../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'User';
  String _userEmail = 'email@example.com';
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final userData = await _userService.getCurrentUser();
    if (userData != null && mounted) {
      setState(() {
        _userName = userData['name'] ?? 'User';
        _userEmail = userData['email'] ?? 'email@example.com';
      });
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await AuthService().logout();
              if (mounted) {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.login, (route) => false);
              }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.darkBackgroundGradient
              : AppTheme.lightBackgroundGradient,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // User Info Card
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.cardColor.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                          child: const Icon(Icons.person, size: 40, color: AppTheme.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _userEmail,
                                style: TextStyle(
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Menu Items
                ProfileMenuItem(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () async {
                    final result = await Navigator.pushNamed(
                        context, AppRoutes.editProfile);
                    if (result == true) {
                      _fetchUserData();
                    }
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.notifications_none,
                  title: 'Notifications',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primary.withValues(alpha: 0.4)),
                ),
                ProfileMenuItem(
                  icon: Icons.security,
                  title: 'Privacy & Security',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.privacySecurity),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primary.withValues(alpha: 0.4)),
                ),
                
                // Dark Mode Toggle
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: themeModeNotifier,
                  builder: (context, themeMode, _) {
                    final isDarkMode = themeMode == ThemeMode.dark;
                    return ProfileMenuItem(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      trailing: Switch(
                        value: isDarkMode,
                        activeThumbColor: AppTheme.primary,
                        activeTrackColor: AppTheme.primary.withValues(alpha: 0.3),
                        onChanged: (val) {
                          final newMode = val ? ThemeMode.dark : ThemeMode.light;
                          themeModeNotifier.value = newMode;
                          ThemeService.saveTheme(newMode);
                        },
                      ),
                      onTap: () {},
                    );
                  },
                ),
                
                ProfileMenuItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.helpSupport),
                ),
                ProfileMenuItem(
                  icon: Icons.info_outline,
                  title: 'About App',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.about),
                ),
                
                const SizedBox(height: 16),
                ProfileMenuItem(
                  icon: Icons.logout,
                  title: 'Log Out',
                  isDestructive: true,
                  trailing: const SizedBox.shrink(),
                  onTap: _logout,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
