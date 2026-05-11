import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/websocket_service.dart';
import '../routes/app_routes.dart';

class CameraStreamingScreen extends StatefulWidget {
  const CameraStreamingScreen({super.key});

  @override
  State<CameraStreamingScreen> createState() => _CameraStreamingScreenState();
}

class _CameraStreamingScreenState extends State<CameraStreamingScreen> {
  CameraController? _controller;
  final WebSocketService _wsService = WebSocketService();
  Timer? _timer;
  String _result = 'Waiting for results...';
  bool _isStreaming = false;
  StreamSubscription? _wsSubscription;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeConnection();
    _wsSubscription = _wsService.stream.listen(
      (event) {
        if (mounted) {
          setState(() => _result = event.toString());
        }
      },
      onError: (error) {
        if (mounted) setState(() => _result = 'Connection error');
      },
    );
  }

  Future<void> _initializeConnection() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    _wsService.connect(token);
  }

  Future<void> _initializeCamera() async {
    List<CameraDescription> cameras;
    try {
      cameras = await availableCameras();
    } catch (e) {
      if (mounted) setState(() => _result = 'Camera unavailable: $e');
      return;
    }

    if (cameras.isEmpty) {
      if (mounted) setState(() => _result = 'No cameras found');
      return;
    }

    // Prefer front camera for eye tracking
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset.low, // LOW = much lighter; medium was overkill for WS streaming
      enableAudio: false,   // No audio needed — removes audio permission overhead
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
    } catch (e) {
      if (mounted) setState(() => _result = 'Camera init error: $e');
      return;
    }

    if (!mounted) return;
    setState(() => _isStreaming = true);

    // 500ms interval → 2 fps is fine for eye-tracking AI inference.
    // Using captureImage instead of takePicture avoids saving files to disk.
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      if (_controller == null || !_controller!.value.isInitialized) return;
      try {
        final XFile file = await _controller!.takePicture();
        final bytes = await file.readAsBytes();
        _wsService.sendBytes(bytes);
      } catch (_) {
        // Silently skip failed frames — camera may be temporarily busy
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _wsSubscription?.cancel();
    _controller?.dispose();
    _wsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isStreaming || _controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF00E5C8)),
              const SizedBox(height: 16),
              Text(
                _result,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('AI Camera Stream'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: CameraPreview(_controller!)),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black87,
            width: double.infinity,
            child: Text(
              _result,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
