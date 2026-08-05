import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:lattos_tuner/views/theme.dart';

/// Fundo "aurora": manchas de luz desfocadas que derivam lentamente, com a
/// cor principal seguindo o estado de afinação.
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key, required this.accent});

  final Color accent;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: widget.accent),
        duration: const Duration(milliseconds: 700),
        builder: (context, accent, _) => AnimatedBuilder(
          animation: _drift,
          builder: (context, _) => CustomPaint(
            size: Size.infinite,
            painter: _AuroraPainter(
              t: _drift.value,
              accent: accent ?? widget.accent,
            ),
          ),
        ),
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter({required this.t, required this.accent});

  final double t;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final phase = 2 * math.pi * t;
    final paint = Paint()
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 80);

    paint.color = accent.withValues(alpha: 0.11);
    canvas.drawCircle(
      Offset(
        w * (0.30 + 0.16 * math.sin(phase)),
        h * (0.16 + 0.05 * math.cos(phase * 1.3)),
      ),
      w * 0.42,
      paint,
    );

    paint.color = AppColors.violet.withValues(alpha: 0.09);
    canvas.drawCircle(
      Offset(
        w * (0.78 - 0.14 * math.cos(phase * 0.7)),
        h * (0.30 + 0.07 * math.sin(phase)),
      ),
      w * 0.38,
      paint,
    );

    paint.color = accent.withValues(alpha: 0.05);
    canvas.drawCircle(
      Offset(w * (0.5 + 0.20 * math.sin(phase * 0.5 + 1.7)), h * 0.78),
      w * 0.5,
      paint,
    );
  }

  @override
  bool shouldRepaint(_AuroraPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.accent != accent;
}
