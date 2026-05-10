import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import 'add_device_screen.dart';

class BedroomScreen extends StatefulWidget {
  const BedroomScreen({super.key});

  @override
  State<BedroomScreen> createState() => _BedroomScreenState();
}

class _BedroomScreenState extends State<BedroomScreen>
    with SingleTickerProviderStateMixin {
  double _light1Brightness = 0.94;
  double _light2Brightness = 0.28;
  double _acLevel = 0.50;
  double _blindsLevel = 0.75;
  double _sliderValue = 0.94;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF080F1A),
                  Color(0xFF0A1628),
                  Color(0xFF060D18),
                ],
              ),
            ),
          ),

          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Hero image section
                _buildHeroSection(context),

                // Bottom controls
                Expanded(
                  child: _buildControlsSection(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.52,
      child: Stack(
        children: [
          // Room image
          Positioned.fill(
            child: Image.asset(
              'assets/bedroom_hero.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Brightness overlay
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: Colors.black.withOpacity((1.0 - _sliderValue).clamp(0.0, 0.9)),
            ),
          ),

          // Overlay gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.transparent,
                    AppColors.bgDeep.withOpacity(0.6),
                    AppColors.bgDeep,
                  ],
                  stops: const [0.0, 0.3, 0.8, 1.0],
                ),
              ),
            ),
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildGlassIconButton(
                    onTap: () => Navigator.pop(context),
                    icon: Icons.arrow_back_ios_rounded,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.15), width: 1),
                        ),
                        child: const Text(
                          'Master Bedroom',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildGlassIconButton(
                    onTap: () {},
                    icon: Icons.more_vert_rounded,
                  ),
                ],
              ),
            ),
          ),

          // Vertical brightness slider (right side)
          Positioned(
            right: 20,
            top: 180,
            bottom: 40,
            child: _buildVerticalSlider(),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassIconButton(
      {required VoidCallback onTap, required IconData icon}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: Colors.white.withOpacity(0.15), width: 1),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalSlider() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: 56,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(30),
            border:
                Border.all(color: Colors.white.withOpacity(0.12), width: 1),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Sun icon at top
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.teal.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.wb_sunny_rounded,
                  color: AppColors.bgDeep,
                  size: 18,
                ),
              ),
              const SizedBox(height: 10),

              // Slider track
              Expanded(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 6,
                      activeTrackColor: AppColors.teal,
                      inactiveTrackColor: Colors.white.withOpacity(0.1),
                      thumbColor: Colors.transparent,
                      thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 0),
                      overlayShape: SliderComponentShape.noOverlay,
                      trackShape: const RoundedRectSliderTrackShape(),
                    ),
                    child: Slider(
                      value: _sliderValue,
                      onChanged: (val) {
                        setState(() {
                          _sliderValue = val;
                          _light1Brightness = val;
                        });
                      },
                    ),
                  ),
                ),
              ),

              // Percentage label
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${(_sliderValue * 100).round()}%',
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Device header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Device',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddDeviceScreen()),
                  );
                },
                child: const Text(
                  'Add device',
                  style: TextStyle(
                    color: AppColors.teal,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Light cards row
          Row(
            children: [
              Expanded(
                child: _buildLightCard(
                  label: 'Smart light 1',
                  brightness: _light1Brightness,
                  isActive: true,
                  onChanged: (val) =>
                      setState(() => _light1Brightness = val),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildLightCard(
                  label: 'Smart light 2',
                  brightness: _light2Brightness,
                  isActive: false,
                  onChanged: (val) =>
                      setState(() => _light2Brightness = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildLightCard(
                  label: 'AC',
                  brightness: _acLevel,
                  isActive: true,
                  icon: Icons.ac_unit_rounded,
                  onChanged: (val) =>
                      setState(() => _acLevel = val),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildLightCard(
                  label: 'Blinds',
                  brightness: _blindsLevel,
                  isActive: false,
                  icon: Icons.blinds_closed_rounded,
                  onChanged: (val) =>
                      setState(() => _blindsLevel = val),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLightCard({
    required String label,
    required double brightness,
    required bool isActive,
    required ValueChanged<double> onChanged,
    IconData icon = Icons.lightbulb_outline_rounded,
  }) {
    final percentInt = (brightness * 100).round();
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0x1A1E3A5F),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? AppColors.teal.withOpacity(0.25)
                  : AppColors.bgGlassBorder,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$percentInt%',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.teal
                          : AppColors.bgGlass,
                      shape: BoxShape.circle,
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.teal.withOpacity(0.4),
                                blurRadius: 10,
                                spreadRadius: 1,
                              )
                            ]
                          : null,
                      border: isActive
                          ? null
                          : Border.all(
                              color: AppColors.bgGlassBorder, width: 1),
                    ),
                    child: Icon(
                      icon,
                      color:
                          isActive ? AppColors.bgDeep : AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildProgressBar(brightness, isActive ? AppColors.teal : AppColors.textMuted),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
