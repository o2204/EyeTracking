import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/websocket_service.dart';

class CameraStreamingScreen extends StatefulWidget {
  const CameraStreamingScreen({super.key});

  @override
  State<CameraStreamingScreen> createState() => _CameraStreamingScreenState();
}

class _CameraStreamingScreenState extends State<CameraStreamingScreen> {
  CameraController? _controller;
  final WebSocketService _wsService = WebSocketService();
  Timer? _timer;
  String _result = "Waiting for results...";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _wsService.connect();
    _wsService.stream.listen((event) {
      setState(() {
        _result = event.toString();
      });
    });
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(cameras.first, ResolutionPreset.medium);
    await _controller!.initialize();
    if (!mounted) return;

    setState(() {});

    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      if (_controller != null && _controller!.value.isInitialized) {
        try {
          final XFile file = await _controller!.takePicture();
          final bytes = await file.readAsBytes();
          _wsService.sendBytes(bytes);
        } catch (e) {
          print("Error capturing frame: $e");
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    _wsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('AI Camera Stream')),
      body: Column(
        children: [
          Expanded(
            child: CameraPreview(_controller!),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black.withAlpha(200),
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
