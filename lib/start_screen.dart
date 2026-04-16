import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'calibration_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  Future<void> _start(BuildContext context) async {
    var status = await Permission.camera.request();

    if (status.isGranted) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CalibrationScreen(),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Camera permission is required")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 50,
              vertical: 20,
            ),
          ),
          onPressed: () => _start(context),
          child: const Text(
            "start",
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
