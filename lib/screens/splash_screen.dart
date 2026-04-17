import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();

    // Total duration for the 9 dots sequence
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    // Create 9 staggered animations (3x3 grid)
    const int dotCount = 9;
    const double intervalStep = 1.0 / dotCount;

    for (int i = 0; i < dotCount; i++) {
      final double start = i * intervalStep * 0.8; // Overlap slightly for smoothness
      final double end = math.min(start + intervalStep * 1.5, 1.0);

      _animations.add(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutBack),
        ),
      );
    }

    _controller.forward();

    // Navigate to Login after animation
    Timer(const Duration(milliseconds: 3800), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // As per image
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
          padding: const EdgeInsets.all(40),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 60,
              mainAxisSpacing: 60,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              return CalibrationDot(
                animation: _animations[index],
              );
            },
          ),
        ),
      ),
    );
  }
}

class CalibrationDot extends StatefulWidget {
  final Animation<double> animation;

  const CalibrationDot({
    super.key,
    required this.animation,
  });

  @override
  State<CalibrationDot> createState() => _CalibrationDotState();
}

class _CalibrationDotState extends State<CalibrationDot> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        final double value = widget.animation.value;
        
        // Flip Up rotation: -90 degrees to 0 degrees
        final double rotation = (1 - value) * -math.pi / 2;
        
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateX(rotation)
              ..scale(value),
            child: Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                transform: Matrix4.identity()
                  ..translate(0.0, _isHovered ? -12.0 : 0.0), // Moves up on hover
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.08),
                      blurRadius: _isHovered ? 20 : 10,
                      offset: Offset(0, _isHovered ? 12 : 4),
                      spreadRadius: _isHovered ? 4 : 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.black.withOpacity(0.03),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: _isHovered ? 12 : 8,
                    height: _isHovered ? 12 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isHovered 
                          ? const Color(0xFF10B981) // Turns Emerald Green when hovered
                          : Colors.black.withOpacity(0.02),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

