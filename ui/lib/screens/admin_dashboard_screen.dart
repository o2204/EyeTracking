import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';
import 'admin_login_screen.dart';

// ────────────────────────────────────────
// Admin Colors
// ────────────────────────────────────────
class AdminColors {
  static const bgDeep = Color(0xFF030B14);
  static const bgDark = Color(0xFF060F1C);
  static const bgMid = Color(0xFF0B1A2E);
  static const bgCard = Color(0xCC0B1A2E);
  static const teal = Color(0xFF00E5B0);
  static const tealDim = Color(0xFF00C498);
  static const tealGlow = Color(0x2E00E5B0);
  static const tealBg = Color(0x1200E5B0);
  static const amber = Color(0xFFF5A623);
  static const red = Color(0xFFFF4D6A);
  static const blue = Color(0xFF3B8EEA);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFF7A8FA8);
  static const textMuted = Color(0xFF3D5068);
  static const glass = Color(0x0AFFFFFF);
  static const glassBorder = Color(0x14FFFFFF);
  static const glassBorderHover = Color(0x4D00E5B0);
}

// ────────────────────────────────────────
// Dashboard Screen (with Drawer)
// ────────────────────────────────────────
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _NavItem {
  final String title;
  final IconData icon;
  final String? badge;
  final Color? badgeColor;
  const _NavItem(this.title, this.icon, {this.badge, this.badgeColor});
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem('Dashboard', Icons.grid_view),
    _NavItem('Rooms', Icons.home_outlined, badge: '12', badgeColor: AdminColors.teal),
    _NavItem('Devices', Icons.devices, badge: '3', badgeColor: AdminColors.red),
    _NavItem('Users', Icons.people_outline),
    _NavItem('Analytics', Icons.timeline),
    _NavItem('Energy', Icons.bolt),
    _NavItem('Security', Icons.shield_outlined),
    _NavItem('Settings', Icons.settings_outlined),
  ];

  final List<Widget> _pages = const [
    _DashboardContent(),
    RoomsScreen(),
    DevicesScreen(),
    UsersScreen(),
    AnalyticsScreen(),
    EnergyScreen(),
    SecurityScreen(),
    SettingsScreen(),
  ];

  void _logout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.adminLogin);
    }
  }

  Widget _buildDrawerItem(_NavItem item, int index) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Material(
        color: isSelected ? AdminColors.tealBg : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            setState(() => _selectedIndex = index);
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: isSelected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AdminColors.teal.withOpacity(0.15)),
                  )
                : null,
            child: Row(
              children: [
                if (isSelected)
                  Container(
                    width: 3,
                    height: 20,
                    margin: const EdgeInsets.only(right: 9),
                    decoration: BoxDecoration(
                      color: AdminColors.teal,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(2),
                        bottomRight: Radius.circular(2),
                      ),
                      boxShadow: [BoxShadow(color: AdminColors.teal.withOpacity(0.5), blurRadius: 8)],
                    ),
                  ),
                Icon(
                  item.icon,
                  size: 16,
                  color: isSelected ? AdminColors.teal : AdminColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Text(
                  item.title,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AdminColors.teal : AdminColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (item.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: (item.badgeColor ?? AdminColors.red).withOpacity(0.15),
                      border: Border.all(
                        color: (item.badgeColor ?? AdminColors.red).withOpacity(0.25),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.badge!,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: item.badgeColor ?? AdminColors.red,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 5)],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.dmSans(fontSize: 11, color: AdminColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.dmMono(fontSize: 10, color: AdminColors.teal),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AdminColors.bgDeep.withOpacity(0.85),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedIndex == 0 ? 'Dashboard Overview' : _navItems[_selectedIndex].title,
              style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            if (_selectedIndex == 0)
              Text(
                'Saturday, May 9, 2026 · 12 devices online',
                style: GoogleFonts.dmSans(fontSize: 11, color: AdminColors.textSecondary),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AdminColors.textSecondary),
            onPressed: () {},
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AdminColors.textSecondary),
                onPressed: () {},
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AdminColors.red,
                    border: Border.all(color: AdminColors.bgDeep, width: 1.5),
                    boxShadow: [BoxShadow(color: AdminColors.red.withOpacity(0.6), blurRadius: 6)],
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AdminColors.textSecondary),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AdminColors.bgDark,
        width: 260,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        gradient: const LinearGradient(
                          colors: [AdminColors.teal, AdminColors.tealDim],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AdminColors.teal.withOpacity(0.3),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.layers, color: AdminColors.bgDeep, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EYE INT.',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: AdminColors.teal,
                          ),
                        ),
                        Text(
                          'ADMIN PANEL',
                          style: GoogleFonts.dmSans(
                            fontSize: 9,
                            letterSpacing: 1,
                            color: AdminColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(color: AdminColors.glassBorder, height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  'OVERVIEW',
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: AdminColors.textMuted,
                  ),
                ),
              ),
              ..._navItems.take(3).map((item) => _buildDrawerItem(item, _navItems.indexOf(item))),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  'MANAGEMENT',
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: AdminColors.textMuted,
                  ),
                ),
              ),
              ..._navItems.skip(3).map((item) => _buildDrawerItem(item, _navItems.indexOf(item))),
              const Spacer(),
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AdminColors.glass,
                  border: Border.all(color: AdminColors.glassBorder),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SYSTEM STATUS',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        letterSpacing: 1,
                        color: AdminColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildStatusRow('API Server', '99.8%', AdminColors.teal),
                    _buildStatusRow('MQTT Broker', 'Online', AdminColors.teal),
                    _buildStatusRow('Firmware OTA', 'Syncing', AdminColors.amber),
                  ],
                ),
              ),
              ListTile(
                leading: CircleAvatar(
                  radius: 17,
                  backgroundColor: AdminColors.teal,
                  child: Text(
                    'OA',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AdminColors.bgDeep,
                    ),
                  ),
                ),
                title: Text(
                  'Omar Admin',
                  style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Super Admin',
                  style: GoogleFonts.dmSans(fontSize: 10, color: AdminColors.teal),
                ),
                trailing: const Icon(Icons.logout, color: AdminColors.textMuted, size: 18),
                onTap: _logout,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}

