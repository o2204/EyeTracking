import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../controllers/room_controller.dart';
import '../models/room_data.dart';
import '../widgets/animated_toggle_button.dart';

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

class _RoomViewState extends State<RoomView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            const SizedBox(height: 16),
            _buildAnimatedWelcomeText(theme),
            const SizedBox(height: 28),
            _buildTabSelector(theme),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                itemCount: widget.controller.rooms.length,
                separatorBuilder: (_, __) => const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  return _buildRoomCard(widget.controller.rooms[index], theme);
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
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline_rounded,
            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
            size: 30,
          ),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              children: [
                TextSpan(
                  text: 'Hi! ',
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                  ),
                ),
                TextSpan(
                  text: 'User',
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              themeModeNotifier.value = themeModeNotifier.value == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
            child: ValueListenableBuilder<ThemeMode>(
              valueListenable: themeModeNotifier,
              builder: (context, mode, _) {
                final isDarkNow = mode == ThemeMode.dark;
                return Icon(
                  isDarkNow ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
                  size: 28,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedWelcomeText(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primaryColor.withOpacity(0.08),
              theme.primaryColor.withOpacity(0.02)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.primaryColor.withOpacity(0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.remove_red_eye_rounded, size: 16, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'EYE INTELLIGENT SYSTEM',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.secondary,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DefaultTextStyle(
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9),
                fontFamily: 'Outfit',
                height: 1.3,
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Ready for tracking...',
                    speed: const Duration(milliseconds: 100),
                  ),
                  TypewriterAnimatedText(
                    'Environment Optimized.',
                    speed: const Duration(milliseconds: 100),
                  ),
                  TypewriterAnimatedText(
                    'Welcome Home.',
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                isRepeatingAnimation: true,
                pause: const Duration(milliseconds: 1000),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 56,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: theme.dividerColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Rooms',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: theme.colorScheme.secondary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: widget.onDevicesTabSelected,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Devices',
                    style: TextStyle(
                      color: theme.disabledColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(RoomData room, ThemeData theme) {
    void toggleRoom() {
      setState(() {
        widget.controller.toggleRoom(room);
      });
    }

    return GestureDetector(
      onTap: toggleRoom,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuart,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: theme.cardColor,
          border: Border.all(
            color: room.isOn ? theme.primaryColor.withOpacity(0.5) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: room.isOn 
                  ? theme.primaryColor.withOpacity(0.2) 
                  : Colors.black.withOpacity(0.05),
              blurRadius: 24,
              spreadRadius: room.isOn ? 4 : 0,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(room.imagePath),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(room.isOn ? 0.2 : 0.6),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
            ),
            // Premium Glassmorphism Overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(26),
                  bottomRight: Radius.circular(26),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          theme.scaffoldBackgroundColor.withOpacity(0.85),
                          theme.scaffoldBackgroundColor.withOpacity(0.4),
                        ],
                      ),
                      border: Border(
                        top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              room.name,
                              style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: room.isOn 
                                    ? theme.primaryColor.withOpacity(0.15)
                                    : theme.dividerColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.devices_other_rounded, 
                                    size: 14, 
                                    color: room.isOn ? theme.primaryColor : theme.disabledColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${room.deviceCount} Active Devices',
                                    style: TextStyle(
                                      color: room.isOn ? theme.primaryColor : theme.disabledColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              room.isOn ? 'ON' : 'OFF',
                              style: TextStyle(
                                color: room.isOn ? theme.primaryColor : theme.disabledColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 14),
                            AnimatedToggleButton(
                              isOn: room.isOn,
                              onTap: toggleRoom,
                            ),
                          ],
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
    );
  }
}
