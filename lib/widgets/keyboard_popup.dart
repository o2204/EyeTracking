import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../theme/app_theme.dart';

class GazeKeyboardPopup extends StatefulWidget {
  const GazeKeyboardPopup({super.key});

  @override
  State<GazeKeyboardPopup> createState() => _GazeKeyboardPopupState();
}

class _GazeKeyboardPopupState extends State<GazeKeyboardPopup> {
  String text = "";
  final FlutterTts tts = FlutterTts();
  bool isShifted = false;

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

  Future<void> _initTts() async {
    await tts.setLanguage("en-US");
    await tts.setPitch(1.0);
    await tts.setSpeechRate(0.5);
  }

  void speak() async {
    if (text.isNotEmpty) {
      await tts.speak(text);
    }
  }

  void stopSpeech() async {
    await tts.stop();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        height: size.height,
        width: size.width,
        color: theme.scaffoldBackgroundColor.withOpacity(0.95),
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
        border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.3), width: 2),
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
        _buildToolbarItem("SPEAK", theme.primaryColor, Icons.volume_up_rounded, speak, flex: 2),
        _buildToolbarItem("STOP", Colors.deepPurpleAccent, Icons.stop_rounded, stopSpeech, flex: 2),
        const SizedBox(width: 8),
        _buildToolbarItem("Wrd ←", Colors.blueGrey, null, () {}),
        _buildToolbarItem("Wrd →", Colors.blueGrey, null, () {}),
        _buildToolbarItem("Snt ←", Colors.blueGrey, null, () {}),
        _buildToolbarItem("Snt →", Colors.blueGrey, null, () {}),
        const SizedBox(width: 8),
        _buildToolbarItem("CLEAR", Colors.redAccent, Icons.clear_all_rounded, clearText, flex: 1),
        _buildToolbarItem("DEL WRD", Colors.redAccent, Icons.delete_sweep_rounded, deleteWord, flex: 2),
        _buildToolbarItem("BKSP", Colors.red, Icons.backspace_rounded, backspace, flex: 2),
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
                child: _buildKeyButton(isShifted ? key.toUpperCase() : key, theme.cardColor, theme.textTheme.bodyLarge?.color?.withOpacity(0.8), () => addLetter(key)),
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
        _buildToolbarItem("HOME", theme.colorScheme.secondary, Icons.home_rounded, () => Navigator.pop(context), flex: 2),
        _buildToolbarItem("SHIFT", theme.primaryColor, Icons.upload_rounded, () => setState(() => isShifted = !isShifted), flex: 1, isActive: isShifted),
        _buildToolbarItem("PHRASE", theme.colorScheme.secondary, Icons.favorite_rounded, () {}, flex: 2),
        _buildToolbarItem("TOOLS", theme.primaryColor, Icons.settings_rounded, () {}, flex: 1),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildKeyButton("Space", Colors.blueGrey.withOpacity(0.2), theme.disabledColor, () => addLetter(" ")),
          ),
        ),
        _buildToolbarItem("123", theme.primaryColor, Icons.numbers_rounded, () {}, flex: 2),
        _buildToolbarItem("PAUSE", theme.colorScheme.secondary, Icons.pause_rounded, () {}, flex: 2),
      ],
    );
  }

  Widget _buildToolbarItem(String label, Color color, IconData? icon, VoidCallback onTap, {int flex = 1, bool isActive = false}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: isActive ? color : color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.4), width: 1.5),
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
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
