import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';
import 'login_screen.dart'; // TechGridPainter

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  // Simulated live data
  final List<Map<String, dynamic>> _liveUsers = [
    {'name': 'Ahmed Hassan', 'room': 'Room A', 'status': 'active', 'device': 'Eye Tracker #1', 'time': '12 min'},
    {'name': 'Sara Mohamed', 'room': 'Room B', 'status': 'idle', 'device': 'Eye Tracker #2', 'time': '3 min'},
    {'name': 'Omar Khalid', 'room': 'Room A', 'status': 'active', 'device': 'Eye Tracker #3', 'time': '27 min'},
    {'name': 'Nour Ali', 'room': 'Room C', 'status': 'active', 'device': 'Eye Tracker #1', 'time': '8 min'},
    {'name': 'Youssef Adel', 'room': 'Room B', 'status': 'offline', 'device': '—', 'time': '—'},
  ];

  final List<Map<String, dynamic>> _emergencyLog = [
    {'user': 'Ahmed Hassan', 'room': 'Room A', 'time': '10:32 AM', 'status': 'resolved'},
    {'user': 'Nour Ali', 'room': 'Room C', 'time': 'Yesterday', 'status': 'resolved'},
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _clockTimer.cancel();
    super.dispose();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to logout from the admin panel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(context, AppRoutes.adminLogin);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background grid
          Positioned.fill(
            child: CustomPaint(
              painter: TechGridPainter(
                color: AppTheme.primary.withOpacity(isDark ? 0.10 : 0.04),
              ),
            ),
          ),
          // Top ambient orb
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accent.withOpacity(isDark ? 0.15 : 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          FadeTransition(
            opacity: _fadeAnim,
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(theme, isDark, size),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatsRow(theme, isDark),
                          const SizedBox(height: 24),
                          _buildSectionTitle('Live Users', Icons.wifi_rounded, AppTheme.primary, theme),
                          const SizedBox(height: 12),
                          _buildLiveUsersTable(theme, isDark),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildSystemStatus(theme, isDark)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildEmergencyLog(theme, isDark)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildSectionTitle('Quick Actions', Icons.flash_on_rounded, AppTheme.accent, theme),
                          const SizedBox(height: 12),
                          _buildQuickActions(theme, isDark),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark, Size size) {
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');
    final s = _now.second.toString().padLeft(2, '0');
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Shield icon + title
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shield_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Eye Intelligence System',
                  style: TextStyle(color: textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          // Live clock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded, color: AppTheme.primary, size: 14),
                const SizedBox(width: 5),
                Text(
                  '$h:$m:$s',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Logout
          GestureDetector(
            onTap: _showLogoutDialog,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme, bool isDark) {
    final stats = [
      {'icon': Icons.people_rounded, 'label': 'Total Users', 'value': '12', 'color': AppTheme.accent},
      {'icon': Icons.circle, 'label': 'Active Now', 'value': '5', 'color': AppTheme.primary},
      {'icon': Icons.meeting_room_rounded, 'label': 'Rooms', 'value': '3', 'color': const Color(0xFF8B5CF6)},
      {'icon': Icons.warning_amber_rounded, 'label': 'SOS Today', 'value': '0', 'color': Colors.orange},
    ];
    return Row(
      children: stats.map((s) {
        final color = s['color'] as Color;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _buildStatCard(
              icon: s['icon'] as IconData,
              label: s['label'] as String,
              value: s['value'] as String,
              color: color,
              theme: theme,
              isDark: isDark,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildLiveUsersTable(ThemeData theme, bool isDark) {
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.07),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('User', style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w700))),
                Expanded(flex: 2, child: Text('Room', style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w700))),
                Expanded(flex: 2, child: Text('Device', style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w700))),
                Expanded(flex: 2, child: Text('Status', style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w700))),
                const Expanded(flex: 2, child: SizedBox()),
              ],
            ),
          ),
          ..._liveUsers.asMap().entries.map((entry) {
            final i = entry.key;
            final user = entry.value;
            final isLast = i == _liveUsers.length - 1;
            final statusColor = user['status'] == 'active'
                ? AppTheme.primary
                : user['status'] == 'idle'
                    ? Colors.amber
                    : Colors.grey;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5))),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.accent.withOpacity(0.15),
                          child: Text(
                            user['name'][0],
                            style: const TextStyle(color: AppTheme.accent, fontSize: 13, fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            user['name'],
                            style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(user['room'], style: TextStyle(color: textSecondary, fontSize: 12)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(user['device'], style: TextStyle(color: textSecondary, fontSize: 12)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          user['status'][0].toUpperCase() + user['status'].substring(1),
                          style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _smallActionBtn(Icons.visibility_rounded, AppTheme.accent, () {}),
                        const SizedBox(width: 6),
                        _smallActionBtn(Icons.chat_bubble_outline_rounded, AppTheme.primary, () {}),
                      ],
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

  Widget _smallActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 15),
      ),
    );
  }

  Widget _buildSystemStatus(ThemeData theme, bool isDark) {
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final systems = [
      {'name': 'Backend API', 'status': true},
      {'name': 'AI Module', 'status': true},
      {'name': 'Eye Tracking', 'status': true},
      {'name': 'WebSocket', 'status': false},
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accent.withOpacity(0.15)),
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
            final online = sys['status'] as bool;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: online ? AppTheme.primary : Colors.redAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (online ? AppTheme.primary : Colors.redAccent).withOpacity(0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      sys['name'] as String,
                      style: TextStyle(
                        color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    online ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: online ? AppTheme.primary : Colors.redAccent,
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

  Widget _buildEmergencyLog(ThemeData theme, bool isDark) {
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
              const SizedBox(width: 8),
              Text('Emergency Log', style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 14),
          ..._emergencyLog.map((log) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sos_rounded, color: Colors.orange, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(log['user'] as String,
                                style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                            Text('${log['room']} · ${log['time']}',
                                style: TextStyle(color: textSecondary, fontSize: 11)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Resolved',
                            style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme, bool isDark) {
    final actions = [
      {'icon': Icons.person_add_rounded, 'label': 'Add User', 'color': AppTheme.accent},
      {'icon': Icons.bar_chart_rounded, 'label': 'Reports', 'color': AppTheme.primary},
      {'icon': Icons.settings_rounded, 'label': 'Settings', 'color': const Color(0xFF8B5CF6)},
      {'icon': Icons.download_rounded, 'label': 'Export Data', 'color': Colors.orange},
      {'icon': Icons.meeting_room_rounded, 'label': 'Manage Rooms', 'color': AppTheme.primary},
      {'icon': Icons.devices_rounded, 'label': 'Devices', 'color': AppTheme.accent},
    ];
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: actions.map((a) {
        final color = a['color'] as Color;
        return GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${a['label']} — Coming soon'),
                backgroundColor: color,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                  child: Icon(a['icon'] as IconData, color: color, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  a['label'] as String,
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
