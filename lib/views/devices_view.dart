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
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.72,
                ),
                itemCount: widget.controller.devices.length,
                itemBuilder: (context, index) {
                  return _buildDeviceCard(
                    widget.controller.devices[index],
                    index,
                    theme,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: widget.onBackPressed,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: theme.dividerColor),
              ),
              child: Icon(
                Icons.arrow_back_ios,
                color: theme.disabledColor,
                size: 16,
              ),
            ),
          ),
          Text(
            'My Devices',
            style: TextStyle(
              fontSize: 24,
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () => widget.onDarkModeToggle(!widget.isDarkMode),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: theme.dividerColor),
              ),
              child: Icon(
                widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: theme.disabledColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(DeviceData device, int index, ThemeData theme) {
    void toggleDevice() {
      setState(() {
        widget.controller.toggleDevice(index);
      });
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: toggleDevice,
        child: Container(
          decoration: BoxDecoration(
            color: device.isOn
                ? AppColors.success.withOpacity(0.1)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: device.isOn
                        ? AppColors.success.withOpacity(0.2)
                        : theme.disabledColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    device.icon,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF001F3F),
                    size: 28,
                  ),
                ),
                const Spacer(),
                Text(
                  device.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to control',
                  style: TextStyle(fontSize: 12, color: theme.disabledColor),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      device.isOn ? 'ON' : 'OFF',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: device.isOn
                            ? AppColors.success
                            : theme.disabledColor,
                      ),
                    ),
                    AnimatedToggleButton(
                      isOn: device.isOn,
                      onTap: toggleDevice,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
