import 'package:flutter/material.dart';

import '../controllers/devices_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/room_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/keyboard_popup.dart';
import 'devices_view.dart';
import 'profile_view.dart';
import 'room_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDarkMode = false;

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HomePage(
      isDarkMode: _isDarkMode,
      onDarkModeToggle: _toggleDarkMode,
    );
  }
}

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeToggle;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeToggle,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _controller = HomeController();
  final RoomController _roomController = RoomController();
  final DevicesController _devicesController = DevicesController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _getCurrentPage(),
      ),
      bottomNavigationBar: _buildCustomBottomNavigationBar(),
    );
  }

  Widget _getCurrentPage() {
    switch (_controller.selectedTab) {
      case 0:
        return RoomView(
          key: const ValueKey('rooms'),
          controller: _roomController,
          isDarkMode: widget.isDarkMode,
          onDarkModeToggle: widget.onDarkModeToggle,
          onDevicesTabSelected: () {
            setState(() {
              _controller.selectTab(1);
            });
          },
        );
      case 1:
        return DevicesView(
          key: const ValueKey('devices'),
          controller: _devicesController,
          isDarkMode: widget.isDarkMode,
          onDarkModeToggle: widget.onDarkModeToggle,
          onBackPressed: () {
            setState(() {
              _controller.selectTab(0);
            });
          },
        );
      case 2:
        return ProfileView(
          key: const ValueKey('profile'),
          isDarkMode: widget.isDarkMode,
          onDarkModeToggle: widget.onDarkModeToggle,
        );
      default:
        return RoomView(
          key: const ValueKey('rooms_default'),
          controller: _roomController,
          isDarkMode: widget.isDarkMode,
          onDarkModeToggle: widget.onDarkModeToggle,
          onDevicesTabSelected: () {
            setState(() {
              _controller.selectTab(1);
            });
          },
        );
    }
  }

  Widget _buildCustomBottomNavigationBar() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
        border: Border(
          top: BorderSide(
            color: AppTheme.primary.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.04),
            blurRadius: 40,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(
                    icon: Icons.grid_view_rounded,
                    isSelected: _controller.selectedTab == 0,
                    onTap: () => setState(() => _controller.selectTab(0)),
                    theme: theme,
                  ),
                  const SizedBox(width: 80),
                  _buildNavItem(
                    icon: Icons.person_rounded,
                    isSelected: _controller.selectedTab == 2,
                    onTap: () => setState(() => _controller.selectTab(2)),
                    theme: theme,
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                top: -30,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: "Keyboard",
                        pageBuilder: (context, _, __) => const GazeKeyboardPopup(),
                      );
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.primaryHover],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.15),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mic_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: isSelected ? AppTheme.primary : theme.disabledColor,
          size: 28,
        ),
      ),
    );
  }
}
