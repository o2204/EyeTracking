import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import 'bedroom_screen.dart';
import 'dining_room_screen.dart';
import 'reception_room_screen.dart';
import 'camera_streaming_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../services/api_config.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedNav = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String _tempString = '--°C';
  String _humidityString = '--%';
  double _tempProgress = 0.0;
  double _humidityProgress = 0.0;

  final List<IconData> _navIcons = [
    Icons.home_rounded,
    Icons.bed_rounded,
    Icons.weekend_rounded,
    Icons.restaurant_rounded,
    Icons.person_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/weather/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            double t = (data['temperature'] as num).toDouble();
            double h = (data['humidity'] as num).toDouble();
            _tempString = '${t.round()}°C';
            _humidityString = '${h.round()}%';
            _tempProgress = (t / 50).clamp(0.0, 1.0); // Assume max 50C for progress bar
            _humidityProgress = (h / 100).clamp(0.0, 1.0);
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching weather: $e');
    }
  }

  Future<void> _toggleFan() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/fan/on'),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.statusCode == 200
                  ? '✅ Fan turned ON'
                  : '⚠️ Fan request failed (${response.statusCode})',
            ),
            backgroundColor:
                response.statusCode == 200 ? AppColors.teal : Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Could not reach ESP32'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.bgGradient,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top header
                _buildHeader(),
                const SizedBox(height: 16),

                // Stats row
                _buildStatsRow(),
                const SizedBox(height: 20),

                // House image with side nav
                Expanded(
                  child: Stack(
                    children: [
                      _buildHouseSection(),
                      _buildSideNav(),
                    ],
                  ),
                ),

                // Bottom card
                _buildBottomCard(),
                const SizedBox(height: 24),

                // Mic button
                _buildMicButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: AppColors.teal
                              .withOpacity(_pulseAnimation.value),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.teal
                                  .withOpacity(_pulseAnimation.value * 0.6),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'EYE INTELLIGENCE',
                    style: TextStyle(
                      color: AppColors.teal,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Dashboard',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/camera-streaming'),
            child: _buildGlassChip(
              icon: Icons.wifi_rounded,
              label: 'Devices',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassChip({required IconData icon, required String label}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.bgGlass,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.bgGlassBorder, width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.thermostat_rounded,
              value: _tempString,
              label: 'Temperature',
              color: AppColors.teal,
              progress: _tempProgress,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.water_drop_outlined,
              value: _humidityString,
              label: 'Humidity',
              color: AppColors.teal,
              progress: _humidityProgress,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required double progress,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0x1A1E3A5F),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.bgGlassBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              _buildProgressBar(progress, color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(double value, Color color) {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: AppColors.bgGlass,
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.6), color],
            ),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHouseSection() {
    return Positioned.fill(
      left: 96,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/smart_home_hero.jpg',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.bgDeep.withOpacity(0.3),
                    AppColors.bgDeep.withOpacity(0.7),
                  ],
                  stops: const [0.3, 0.7, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideNav() {
    return Positioned(
      left: 16,
      top: 16,
      bottom: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 64,
            decoration: BoxDecoration(
              color: const Color(0x26050D18),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                  color: AppColors.bgGlassBorder.withOpacity(0.3), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _navIcons.length,
                (index) => _buildNavItem(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = _selectedNav == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedNav = index);
        if (index == 1) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const BedroomScreen(),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const ReceptionRoomScreen(),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const DiningRoomScreen(),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
          );
        } else if (index == 4) {
          Navigator.pushNamed(context, '/profile');
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 8),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.teal.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 0,
                  )
                ]
              : null,
        ),
        child: Icon(
          _navIcons[index],
          color:
              isSelected ? AppColors.bgDeep : AppColors.textSecondary,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildBottomCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0x330A1628),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.bgGlassBorder, width: 1),
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
                        const Text(
                          'Welcome home, Omar',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '12 devices online',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.teal.withOpacity(0.3), width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.bolt_rounded,
                              color: AppColors.teal, size: 14),
                          const SizedBox(width: 4),
                          const Text(
                            '2.4 kWh',
                            style: TextStyle(
                              color: AppColors.teal,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: _toggleFan,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0x1A1E3A5F),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.bgGlassBorder, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick scene',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Master Bedroom · Relax',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.textSecondary,
                          size: 16,
                        ),
                      ],
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

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/camera-streaming'),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [AppColors.teal, AppColors.tealDim],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.teal
                      .withOpacity(0.4 * _pulseAnimation.value),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.mic_rounded,
              color: AppColors.bgDeep,
              size: 28,
            ),
          );
        },
      ),
    );
  }
}
