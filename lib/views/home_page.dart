import 'package:flutter/material.dart';

import '../controllers/devices_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/room_controller.dart';
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
      body: _getCurrentPage(),
      bottomNavigationBar: _buildCustomBottomNavigationBar(),
    );
  }

  Widget _getCurrentPage() {
    switch (_controller.selectedTab) {
      case 0:
        return RoomView(
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
          isDarkMode: widget.isDarkMode,
          onDarkModeToggle: widget.onDarkModeToggle,
        );
      default:
        return RoomView(
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
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, -10),
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
                        gradient: LinearGradient(
                          colors: [theme.primaryColor, theme.colorScheme.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
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
      child: Icon(
        icon,
        color: isSelected ? theme.primaryColor : theme.disabledColor,
        size: 28,
      ),
    );
  }
}
