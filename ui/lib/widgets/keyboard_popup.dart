import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../theme/app_theme.dart';

bool isTtsSupported() {
  return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
}

class GazeKeyboardPopup extends StatefulWidget {
  const GazeKeyboardPopup({super.key});

  @override
  State<GazeKeyboardPopup> createState() => _GazeKeyboardPopupState();
}

class _GazeKeyboardPopupState extends State<GazeKeyboardPopup> {
  String text = "";
  FlutterTts? tts;
  bool isShifted = false;
  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;

  final List<List<String>> qwertyRows = [
    ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
    ["a", "s", "d", "f", "g", "h", "j", "k", "l", ""],
    ["z", "x", "c", "v", "b", "n", "m", ",", ".", "?"],
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    tts?.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    if (isTtsSupported()) {
      tts = FlutterTts();
      await tts?.setLanguage("en-US");
      await tts?.setPitch(1.0);
      await tts?.setSpeechRate(0.5);
    }
  }

  void speak() async {
    if (text.isNotEmpty) await tts?.speak(text);
  }

  void stopSpeech() async {
    await tts?.stop();
  }

  void addLetter(String letter) {
    setState(() {
      final actualLetter = isShifted ? letter.toUpperCase() : letter.toLowerCase();
      text += actualLetter;
    });
  }

  void deleteWord() {
    if (text.isNotEmpty) {
      setState(() {
        List<String> words = text.trimRight().split(" ");
        if (words.length > 1) {
          words.removeLast();
          text = "${words.join(" ")} ";
        } else {
          text = "";
        }
      });
    }
  }

  void backspace() {
    if (text.isNotEmpty) {
      setState(() {
        text = text.substring(0, text.length - 1);
      });
    }
  }

  void clearText() {
    setState(() {
      text = "";
    });
  }

