import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

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
            _buildAnimatedWelcomeText(theme),
            _buildTabSelector(theme),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: widget.controller.rooms.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
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
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: theme.dividerColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(Icons.person, color: theme.disabledColor),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Hi! ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                    fontSize: 24,
                  ),
                ),
                TextSpan(
                  text: 'User',
                  style: TextStyle(
                    fontWeight: FontWeight.w200,
                    color: theme.primaryColor,
                    fontSize: 20,
                  ),
                ),
              ],
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
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

  Widget _buildAnimatedWelcomeText(ThemeData theme) {
    return SizedBox(
      width: 250,
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: 20,
          fontFamily: 'Agne',
          color: theme.primaryColor,
        ),
        child: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              'Welcome in Eye Intelligent',
              speed: const Duration(milliseconds: 200),
            ),
          ],
          isRepeatingAnimation: true,
        ),
      ),
    );
  }

  Widget _buildTabSelector(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Room',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: widget.onDevicesTabSelected,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Devices',
                    style: TextStyle(
                      color: theme.disabledColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: toggleRoom,
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: theme.cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: AssetImage(room.imagePath),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(room.isOn ? 0.2 : 0.4),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.cardColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.more_vert,
                    color: theme.disabledColor,
                    size: 20,
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${room.deviceCount} Devices',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                            shadows: [
                              Shadow(
                                blurRadius: 5,
                                color: Colors.black.withOpacity(0.3),
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
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                blurRadius: 8,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        AnimatedToggleButton(
                          isOn: room.isOn,
                          onTap: toggleRoom,
                        ),
                      ],
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
