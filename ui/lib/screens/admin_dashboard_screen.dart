import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

// ────────────────────────────────────────
// App entry point
// ────────────────────────────────────────
void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eye Intelligence',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AdminColors.bgDeep,
        textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5B0),
          secondary: Color(0xFF00C498),
          surface: Color(0xFF060F1C),
          error: Color(0xFFFF4D6A),
        ),
      ),
      home: const AdminLoginScreen(),
    );
  }
}

// ────────────────────────────────────────
// App colors
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
// Login Screen
// ────────────────────────────────────────
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  bool _obscurePassword = true;
  bool _rememberMe = true;
  final _emailController = TextEditingController(text: 'admin@eyeintelligence.io');
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
    );
  }

  Widget _buildLabel(String text, {bool isAmber = false}) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: isAmber ? AdminColors.amber : AdminColors.teal,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      style: GoogleFonts.dmSans(fontSize: 14, color: AdminColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(color: AdminColors.textMuted),
        prefixIcon: Icon(icon, color: AdminColors.textMuted, size: 17),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AdminColors.textMuted,
                  size: 17,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
        filled: true,
        fillColor: AdminColors.bgMid.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminColors.glassBorderHover),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildStatPill(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AdminColors.glass,
        border: Border.all(color: AdminColors.glassBorder),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 6)],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$value $label',
            style: GoogleFonts.dmSans(fontSize: 11, color: AdminColors.textSecondary),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.bgDeep,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [AdminColors.teal, AdminColors.tealDim],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AdminColors.teal.withOpacity(0.3),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.layers, color: AdminColors.bgDeep, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'EYE INTELLIGENCE',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: AdminColors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'Admin Login',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Secure access to the Eye Intelligence control panel',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(fontSize: 13, color: AdminColors.textSecondary),
                  ),
                  const SizedBox(height: 36),
                  _buildLabel('Admin Email'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'admin@eyeintelligence.io',
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Password', isAmber: true),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _passwordController,
                    hint: '••••••••••••',
                    icon: Icons.lock_outlined,
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _rememberMe = !_rememberMe),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: _rememberMe ? AdminColors.teal : AdminColors.glass,
                                border: Border.all(
                                  color: _rememberMe ? AdminColors.teal : AdminColors.glassBorder,
                                ),
                              ),
                              child: _rememberMe
                                  ? const Icon(Icons.check, size: 10, color: AdminColors.bgDeep)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Keep me signed in',
                              style: GoogleFonts.dmSans(fontSize: 12, color: AdminColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Forgot password?',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AdminColors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.teal,
                        foregroundColor: AdminColors.bgDeep,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        elevation: 8,
                        shadowColor: AdminColors.teal.withOpacity(0.4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.login, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Sign in to Dashboard',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield, size: 12, color: AdminColors.teal),
                      const SizedBox(width: 6),
                      Text(
                        '256-bit SSL encrypted · Admin access only',
                        style: GoogleFonts.dmSans(fontSize: 11, color: AdminColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatPill('247', 'devices', AdminColors.teal),
                      const SizedBox(width: 8),
                      _buildStatPill('12', 'rooms', AdminColors.amber),
                      const SizedBox(width: 8),
                      _buildStatPill('99.8%', 'uptime', AdminColors.blue),
                    ],
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

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
    );
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

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AdminColors.textMuted.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('Users Management', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('1,842 active users', style: GoogleFonts.dmSans(fontSize: 13, color: AdminColors.textSecondary)),
        ],
      ),
    );
  }
}

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timeline, size: 64, color: AdminColors.textMuted.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('Analytics', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Advanced analytics & insights', style: GoogleFonts.dmSans(fontSize: 13, color: AdminColors.textSecondary)),
        ],
      ),
    );
  }
}

class EnergyScreen extends StatelessWidget {
  const EnergyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bolt, size: 64, color: AdminColors.textMuted.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('Energy Monitoring', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('48.2 kWh used today', style: GoogleFonts.dmSans(fontSize: 13, color: AdminColors.textSecondary)),
        ],
      ),
    );
  }
}

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 64, color: AdminColors.textMuted.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('Security', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('3 active alerts', style: GoogleFonts.dmSans(fontSize: 13, color: AdminColors.textSecondary)),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings_outlined, size: 64, color: AdminColors.textMuted.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('Settings', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('System configuration', style: GoogleFonts.dmSans(fontSize: 13, color: AdminColors.textSecondary)),
        ],
      ),
    );
  }
}