  // ─── Audio Upload / Record Sheet ───────────────────────────
  void _showAudioSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 40,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.audiotrack_rounded, color: AppTheme.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Audio Input', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        Text('Upload a file or record your voice', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Upload File ──
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    _simulateFileUpload();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.accent.withValues(alpha: 0.25)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.upload_file_rounded, color: AppTheme.accent, size: 28),
                        SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Upload Audio File', style: TextStyle(color: AppTheme.accent, fontSize: 15, fontWeight: FontWeight.w700)),
                            Text('MP3, WAV, M4A supported', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.accent, size: 14),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Record ──
                GestureDetector(
                  onTap: () {
                    if (!_isRecording) {
                      setModalState(() {});
                      _startRecording(setModalState);
                    } else {
                      _stopRecording();
                      Navigator.pop(ctx);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _isRecording
                          ? Colors.redAccent.withValues(alpha: 0.12)
                          : AppTheme.primary.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isRecording
                            ? Colors.redAccent.withValues(alpha: 0.4)
                            : AppTheme.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isRecording ? Icons.stop_circle_rounded : Icons.mic_rounded,
                          color: _isRecording ? Colors.redAccent : AppTheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isRecording ? 'Stop Recording' : 'Record Voice',
                              style: TextStyle(
                                color: _isRecording ? Colors.redAccent : AppTheme.primary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              _isRecording
                                  ? '${_formatTime(_recordSeconds)} — tap to stop'
                                  : 'Tap to start recording',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (_isRecording)
                          _buildRecordingDot(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecordingDot() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (_, val, __) => Opacity(
        opacity: val,
        child: Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  void _startRecording(StateSetter setModalState) {
    setState(() => _isRecording = true);
    _recordSeconds = 0;
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _recordSeconds++);
        setModalState(() {});
      }
    });
  }

  void _stopRecording() {
    _recordTimer?.cancel();
    setState(() => _isRecording = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Recording saved (${_formatTime(_recordSeconds)})'),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _simulateFileUpload() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📁 Audio file uploaded successfully'),
        backgroundColor: AppTheme.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ─── Emergency SOS ────────────────────────────────────────
  void _showEmergencyDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.redAccent, size: 28),
            SizedBox(width: 10),
            Text('Emergency Alert', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900)),
          ],
        ),
        content: const Text(
          'This will immediately notify the admin and medical staff.\n\nAre you sure?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _triggerSOS();
            },
            child: const Text(
              '🚨 SEND SOS',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _triggerSOS() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.sos_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text('🚨 Emergency Alert Sent! Help is on the way.',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        height: size.height,
        width: size.width,
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTopDisplay(theme),
            const SizedBox(height: 12),
            _buildPredictionRow(theme),
            const SizedBox(height: 12),
            _buildToolbarRow(theme),
            const SizedBox(height: 12),
            Expanded(child: _buildQwertyGrid(theme)),
            const SizedBox(height: 12),
            _buildControlRow(theme),
            const SizedBox(height: 10),
            _buildSpecialActionsRow(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTopDisplay(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.3), width: 2),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: theme.textTheme.bodyLarge?.color,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildPredictionRow(ThemeData theme) {
    final predictions = ["I", "I'm", "I'll", "Yes", "No", "Thanks"];
    return Row(
      children: predictions.map((p) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _buildKeyButton(p, theme.cardColor, theme.primaryColor, () => setState(() => text += "$p ")),
        ),
      )).toList(),
    );
  }

  Widget _buildToolbarRow(ThemeData theme) {
    return Row(
      children: [
        _buildToolbarItem("SPEAK", AppTheme.primary, Icons.volume_up_rounded, speak, flex: 2),
        _buildToolbarItem("STOP", AppTheme.accent, Icons.stop_rounded, stopSpeech, flex: 2),
        const SizedBox(width: 8),
        _buildToolbarItem("Wrd ←", AppTheme.textSecondary, null, () {}),
        _buildToolbarItem("Wrd →", AppTheme.textSecondary, null, () {}),
        _buildToolbarItem("Snt ←", AppTheme.textSecondary, null, () {}),
        _buildToolbarItem("Snt →", AppTheme.textSecondary, null, () {}),
        const SizedBox(width: 8),
        _buildToolbarItem("CLEAR", AppTheme.textError, Icons.clear_all_rounded, clearText, flex: 1),
        _buildToolbarItem("DEL WRD", AppTheme.textError, Icons.delete_sweep_rounded, deleteWord, flex: 2),
        _buildToolbarItem("BKSP", AppTheme.textError, Icons.backspace_rounded, backspace, flex: 2),
      ],
    );
  }

  Widget _buildQwertyGrid(ThemeData theme) {
    return Column(
      children: qwertyRows.map((row) => Expanded(
        child: Row(
          children: row.map((key) {
            if (key.isEmpty) return Expanded(child: Container());
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: _buildKeyButton(
                  isShifted ? key.toUpperCase() : key,
                  theme.cardColor,
                  theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
                  () => addLetter(key),
                ),
              ),
            );
          }).toList(),
        ),
      )).toList(),
    );
  }

  Widget _buildControlRow(ThemeData theme) {
    return Row(
      children: [
        _buildToolbarItem("HOME", AppTheme.textSecondary, Icons.home_rounded,
            () => Navigator.pop(context), flex: 2),
        _buildToolbarItem("SHIFT", AppTheme.primary, Icons.upload_rounded,
            () => setState(() => isShifted = !isShifted), flex: 1, isActive: isShifted),
        _buildToolbarItem("PHRASE", AppTheme.textSecondary, Icons.favorite_rounded, () {}, flex: 2),
        _buildToolbarItem("TOOLS", AppTheme.primary, Icons.settings_rounded, () {}, flex: 1),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildKeyButton(
                "Space", AppTheme.cardBackground, theme.disabledColor, () => addLetter(" ")),
          ),
        ),
        _buildToolbarItem("123", AppTheme.primary, Icons.numbers_rounded, () {}, flex: 2),
        _buildToolbarItem("PAUSE", AppTheme.textSecondary, Icons.pause_rounded, () {}, flex: 2),
      ],
    );
  }

  // ─── NEW: Special Actions Row ─────────────────────────────
  Widget _buildSpecialActionsRow(ThemeData theme) {
    return Row(
      children: [
        // Audio Upload / Record button
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: _showAudioSheet,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.15),
                    AppTheme.accent.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isRecording
                      ? Colors.redAccent.withValues(alpha: 0.7)
                      : AppTheme.primary.withValues(alpha: 0.4),
                  width: 1.8,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isRecording ? Icons.fiber_manual_record : Icons.mic_rounded,
                    color: _isRecording ? Colors.redAccent : AppTheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isRecording ? '● RECORDING' : 'AUDIO',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: _isRecording ? Colors.redAccent : AppTheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        _isRecording ? _formatTime(_recordSeconds) : 'Upload or Record',
                        style: TextStyle(
                          fontSize: 10,
                          color: _isRecording
                              ? Colors.redAccent.withValues(alpha: 0.8)
                              : AppTheme.primary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Emergency / SOS button
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: _showEmergencyDialog,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.redAccent.withValues(alpha: 0.2),
                    Colors.red.shade900.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.6), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sos_rounded, color: Colors.redAccent, size: 26),
                  SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EMERGENCY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.redAccent,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Send SOS Alert',
                        style: TextStyle(fontSize: 10, color: Colors.redAccent, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbarItem(String label, Color color, IconData? icon, VoidCallback onTap,
      {int flex = 1, bool isActive = false}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: isActive ? color : color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) Icon(icon, color: isActive ? Colors.white : color, size: 20),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isActive ? Colors.white : color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyButton(String label, Color bgColor, Color? textColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: textColor),
        ),
      ),
    );
  }
}
