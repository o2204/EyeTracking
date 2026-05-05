import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animated robot mascot that reacts to password visibility.
///
/// - [isPasswordVisible] = false → arms up, eyes covered 🙈
/// - [isPasswordVisible] = true  → arms down, eyes open 👀
class MascotCharacter extends StatefulWidget {
  final bool isPasswordVisible;

  const MascotCharacter({
    super.key,
    required this.isPasswordVisible,
  });

  @override
  State<MascotCharacter> createState() => _MascotCharacterState();
}

class _MascotCharacterState extends State<MascotCharacter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  static const _hidingText  = 'حقل كلمة المرور مغلق\nأنا لا أنظر! 🙈';
  static const _peekingText = 'تم الضغط على زر الإظهار\nسأبقي نظرة معادا! 👀';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: widget.isPasswordVisible ? 1.0 : 0.0,
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(MascotCharacter old) {
    super.didUpdateWidget(old);
    if (widget.isPasswordVisible != old.isPasswordVisible) {
      widget.isPasswordVisible ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bubbleBg  = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final text = _anim.value < 0.5 ? _hidingText : _peekingText;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Speech bubble ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: bubbleBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                text,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: textColor,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
            // ── Bubble tail triangle ──
            CustomPaint(
              size: const Size(12, 6),
              painter: _TrianglePainter(color: bubbleBg),
            ),
            const SizedBox(height: 1),
            // ── Character ──
            CustomPaint(
              size: const Size(82, 102),
              painter: _MascotPainter(peek: _anim.value),
            ),
          ],
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Bubble-tail painter
// ──────────────────────────────────────────────────────────────────────────────
class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = AppTheme.primary.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}

// ──────────────────────────────────────────────────────────────────────────────
// Main mascot painter  (canvas 82 × 102)
// ──────────────────────────────────────────────────────────────────────────────
class _MascotPainter extends CustomPainter {
  /// 0 = hiding (eyes covered), 1 = peeking (eyes open)
  final double peek;

  const _MascotPainter({required this.peek});

  // ── Color palette matching the image ──
  static const _navy      = Color(0xFF1E293B); // Body color
  static const _vest      = Color(0xFFFEF3C7); // Light cream/gold vest
  static const _vestBorder = Color(0xFFD4A017); // Darker gold for vest trim
  static const _emerald   = Color(0xFF10B981); // Small badge/detail
  static const _cream     = Color(0xFFFFFFFF); // Eye whites / Gloves
  static const _black     = Color(0xFF0F172A); // Pupils

  @override
  void paint(Canvas canvas, Size size) {
    _drawBody(canvas, size);
    _drawEyes(canvas, size);
    _drawArms(canvas, size);
  }

  // ─── Body (Bean Shape + Vest) ──────────────────────────────────────────
  void _drawBody(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 10);
    
    // 1. Main Navy Body (Oval/Bean)
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 60, height: 80),
      const Radius.circular(30),
    );
    canvas.drawRRect(bodyRect, Paint()..color = _navy);

    // 2. The Vest (Cream color area)
    final vestPath = Path();
    vestPath.moveTo(center.dx - 30, center.dy - 10);
    vestPath.quadraticBezierTo(center.dx, center.dy - 20, center.dx + 30, center.dy - 10);
    vestPath.lineTo(center.dx + 30, center.dy + 30);
    vestPath.quadraticBezierTo(center.dx, center.dy + 40, center.dx - 30, center.dy + 30);
    vestPath.close();

    canvas.drawPath(vestPath, Paint()..color = _vest);
    canvas.drawPath(
      vestPath,
      Paint()
        ..color = _vestBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Vest zipper/center line
    canvas.drawLine(
      Offset(center.dx, center.dy - 15),
      Offset(center.dx, center.dy + 35),
      Paint()
        ..color = _vestBorder
        ..strokeWidth = 1.5,
    );

    // Small Emerald badge on the vest
    canvas.drawCircle(Offset(center.dx + 15, center.dy + 10), 4, Paint()..color = _emerald);
  }

  // ─── Eyes (Large & Expressive) ──────────────────────────────────────────
  void _drawEyes(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 15);
    const eyeSpacing = 12.0;
    
    // Only draw eyes if peek > 0 (they get revealed)
    if (peek > 0.1) {
      for (final sign in [-1, 1]) {
        final eyeCenter = Offset(center.dx + (sign * eyeSpacing), center.dy);
        
        // Eye White (Sclera)
        canvas.drawCircle(eyeCenter, 9 * peek, Paint()..color = _cream);
        
        // Pupil
        if (peek > 0.5) {
          canvas.drawCircle(eyeCenter, 4 * peek, Paint()..color = _black);
          // Highlight
          canvas.drawCircle(Offset(eyeCenter.dx - 2, eyeCenter.dy - 2), 1.5, Paint()..color = _cream);
        }
      }
    }
  }

  // ─── Arms (Interaction) ──────────────────────────────────────────────────
  void _drawArms(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 10);
    
    // Left Arm (Hider)
    canvas.save();
    canvas.translate(center.dx - 28, center.dy - 5);
    // Rotate arm to cover eyes when peek is low
    final leftRotation = math.pi * 0.7 * (1 - peek);
    canvas.rotate(leftRotation);
    
    // Arm segment
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-4, 0, 8, 20), const Radius.circular(4)),
      Paint()..color = _navy,
    );
    // Hand (White glove)
    canvas.drawCircle(const Offset(0, 22), 7, Paint()..color = _cream);
    canvas.restore();

    // Right Arm
    canvas.save();
    canvas.translate(center.dx + 28, center.dy - 5);
    final rightRotation = -math.pi * 0.1 * (1 - peek);
    canvas.rotate(rightRotation);
    
    // Arm segment
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-4, 0, 8, 20), const Radius.circular(4)),
      Paint()..color = _navy,
    );
    // Hand (White glove)
    canvas.drawCircle(const Offset(0, 22), 7, Paint()..color = _cream);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MascotPainter old) => old.peek != peek;
}
