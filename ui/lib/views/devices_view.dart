import 'package:flutter/material.dart';

import '../controllers/devices_controller.dart';
import '../models/device_data.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_toggle_button.dart';

class DevicesView extends StatefulWidget {
  final DevicesController controller;
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeToggle;
  final VoidCallback? onBackPressed;

  const DevicesView({
    super.key,
    required this.controller,
    required this.isDarkMode,
    required this.onDarkModeToggle,
    this.onBackPressed,
  });

  @override
  State<DevicesView> createState() => _DevicesViewState();
}

class _DevicesViewState extends State<DevicesView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.globalBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(theme),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: widget.controller.devices.length,
                  itemBuilder: (context, index) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 350 + (index * 80)),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: _buildDeviceCard(
                        widget.controller.devices[index],
                        index,
                        theme,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: widget.onBackPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.cardColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const Text(
            'Connected Devices',
            style: TextStyle(
              fontSize: 22,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 44), // Spacer for balance
        ],
      ),
    );
  }

  Widget _buildDeviceCard(DeviceData device, int index, ThemeData theme) {
    // Map device properties based on index
    String title = device.name;
    String subtitle = 'Living Room';
    String imagePath;
    Color switchColor;
    Color cardColor;
    double imgWidth = 150;
    double imgHeight = 150;
    double imgRight = -8;
    double imgBottom = -8;
    
    switch (title.toLowerCase()) {
      case 'ac':
        title = 'Smart AC';
        imagePath = 'assets/images/AC.png';
        imgWidth = 170;
        imgHeight = 110;
        imgRight = 5;
        imgBottom = 15;
        break;
      case 'lights':
        title = 'Smart Lamp';
        imagePath = 'assets/images/lamp.png';
        imgRight = 10;
        imgBottom = 10;
        break;
      case 'fan':
        title = 'Smart Fan';
        imagePath = 'assets/images/fan.png';
        imgWidth = 135;
        imgHeight = 135;
        imgRight = 10;
        imgBottom = 10;
        break;
      case 'tv':
        title = 'Smart TV';
        imagePath = 'assets/images/TV.png';
        imgWidth = 180;
        imgHeight = 120;
        imgRight = 5;
        imgBottom = 15;
        break;
      default:
        imagePath = 'assets/images/lamp.png';
    }
    
    switchColor = AppTheme.primary;
    cardColor = AppTheme.cardBackground;

    void toggleDevice() {
      setState(() {
        widget.controller.toggleDevice(index);
      });
    }

    return GestureDetector(
      onTap: toggleDevice,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            border: Border.all(
              color: device.isOn ? AppTheme.primary.withValues(alpha: 0.3) : AppTheme.inputBorder,
              width: 1.5,
            ),
            boxShadow: device.isOn ? AppTheme.cardGlow : AppTheme.softShadow,
          ),
          child: Stack(
            children: [
              // Device Image at Bottom Right
              Positioned(
                right: imgRight,
                bottom: imgBottom,
                width: imgWidth, 
                height: imgHeight,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                ),
              ),
              
              // Content (Text & Switch)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Vertical Custom Switch
                    GestureDetector(
                      onTap: toggleDevice,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 26,
                        height: 48,
                        decoration: BoxDecoration(
                          color: device.isOn ? switchColor : switchColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutBack,
                          alignment: device.isOn ? Alignment.topCenter : Alignment.bottomCenter,
                          child: Container(
                            margin: const EdgeInsets.all(3),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppTheme.textPrimary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
