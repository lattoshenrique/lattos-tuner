import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:lattos_tuner/views/theme.dart';

/// Medidor em arco com ponteiro animado e escala de cents (-50 a +50).
///
/// As marcas da escala "acendem" progressivamente entre o zero e a posição
/// atual do ponteiro, com brilho na cor do estado de afinação.
class TunerGauge extends StatelessWidget {
  const TunerGauge({
    super.key,
    required this.cents,
    required this.color,
    this.active = true,
  });

  /// Desvio atual em cents, ou null quando não há leitura.
  final double? cents;

  /// Cor do ponteiro e das marcas acesas (cor do estado de afinação).
  final Color color;

  /// Se falso, o medidor inteiro fica esmaecido (ex.: microfone desligado).
  final bool active;

  @override
  Widget build(BuildContext context) {
    final target = (cents ?? 0.0).clamp(-50.0, 50.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: target),
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      builder: (context, animatedCents, _) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          opacity: active ? 1.0 : 0.35,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: cents == null ? 0.0 : 1.0),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            builder: (context, liveness, _) => CustomPaint(
              painter: _GaugePainter(
                cents: animatedCents,
                color: color,
                liveness: liveness,
              ),
              child: const AspectRatio(aspectRatio: 1.7),
            ),
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.cents,
    required this.color,
    required this.liveness,
  });

  final double cents;
  final Color color;

  /// 0 = ocioso (ponteiro apagado no centro), 1 = leitura ativa.
  final double liveness;

  static const double _sweepDegrees = 70.0;

  double _angleForCents(double value) =>
      -math.pi / 2 + (value / 50.0) * (_sweepDegrees * math.pi / 180.0);

  @override
  void paint(Canvas canvas, Size size) {
    final pivot = Offset(size.width / 2, size.height * 0.98);
    final radius = math.min(size.height * 0.92, size.width * 0.46);
    final startAngle = _angleForCents(-50);
    final sweep = _angleForCents(50) - startAngle;

    // Trilho do arco.
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.07);
    final arcRect = Rect.fromCircle(center: pivot, radius: radius);
    canvas.drawArc(arcRect, startAngle - math.pi / 2, sweep, false, track);

    // Zona "afinado" (±5 cents) destacada no trilho.
    final zone = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = AppColors.mint.withValues(alpha: 0.5);
    canvas.drawArc(
      arcRect,
      _angleForCents(-5) - math.pi / 2,
      _angleForCents(5) - _angleForCents(-5),
      false,
      zone,
    );

    // Marcas da escala, acesas entre 0 e a posição do ponteiro.
    for (var value = -50; value <= 50; value += 5) {
      final isMajor = value % 25 == 0;
      final angle = _angleForCents(value.toDouble());
      final direction = Offset(math.sin(angle), -math.cos(angle));
      final outer = pivot + direction * (radius - 12);
      final inner = pivot + direction * (radius - (isMajor ? 30.0 : 22.0));
      final lit = liveness > 0 &&
          ((cents >= 0 && value >= 0 && value <= cents) ||
              (cents < 0 && value <= 0 && value >= cents));
      final tick = Paint()
        ..strokeWidth = isMajor ? 3.4 : 2.2
        ..strokeCap = StrokeCap.round
        ..color = lit
            ? color.withValues(alpha: 0.55 + 0.45 * liveness)
            : Colors.white.withValues(alpha: isMajor ? 0.28 : 0.14);
      if (lit) {
        tick.maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.solid, 2.5);
      }
      canvas.drawLine(inner, outer, tick);
    }

    // Rótulos da escala.
    _drawLabel(canvas, pivot, radius + 20, _angleForCents(-50), '♭');
    _drawLabel(canvas, pivot, radius + 20, _angleForCents(0), '0');
    _drawLabel(canvas, pivot, radius + 20, _angleForCents(50), '♯');

    // Ponteiro com brilho.
    final needleAngle = _angleForCents(cents);
    final needleDirection =
        Offset(math.sin(needleAngle), -math.cos(needleAngle));
    final needleEnd = pivot + needleDirection * (radius - 36);
    final needleColor =
        Color.lerp(Colors.white.withValues(alpha: 0.25), color, liveness)!;
    final glow = Paint()
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..color = needleColor.withValues(alpha: 0.35 * liveness)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8);
    canvas.drawLine(pivot, needleEnd, glow);
    final needle = Paint()
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..color = needleColor;
    canvas.drawLine(pivot, needleEnd, needle);

    // Pivô.
    canvas.drawCircle(
      pivot,
      7,
      Paint()..color = needleColor,
    );
    canvas.drawCircle(
      pivot,
      3,
      Paint()..color = AppColors.background,
    );
  }

  void _drawLabel(
    Canvas canvas,
    Offset pivot,
    double distance,
    double angle,
    String text,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.45),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final position = pivot +
        Offset(math.sin(angle), -math.cos(angle)) * distance -
        Offset(painter.width / 2, painter.height / 2);
    painter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.cents != cents ||
      oldDelegate.color != color ||
      oldDelegate.liveness != liveness;
}
