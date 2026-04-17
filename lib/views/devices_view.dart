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
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.82,
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
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: widget.onBackPressed,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.chevron_left_rounded,
                color: theme.colorScheme.secondary,
                size: 28,
              ),
            ),
          ),
          Text(
            'Connected Devices',
            style: TextStyle(
              fontSize: 22,
              color: theme.textTheme.bodyLarge?.color,
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
    void toggleDevice() {
      setState(() {
        widget.controller.toggleDevice(index);
      });
    }

    return GestureDetector(
      onTap: toggleDevice,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: device.isOn
              ? theme.primaryColor.withOpacity(0.04)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: device.isOn 
                ? theme.primaryColor.withOpacity(0.2) 
                : theme.dividerColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: device.isOn 
                  ? theme.primaryColor.withOpacity(0.1) 
                  : Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: device.isOn ? theme.primaryColor : theme.dividerColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  device.icon,
                  color: device.isOn ? Colors.white : theme.disabledColor,
                  size: 24,
                ),
              ),
              const Spacer(),
              Text(
                device.name,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    device.isOn ? 'Active' : 'Standby',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: device.isOn
                          ? theme.primaryColor
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
    );
  }
}
