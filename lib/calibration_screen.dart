import 'package:flutter/material.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  int activeDot = 0;

  void nextDot() {
    if (activeDot < 8) {
      setState(() {
        activeDot++;
      });
    } else {
      // خلص calibration
      print("Calibration Done");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: nextDot, // مؤقتًا tap بدل eye tracking
        child: Stack(
          children: List.generate(9, (index) {
            return _buildDot(index);
          }),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final positions = [
      Alignment.topLeft,
      Alignment.topCenter,
      Alignment.topRight,
      Alignment.centerLeft,
      Alignment.center,
      Alignment.centerRight,
      Alignment.bottomLeft,
      Alignment.bottomCenter,
      Alignment.bottomRight,
    ];

    final isActive = index == activeDot;

    return Align(
      alignment: positions[index],
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
          width: isActive ? 40 : 20,
          height: isActive ? 40 : 20,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey.shade400,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
        ),
      ),
    );
  }
}
