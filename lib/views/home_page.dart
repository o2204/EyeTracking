import 'package:flutter/material.dart';

import '../controllers/devices_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/room_controller.dart';
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
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
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
                    icon: Icons.home_outlined,
                    isSelected: _controller.selectedTab == 0,
                    onTap: () => setState(() => _controller.selectTab(0)),
                    theme: theme,
                  ),
                  const SizedBox(width: 60),
                  _buildNavItem(
                    icon: Icons.person_outline,
                    isSelected: _controller.selectedTab == 2,
                    onTap: () => setState(() => _controller.selectTab(2)),
                    theme: theme,
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                top: -25,
                child: Center(
                  child: GestureDetector(
                    onTap: () => setState(() => _controller.selectTab(1)),
                    child: Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.mic_none,
                        color: _controller.selectedTab == 1
                            ? theme.primaryColor
                            : theme.disabledColor,
                        size: 28,
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