// ────────────────────────────────────────
// Dashboard Content (main home)
// ────────────────────────────────────────
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: const KpiCard(
                      label: 'TOTAL DEVICES',
                      value: '247',
                      delta: '+12 this week',
                      deltaUp: true,
                      color: AdminColors.teal,
                      icon: Icons.devices,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: const KpiCard(
                      label: 'ACTIVE USERS',
                      value: '1,842',
                      delta: '+8.3% vs last month',
                      deltaUp: true,
                      color: AdminColors.amber,
                      icon: Icons.people_outline,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: const KpiCard(
                      label: 'ALERTS',
                      value: '3',
                      delta: '2 critical',
                      deltaUp: false,
                      color: AdminColors.red,
                      icon: Icons.warning_amber,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: const KpiCard(
                      label: 'ENERGY TODAY',
                      value: '48.2',
                      unit: 'kWh',
                      delta: '-5% vs yesterday',
                      deltaUp: true,
                      color: AdminColors.blue,
                      icon: Icons.bolt,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const DeviceChartWidget(),
          const SizedBox(height: 16),
          const ActivityFeedWidget(),
          const SizedBox(height: 16),
          const DevicesTableWidget(),
          const SizedBox(height: 16),
          const QuickControlsWidget(),
          const SizedBox(height: 16),
          const HomeMapCardWidget(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────
// KPI Card Widget
// ────────────────────────────────────────
class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final String delta;
  final bool deltaUp;
  final Color color;
  final IconData icon;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    required this.delta,
    required this.deltaUp,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.bgCard,
        border: Border.all(color: AdminColors.glassBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(fontSize: 10, color: AdminColors.textSecondary, letterSpacing: 0.5),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: color.withOpacity(0.1),
                ),
                child: Icon(icon, size: 15, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: AdminColors.textPrimary,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unit!,
                    style: GoogleFonts.dmSans(fontSize: 14, color: AdminColors.textSecondary),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: deltaUp ? AdminColors.teal.withOpacity(0.1) : AdminColors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  deltaUp ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 10,
                  color: deltaUp ? AdminColors.teal : AdminColors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  delta,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: deltaUp ? AdminColors.teal : AdminColors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────
// Device Chart Widget
// ────────────────────────────────────────
class DeviceChartWidget extends StatefulWidget {
  const DeviceChartWidget({super.key});

  @override
  State<DeviceChartWidget> createState() => _DeviceChartWidgetState();
}

class _DeviceChartWidgetState extends State<DeviceChartWidget> {
  String _selectedFilter = '24H';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AdminColors.bgCard,
        border: Border.all(color: AdminColors.glassBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Device Activity',
                    style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Online devices per hour · Today',
                    style: GoogleFonts.dmSans(fontSize: 11, color: AdminColors.textSecondary),
                  ),
                ],
              ),
              Row(
                children: ['24H', '7D', '30D'].map((filter) {
                  final isActive = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isActive ? AdminColors.tealBg : Colors.transparent,
                          border: Border.all(
                            color: isActive ? AdminColors.teal.withOpacity(0.25) : AdminColors.glassBorder,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          filter,
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isActive ? AdminColors.teal : AdminColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 50,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.04),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: GoogleFonts.dmMono(fontSize: 9, color: AdminColors.textMuted),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 6,
                      getTitlesWidget: (value, meta) {
                        const hours = ['00:00', '06:00', '12:00', '16:00', '20:00', ''];
                        final idx = value.toInt();
                        if (idx >= 0 && idx < hours.length) {
                          return Text(
                            hours[idx],
                            style: GoogleFonts.dmMono(fontSize: 8, color: AdminColors.textMuted),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 5,
                minY: 50,
                maxY: 200,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 120),
                      FlSpot(1, 80),
                      FlSpot(2, 45),
                      FlSpot(3, 55),
                      FlSpot(4, 30),
                      FlSpot(5, 35),
                    ],
                    isCurved: true,
                    color: AdminColors.teal,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: index == 4 ? 5 : 3,
                          color: AdminColors.teal,
                          strokeWidth: 0,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AdminColors.teal.withOpacity(0.25),
                          AdminColors.teal.withOpacity(0.0),
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
}

// ────────────────────────────────────────
// Activity Feed Widget
// ────────────────────────────────────────
class _ActivityItem {
  final IconData icon;
  final Color iconColor;
  final String text;
  final String time;
  final String highlight;

  const _ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.time,
    required this.highlight,
  });
}

class ActivityFeedWidget extends StatelessWidget {
  const ActivityFeedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = const [
      _ActivityItem(
        icon: Icons.bolt,
        iconColor: AdminColors.teal,
        text: 'Master Bedroom lights set to 94% brightness',
        time: 'Just now · Omar A.',
        highlight: 'Master Bedroom',
      ),
      _ActivityItem(
        icon: Icons.visibility,
        iconColor: AdminColors.amber,
        text: 'Motion detected in Front Entrance',
        time: '3 min ago · Security cam',
        highlight: 'Front Entrance',
      ),
      _ActivityItem(
        icon: Icons.warning_amber,
        iconColor: AdminColors.red,
        text: 'Thermostat offline — check connection',
        time: '12 min ago · Auto-alert',
        highlight: 'Thermostat',
      ),
      _ActivityItem(
        icon: Icons.person_add,
        iconColor: AdminColors.blue,
        text: 'New user Sarah K. joined the household',
        time: '1 hr ago · Admin',
        highlight: 'Sarah K.',
      ),
      _ActivityItem(
        icon: Icons.home,
        iconColor: AdminColors.teal,
        text: 'Scene "Relax Mode" activated in Living Room',
        time: '2 hr ago · Voice command',
        highlight: '"Relax Mode"',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AdminColors.bgCard,
        border: Border.all(color: AdminColors.glassBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Activity',
                    style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Live system events',
                    style: GoogleFonts.dmSans(fontSize: 11, color: AdminColors.textSecondary),
                  ),
                ],
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AdminColors.teal,
                  boxShadow: [BoxShadow(color: AdminColors.teal.withOpacity(0.6), blurRadius: 8)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...activities.map((a) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: a.iconColor.withOpacity(0.1),
                    ),
                    child: Icon(a.icon, size: 13, color: a.iconColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.dmSans(fontSize: 12, color: AdminColors.textPrimary, height: 1.4),
                            children: [
                              TextSpan(
                                text: a.highlight,
                                style: const TextStyle(color: AdminColors.teal, fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: ' ${a.text.replaceFirst(a.highlight, '').trim()}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          a.time,
                          style: GoogleFonts.dmMono(fontSize: 9, color: AdminColors.textMuted),
                        ),
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
}

// ────────────────────────────────────────
// Devices Table Widget
// ────────────────────────────────────────
class _Device {
  final String name;
  final String room;
  final String status;
  final String lastActive;
  final String load;
  final bool isOnline;
  final bool isWarning;

  const _Device(this.name, this.room, this.status, this.lastActive, this.load, this.isOnline, this.isWarning);
}

class DevicesTableWidget extends StatelessWidget {
  const DevicesTableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final devices = const [
      _Device('Smart Light 1', 'Master Bed', 'Online', 'Now', '94%', true, false),
      _Device('Smart Light 2', 'Master Bed', 'Online', 'Now', '28%', true, false),
      _Device('Thermostat', 'Living Room', 'Warning', '12m ago', '--', false, true),
      _Device('Security Cam', 'Entrance', 'Online', '3m ago', '41%', true, false),
      _Device('Smart Lock', 'Front Door', 'Online', '1h ago', '12%', true, false),
      _Device('Air Purifier', 'Bedroom 2', 'Offline', '2d ago', '--', false, false),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AdminColors.bgCard,
        border: Border.all(color: AdminColors.glassBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connected Devices',
                    style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '247 total · 12 offline',
                    style: GoogleFonts.dmSans(fontSize: 11, color: AdminColors.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AdminColors.tealBg,
                  border: Border.all(color: AdminColors.teal.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'View All',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.teal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Expanded(flex: 2, child: _header('DEVICE')),
                Expanded(flex: 2, child: _header('ROOM')),
                Expanded(flex: 2, child: _header('STATUS')),
                Expanded(flex: 2, child: _header('LAST ACTIVE')),
                Expanded(flex: 1, child: _header('LOAD')),
              ],
            ),
          ),
          const Divider(color: AdminColors.glassBorder, height: 8),
          // Rows
          ...devices.map((d) {
            Color statusColor;
            if (d.isOnline) {
              statusColor = AdminColors.teal;
            } else if (d.isWarning) {
              statusColor = AdminColors.amber;
            } else {
              statusColor = AdminColors.textMuted;
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      d.name,
                      style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AdminColors.glass,
                        border: Border.all(color: AdminColors.glassBorder),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        d.room,
                        style: GoogleFonts.dmSans(fontSize: 9, color: AdminColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                            boxShadow: d.isOnline
                                ? [BoxShadow(color: statusColor.withOpacity(0.6), blurRadius: 5)]
                                : null,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          d.status,
                          style: GoogleFonts.dmSans(fontSize: 10, color: AdminColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      d.lastActive,
                      style: GoogleFonts.dmMono(fontSize: 10, color: AdminColors.textSecondary),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      d.load,
                      style: GoogleFonts.dmMono(
                        fontSize: 10,
                        color: d.isOnline ? AdminColors.teal : AdminColors.textMuted,
                      ),
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

  Widget _header(String text) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 9,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        color: AdminColors.textMuted,
      ),
    );
  }
}

// ────────────────────────────────────────
// Quick Controls Widget
// ────────────────────────────────────────
class QuickControlsWidget extends StatefulWidget {
  const QuickControlsWidget({super.key});

  @override
  State<QuickControlsWidget> createState() => _QuickControlsWidgetState();
}

class _QuickControlsWidgetState extends State<QuickControlsWidget> {
  bool _allLights = true;
  bool _securityMode = true;
  bool _smartHvac = false;
  bool _guestMode = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AdminColors.bgCard,
        border: Border.all(color: AdminColors.glassBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Controls',
                style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              Text(
                'Global scene toggles',
                style: GoogleFonts.dmSans(fontSize: 11, color: AdminColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildSwitch(Icons.light_mode, 'All Lights', '12 fixtures active', _allLights,
              (v) => setState(() => _allLights = v)),
          _buildSwitch(Icons.shield, 'Security Mode', 'Cameras + motion active', _securityMode,
              (v) => setState(() => _securityMode = v)),
          _buildSwitch(Icons.ac_unit, 'Smart HVAC', '24°C · Auto mode', _smartHvac,
              (v) => setState(() => _smartHvac = v)),
          _buildSwitch(Icons.person_outline, 'Guest Mode', 'Restricted access', _guestMode,
              (v) => setState(() => _guestMode = v), isLast: true),
        ],
      ),
    );
  }

  Widget _buildSwitch(IconData icon, String title, String subtitle, bool value,
      ValueChanged<bool> onChanged, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              color: AdminColors.glass,
              border: Border.all(color: AdminColors.glassBorder),
            ),
            child: Icon(icon, size: 15, color: AdminColors.textSecondary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500)),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(fontSize: 10, color: AdminColors.textMuted),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                color: value ? AdminColors.teal : AdminColors.glassBorder,
                border: Border.all(
                  color: value ? AdminColors.teal : AdminColors.glassBorder,
                ),
                boxShadow: value
                    ? [BoxShadow(color: AdminColors.teal.withOpacity(0.4), blurRadius: 10)]
                    : null,
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────
// Home Map Card Widget
// ────────────────────────────────────────
class HomeMapCardWidget extends StatelessWidget {
  const HomeMapCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AdminColors.bgCard,
        border: Border.all(color: AdminColors.glassBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Home Overview',
                style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              Text(
                'Live floor status',
                style: GoogleFonts.dmSans(fontSize: 11, color: AdminColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: AdminColors.bgMid,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.home_work_outlined,
                      size: 60,
                      color: AdminColors.textMuted.withOpacity(0.3),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AdminColors.bgDeep.withOpacity(0.85),
                          ],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Row(
                      children: [
                        _badge('12 Online', AdminColors.teal),
                        const SizedBox(width: 6),
                        _badge('3 Alerts', AdminColors.red),
                        const SizedBox(width: 6),
                        _badge('1 Offline', AdminColors.textMuted),
                      ],
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

  Widget _badge(String text, Color dotColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AdminColors.bgDeep.withOpacity(0.7),
        border: Border.all(color: AdminColors.glassBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
              boxShadow: dotColor == AdminColors.textMuted
                  ? null
                  : [BoxShadow(color: dotColor.withOpacity(0.6), blurRadius: 4)],
            ),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.dmSans(fontSize: 10, color: AdminColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────
// Placeholder Screens
// ────────────────────────────────────────

class RoomsScreen extends StatelessWidget {
  const RoomsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final rooms = [
      ('Master Bedroom', '6 devices', true),
      ('Living Room', '4 devices', true),
      ('Kitchen', '3 devices', true),
      ('Front Entrance', '2 devices', true),
      ('Bedroom 2', '2 devices', false),
      ('Bathroom', '1 device', true),
      ('Garage', '2 devices', true),
      ('Home Office', '3 devices', true),
      ('Dining Room', '2 devices', true),
      ('Basement', '1 device', false),
      ('Guest Room', '1 device', true),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: rooms.map((r) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AdminColors.bgCard,
          border: Border.all(color: AdminColors.glassBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: r.$3 ? AdminColors.tealBg : AdminColors.glass,
              ),
              child: Icon(Icons.home, color: r.$3 ? AdminColors.teal : AdminColors.textMuted, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.$1, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(r.$2, style: GoogleFonts.dmSans(fontSize: 11, color: AdminColors.textSecondary)),
                ],
              ),
            ),
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: r.$3 ? AdminColors.teal : AdminColors.textMuted,
                boxShadow: r.$3 ? [BoxShadow(color: AdminColors.teal.withOpacity(0.6), blurRadius: 5)] : null,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final devices = [
      ('Smart Light 1', 'Master Bedroom', '94%', true, false),
      ('Smart Light 2', 'Master Bedroom', '28%', true, false),
      ('Thermostat', 'Living Room', '--', false, true),
      ('Security Camera', 'Front Entrance', '41%', true, false),
      ('Smart Lock', 'Front Door', '12%', true, false),
      ('Air Purifier', 'Bedroom 2', '--', false, false),
      ('Smart Speaker', 'Living Room', '60%', true, false),
      ('Motion Sensor', 'Hallway', '100%', true, false),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: devices.map((d) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AdminColors.bgCard,
          border: Border.all(color: AdminColors.glassBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: d.$4 ? AdminColors.tealBg : AdminColors.glass,
              ),
              child: Icon(Icons.devices, color: d.$4 ? AdminColors.teal : AdminColors.textMuted, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.$1, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500)),
                  Text(d.$2, style: GoogleFonts.dmSans(fontSize: 11, color: AdminColors.textSecondary)),
                ],
              ),
            ),
            Text(
              d.$3,
              style: GoogleFonts.dmMono(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: d.$4 ? AdminColors.teal : (d.$5 ? AdminColors.amber : AdminColors.textMuted),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: d.$4 ? AdminColors.teal : (d.$5 ? AdminColors.amber : AdminColors.textMuted),
                boxShadow: d.$4 ? [BoxShadow(color: AdminColors.teal.withOpacity(0.6), blurRadius: 5)] : null,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _notificationType = 'email';
  bool _isLoading = false;

  final _authService = AuthService();

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await _authService.sendNotification(
        userEmail: _emailController.text.trim(),
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
        type: _notificationType,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? AdminColors.teal : AdminColors.red,
          ),
        );
        if (result['success']) {
          _emailController.clear();
          _subjectController.clear();
          _messageController.clear();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AdminColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AdminColors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.people_outline, color: AdminColors.teal, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Users Management',
                    style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Manage users and send notifications',
                    style: GoogleFonts.dmSans(fontSize: 12, color: AdminColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AdminColors.bgCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AdminColors.glassBorder),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Send Notification',
                    style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 24),
                  _buildLabel('User Email'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'user@example.com',
                    icon: Icons.email_outlined,
                    validator: (v) => v!.isEmpty ? 'Email is required' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Notification Type'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTypeOption('email', Icons.mail_outline),
                      const SizedBox(width: 12),
                      _buildTypeOption('sms', Icons.sms_outlined),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Subject'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _subjectController,
                    hint: 'Notification Subject',
                    icon: Icons.title,
                    validator: (v) => v!.isEmpty ? 'Subject is required' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Message'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _messageController,
                    hint: 'Enter your message here...',
                    icon: Icons.message_outlined,
                    maxLines: 5,
                    validator: (v) => v!.isEmpty ? 'Message is required' : null,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendNotification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.teal,
                        foregroundColor: AdminColors.bgDeep,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AdminColors.bgDeep),
                            )
                          : Text(
                              'Send Notification',
                              style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 15),
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

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: AdminColors.textSecondary),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.dmSans(color: AdminColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(color: AdminColors.textMuted, fontSize: 14),
        prefixIcon: Icon(icon, color: AdminColors.textSecondary, size: 18),
        filled: true,
        fillColor: AdminColors.bgDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
   class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('System Analytics', 'Real-time performance and usage metrics', Icons.timeline),
          const SizedBox(height: 24),
          _buildAnalyticsSummary(),
          const SizedBox(height: 24),
          _buildChartCard('User Growth', 'Monthly active users trend', _buildUserGrowthChart()),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSmallStatCard('Uptime', '99.98%', Icons.check_circle_outline, AdminColors.teal)),
              const SizedBox(width: 16),
              Expanded(child: _buildSmallStatCard('Latency', '24ms', Icons.speed, AdminColors.blue)),
            ],
          ),
          const SizedBox(height: 16),
          _buildChartCard('System Load', 'CPU and Memory utilization', _buildSystemLoadChart()),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSummary() {
    return Row(
      children: [
        Expanded(child: _buildMetricCard('Total Users', '14.2k', '+12%', true)),
        const SizedBox(width: 12),
        Expanded(child: _buildMetricCard('Sessions', '85.4k', '+5.2%', true)),
        const SizedBox(width: 12),
        Expanded(child: _buildMetricCard('Bounce', '24%', '-1.5%', true)),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, String delta, bool up) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: AdminColors.textSecondary)),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(delta, style: GoogleFonts.dmSans(fontSize: 10, color: up ? AdminColors.teal : AdminColors.red)),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, String subtitle, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdminColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700)),
          Text(subtitle, style: GoogleFonts.dmSans(fontSize: 11, color: AdminColors.textSecondary)),
          const SizedBox(height: 24),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  Widget _buildUserGrowthChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 3.5), FlSpot(3, 5), FlSpot(4, 4.8), FlSpot(5, 6)],
            isCurved: true,
            color: AdminColors.teal,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AdminColors.teal.withOpacity(0.2), Colors.transparent],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemLoadChart() {
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          _barGroup(0, 15, AdminColors.teal),
          _barGroup(1, 12, AdminColors.teal),
          _barGroup(2, 18, AdminColors.blue),
          _barGroup(3, 14, AdminColors.teal),
          _barGroup(4, 20, AdminColors.red),
          _barGroup(5, 16, AdminColors.teal),
        ],
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [BarChartRodData(toY: y, color: color, width: 12, borderRadius: BorderRadius.circular(4))],
    );
  }
}

class EnergyScreen extends StatelessWidget {
  const EnergyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Energy Management', 'Monitor consumption and optimize efficiency', Icons.bolt),
          const SizedBox(height: 24),
          _buildEnergyKPIs(),
          const SizedBox(height: 24),
          _buildSectionTitle('Usage by Room'),
          const SizedBox(height: 16),
          _buildRoomEnergyList(),
          const SizedBox(height: 24),
          _buildChartCard('Consumption Trend', 'Daily kWh usage for the last 7 days', _buildEnergyTrendChart()),
        ],
      ),
    );
  }

  Widget _buildEnergyKPIs() {
    return Row(
      children: [
        Expanded(
          child: _buildLargeMetricCard('48.2', 'kWh', 'TODAY', AdminColors.teal),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildLargeMetricCard('1,240', 'LE', 'EST. COST', AdminColors.amber),
        ),
      ],
    );
  }

  Widget _buildLargeMetricCard(String value, String unit, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminColors.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AdminColors.glassBorder),
      ),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700, color: AdminColors.textMuted, letterSpacing: 1)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: GoogleFonts.dmSans(fontSize: 32, fontWeight: FontWeight.w800, color: color)),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(unit, style: GoogleFonts.dmSans(fontSize: 14, color: AdminColors.textSecondary)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomEnergyList() {
    final rooms = [
      {'name': 'Living Room', 'value': '12.4 kWh', 'percent': 0.4},
      {'name': 'Kitchen', 'value': '18.2 kWh', 'percent': 0.6},
      {'name': 'Master Bedroom', 'value': '8.5 kWh', 'percent': 0.3},
      {'name': 'Office', 'value': '9.1 kWh', 'percent': 0.35},
    ];

    return Column(
      children: rooms.map((room) => _buildRoomItem(room)).toList(),
    );
  }

  Widget _buildRoomItem(Map<String, dynamic> room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.glassBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(room['name'], style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600)),
              Text(room['value'], style: GoogleFonts.dmMono(fontSize: 12, color: AdminColors.teal)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: room['percent'],
              backgroundColor: AdminColors.bgDark,
              valueColor: const AlwaysStoppedAnimation<Color>(AdminColors.teal),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyTrendChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [FlSpot(0, 10), FlSpot(1, 15), FlSpot(2, 12), FlSpot(3, 20), FlSpot(4, 18), FlSpot(5, 25), FlSpot(6, 22)],
            isCurved: true,
            color: AdminColors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Security & Safety', 'Intrusion detection and system integrity', Icons.shield_outlined),
          const SizedBox(height: 24),
          _buildSecurityStatus(),
          const SizedBox(height: 24),
          _buildSectionTitle('Recent Security Events'),
          const SizedBox(height: 16),
          _buildSecurityEventsList(),
          const SizedBox(height: 24),
          _buildSectionTitle('Access Logs'),
          const SizedBox(height: 16),
          _buildAccessLogsTable(),
        ],
      ),
    );
  }

  Widget _buildSecurityStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AdminColors.teal.withOpacity(0.1), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdminColors.teal.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: AdminColors.teal, shape: BoxShape.circle),
            child: const Icon(Icons.verified_user, color: AdminColors.bgDeep, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('System Shield Active', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700, color: AdminColors.teal)),
                Text('All nodes are encrypted and firewall is monitoring 12 ports.', style: GoogleFonts.dmSans(fontSize: 12, color: AdminColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityEventsList() {
    final events = [
      {'title': 'Unauthorized Login Attempt', 'time': '2 mins ago', 'desc': 'Blocked IP 192.168.1.45', 'color': AdminColors.red},
      {'title': 'Motion Detected', 'time': '15 mins ago', 'desc': 'Camera 2 (Garage) active', 'color': AdminColors.amber},
      {'title': 'System Backup Successful', 'time': '1 hour ago', 'desc': 'Integrity check passed', 'color': AdminColors.teal},
    ];

    return Column(
      children: events.map((e) => _buildEventItem(e)).toList(),
    );
  }

  Widget _buildEventItem(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(width: 4, height: 40, decoration: BoxDecoration(color: event['color'], borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(event['title'], style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(event['time'], style: GoogleFonts.dmSans(fontSize: 10, color: AdminColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(event['desc'], style: GoogleFonts.dmSans(fontSize: 11, color: AdminColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessLogsTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.glassBorder),
      ),
      child: Column(
        children: [
          _logRow('Admin', 'Login', '12:45 PM', AdminColors.teal),
          const Divider(color: AdminColors.glassBorder),
          _logRow('User_04', 'Lights_On', '12:42 PM', AdminColors.blue),
          const Divider(color: AdminColors.glassBorder),
          _logRow('API_Key_3', 'Data_Fetch', '12:40 PM', AdminColors.textMuted),
        ],
      ),
    );
  }

  Widget _logRow(String user, String action, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(user, style: GoogleFonts.dmMono(fontSize: 11, fontWeight: FontWeight.w600)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(action, style: GoogleFonts.dmSans(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 20),
          Text(time, style: GoogleFonts.dmSans(fontSize: 10, color: AdminColors.textMuted)),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _maintenanceMode = false;
  bool _emailNotifications = true;
  bool _pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('System Settings', 'Configure global application parameters', Icons.settings_outlined),
          const SizedBox(height: 24),
          _buildSettingsGroup('Infrastructure', [
            _buildSettingTile('API Base URL', 'http://127.0.0.1:8000', Icons.link),
            _buildSettingTile('MQTT Broker', 'tcp://localhost:1883', Icons.rss_feed),
            _buildSwitchTile('Maintenance Mode', 'Block all client traffic', _maintenanceMode, (v) => setState(() => _maintenanceMode = v)),
          ]),
    return ListTile(
      leading: Icon(icon, size: 20, color: AdminColors.textSecondary),
      title: Text(title, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: GoogleFonts.dmMono(fontSize: 12, color: AdminColors.textMuted)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 16, color: AdminColors.textMuted),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: GoogleFonts.dmSans(fontSize: 11, color: AdminColors.textSecondary)),
      activeColor: AdminColors.teal,
      secondary: Icon(Icons.notifications_none, size: 20, color: value ? AdminColors.teal : AdminColors.textSecondary),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, size: 20, color: color),
      title: Text(title, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: color)),
      subtitle: Text(subtitle, style: GoogleFonts.dmSans(fontSize: 11, color: AdminColors.textSecondary)),
      onTap: () {},
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AdminColors.teal,
          foregroundColor: AdminColors.bgDeep,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          shadowColor: AdminColors.teal.withOpacity(0.3),
        ),
        child: Text('Apply Configurations', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ── Shared Helpers ──────────────────────────

Widget _buildHeader(String title, String subtitle, IconData icon) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AdminColors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AdminColors.teal, size: 24),
      ),
      const SizedBox(width: 16),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w700)),
          Text(subtitle, style: GoogleFonts.dmSans(fontSize: 12, color: AdminColors.textSecondary)),
        ],
      ),
    ],
  );
}

Widget _buildSectionTitle(String title) {
  return Text(title, style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600));
}

Widget _buildSmallStatCard(String label, String value, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AdminColors.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AdminColors.glassBorder)),
    child: Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: AdminColors.textSecondary)),
            Text(value, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    ),
  );
