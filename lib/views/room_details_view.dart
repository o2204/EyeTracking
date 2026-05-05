import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/room_data.dart';
import '../theme/app_theme.dart';

class RoomDetailsView extends StatefulWidget {
  final RoomData room;

  const RoomDetailsView({super.key, required this.room});

  @override
  State<RoomDetailsView> createState() => _RoomDetailsViewState();
}

class _RoomDetailsViewState extends State<RoomDetailsView> {
  double _mainSliderValue = 0.94;
  
  // Dummy devices to match the mockup exactly
  final List<Map<String, dynamic>> _devices = [
    {
      'title': 'Smart light 1',
      'subtitle': 'Active until 06:00 am',
      'value': '94%',
      'icon': Icons.wb_sunny_outlined,
      'isActive': true,
    },
    {
      'title': 'Smart light 2',
      'subtitle': 'Active until 06:00 am',
      'value': '28%',
      'icon': Icons.wb_sunny_outlined,
      'isActive': false,
    },
    {
      'title': 'Air Conditioner',
      'subtitle': 'Cooling mode',
      'value': '16°C',
      'icon': Icons.air_rounded,
      'isActive': false,
    },
    {
      'title': 'Smart Timer',
      'subtitle': 'Next schedule',
      'value': '05:40',
      'icon': Icons.timer_outlined,
      'isActive': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: Stack(
        children: [
          // Background Room Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.sizeOf(context).height * 0.65,
            child: Image.asset(
              widget.room.imagePath,
              fit: BoxFit.cover,
            ),
          ),
          
          // Subtle gradient overlay to ensure text is readable
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 150,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Header (Back, Title, Options)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                Text(
                  widget.room.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                _buildCircleButton(
                  icon: Icons.more_vert_rounded,
                  onTap: () {},
                ),
              ],
            ),
          ),

          // Vertical Main Slider
          Positioned(
            top: MediaQuery.sizeOf(context).height * 0.25,
            right: 24,
            child: _buildVerticalSlider(),
          ),

          // Bottom Sheet (Devices)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.sizeOf(context).height * 0.45,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Header text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Device',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Change',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Devices Grid
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.1,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _devices.length,
                      itemBuilder: (context, index) {
                        return _buildDeviceCard(_devices[index]);
                      },
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

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white.withValues(alpha: 0.2),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalSlider() {
    return Container(
      width: 70,
      height: 220,
      decoration: BoxDecoration(
        color: AppTheme.backgroundPrimary.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Active Track
          FractionallySizedBox(
            heightFactor: _mainSliderValue,
            widthFactor: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBackground.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(35),
              ),
            ),
          ),
          // Thumb/Icon
          Positioned(
            bottom: (_mainSliderValue * 220) - 45, // approximate center
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                setState(() {
                  _mainSliderValue -= details.delta.dy / 220;
                  _mainSliderValue = _mainSliderValue.clamp(0.0, 1.0);
                });
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.5),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: const Icon(Icons.wb_sunny_outlined, color: AppTheme.backgroundPrimary),
              ),
            ),
          ),
          // Percentage Text
          Positioned(
            bottom: 20,
            child: Text(
              '${(_mainSliderValue * 100).toInt()}%',
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    final bool isActive = device['isActive'];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundPrimary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device['value'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isActive ? AppTheme.primary : Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.primary : AppTheme.cardBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  device['icon'],
                  color: isActive ? AppTheme.backgroundPrimary : Colors.white.withValues(alpha: 0.5),
                  size: 20,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device['title'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                device['subtitle'],
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
