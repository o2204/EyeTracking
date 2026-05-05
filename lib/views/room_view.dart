import 'dart:ui';
import 'package:flutter/material.dart';
import '../controllers/room_controller.dart';
import '../theme/app_theme.dart';
import 'room_details_view.dart';

class RoomView extends StatefulWidget {
  final RoomController controller;
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeToggle;
  final VoidCallback? onDevicesTabSelected;

  const RoomView({
    super.key,
    required this.controller,
    required this.isDarkMode,
    required this.onDarkModeToggle,
    this.onDevicesTabSelected,
  });

  @override
  State<RoomView> createState() => _RoomViewState();
}

class _RoomViewState extends State<RoomView> with SingleTickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;
  int _selectedSidebarIndex = 0; // 0 = Home, 1... = rooms

  // 3D Interactive Rotation
  double _targetRotationX = 0;
  double _targetRotationY = 0;

  @override
  void initState() {
    super.initState();
    // Subtle floating animation for the 3D house
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _floatingAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.4, -0.6), 
            radius: 1.6, 
            colors: [
              AppTheme.accent.withValues(alpha: 0.2), // Subtle warm glow
              AppTheme.backgroundSecondary,
              AppTheme.backgroundPrimary,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          image: const DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover, 
            alignment: Alignment.center,
            opacity: 0.9,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [

              // Header (Logo & User)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildHeader(context),
              ),

              // Floating Control Panel
              Positioned(
                top: 120,
                left: 0,
                right: 0,
                child: _buildFloatingControlPanel(),
              ),

              // Left Sidebar
              Positioned(
                left: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildSidebar(),
                ),
              ),
              
              // Right-side quick controls or details (removed as requested)
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildFloatingControlPanel() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -40 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppTheme.cardBackground.withValues(alpha: 0.8),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                ),
                boxShadow: AppTheme.premiumShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPanelItem(Icons.thermostat_rounded, "24°C", "Temperature", 0.7),
                  Container(
                    height: 50,
                    width: 1,
                    color: Colors.white.withValues(alpha: 0.15),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  _buildPanelItem(Icons.water_drop_rounded, "45%", "Humidity", 0.45),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanelItem(IconData icon, String value, String label, double progress) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF00C897), size: 22),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        // Progress bar
        Container(
          width: 90,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF00C897),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C897).withValues(alpha: 0.6),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: AppTheme.inputBorder,
          ),
        ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSidebarIcon(0, Icons.home_rounded, "Overview"),
          const SizedBox(height: 24),
          for (int i = 0; i < widget.controller.rooms.length; i++) ...[
            _buildSidebarIcon(
              i + 1, 
              _getIconForRoom(widget.controller.rooms[i].name), 
              widget.controller.rooms[i].name
            ),
            if (i < widget.controller.rooms.length - 1) 
              const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  IconData _getIconForRoom(String name) {
    final lower = name.toLowerCase();
    if (lower.contains("bed")) return Icons.bed_rounded;
    if (lower.contains("dining") || lower.contains("kitchen")) return Icons.restaurant_rounded;
    if (lower.contains("wash") || lower.contains("bath")) return Icons.bathtub_rounded;
    if (lower.contains("living")) return Icons.weekend_rounded;
    return Icons.meeting_room_rounded;
  }

  Widget _buildSidebarIcon(int index, IconData icon, String tooltip) {
    final isSelected = _selectedSidebarIndex == index;
    
    return Tooltip(
      message: tooltip,
      verticalOffset: 24,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedSidebarIndex = index;
            });
            if (index > 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoomDetailsView(room: widget.controller.rooms[index - 1]),
                ),
              );
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF00C897).withValues(alpha: 0.25) : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00C897).withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF00C897) : Colors.white.withValues(alpha: 0.5),
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final circleSize = (screenWidth * 0.15).clamp(40.0, 65.0);
    final logoSize = circleSize * 0.85;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Logo
              Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00C897).withValues(alpha: 0.2),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Center(
                  child: SizedBox(
                    width: logoSize,
                    height: logoSize,
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const Icon(Icons.remove_red_eye_rounded, color: Color(0xFF00C897)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // User Greeting
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Eye Intelligence",
                    style: TextStyle(color: Colors.white54, fontSize: 13, letterSpacing: 1.2),
                  ),
                  Text(
                    "Dashboard",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Devices Tab Toggle
          if (widget.onDevicesTabSelected != null)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: widget.onDevicesTabSelected,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.devices_rounded, color: Color(0xFF00C897), size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Devices",
                        style: TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

}