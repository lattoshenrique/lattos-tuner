import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:lattos_tuner/controllers/tuner_controller.dart';
import 'package:lattos_tuner/views/theme.dart';

/// Medidor em arco com ponteiro animado e escala de cents (-50 a +50).
///
/// As marcas da escala "acendem" progressivamente entre o zero e a posição
/// atual do ponteiro, e as três faixas de tolerância (âmbar dos dois lados,
/// menta no centro) reagem quando o ponteiro entra nelas: engrossam, ganham
/// brilho, acendem um facho sob a ponta do ponteiro e — na faixa afinada —
/// passam a pulsar.
class TunerGauge extends StatefulWidget {
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
  State<TunerGauge> createState() => _TunerGaugeState();
}

class _TunerGaugeState extends State<TunerGauge>
    with SingleTickerProviderStateMixin {
  /// Respiração das faixas acesas.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = (widget.cents ?? 0.0).clamp(-50.0, 50.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: target),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (context, animatedCents, _) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          opacity: widget.active ? 1.0 : 0.35,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: widget.cents == null ? 0.0 : 1.0),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            builder: (context, liveness, _) => AnimatedBuilder(
              animation: _pulse,
              builder: (context, child) => CustomPaint(
                painter: _GaugePainter(
                  cents: animatedCents,
                  color: widget.color,
                  liveness: liveness,
                  pulse: _pulse.value,
                ),
                child: child,
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
    required this.pulse,
  });

  final double cents;
  final Color color;

  /// 0 = ocioso (ponteiro apagado no centro), 1 = leitura ativa.
  final double liveness;

  /// Fase 0..1 da respiração das faixas acesas.
  final double pulse;

  static const double _sweepDegrees = 70.0;

  /// Margem, em cents, na qual a faixa acende/apaga gradualmente em vez de
  /// piscar quando o ponteiro cruza a borda.
  static const double _edgeCents = 3.5;

  /// Metade da largura, em cents, do facho aceso sob a ponta do ponteiro.
  static const double _beamCents = 5.0;

  /// Ângulo do ponteiro medido a partir da vertical (0 = topo, positivo à
  /// direita). As direções usam (sin, −cos) e os arcos somam −π/2 para
  /// converter à convenção do canvas (0 = eixo +x).
  double _angleForCents(double value) =>
      (value / 50.0) * (_sweepDegrees * math.pi / 180.0);

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

    // Zonas de tolerância no trilho, alinhadas com o controller:
    // âmbar = "quase lá" (entre inTuneCents e slightlyOffCents, dos dois
    // lados) e menta = "afinado" (±inTuneCents). Cada faixa acende quando o
    // ponteiro entra nela.
    const inTune = TunerController.inTuneCents;
    const slightlyOff = TunerController.slightlyOffCents;
    _drawZone(canvas, pivot, radius, -slightlyOff, -inTune, AppColors.amber, 6);
    _drawZone(canvas, pivot, radius, inTune, slightlyOff, AppColors.amber, 6);
    _drawZone(canvas, pivot, radius, -inTune, inTune, AppColors.mint, 8);

    // Marcas da escala, acesas entre 0 e a posição do ponteiro.
    for (var value = -50; value <= 50; value += 5) {
      final isMajor = value % 25 == 0;
      final angle = _angleForCents(value.toDouble());
      final direction = Offset(math.sin(angle), -math.cos(angle));
      final outer = pivot + direction * (radius - 12);
      final inner = pivot + direction * (radius - (isMajor ? 30.0 : 22.0));
      final lit =
          liveness > 0 &&
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
    final needleDirection = Offset(
      math.sin(needleAngle),
      -math.cos(needleAngle),
    );
    final needleEnd = pivot + needleDirection * (radius - 36);
    final needleColor = Color.lerp(
      Colors.white.withValues(alpha: 0.25),
      color,
      liveness,
    )!;
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
    canvas.drawCircle(pivot, 7, Paint()..color = needleColor);
    canvas.drawCircle(pivot, 3, Paint()..color = AppColors.background);
  }

  /// Quanto a faixa [from]..[to] está acesa (0..1) para o ponteiro atual.
  ///
  /// Vale 1 com o ponteiro dentro dela e cai suavemente ao longo de
  /// [_edgeCents] fora das bordas, para a faixa acender ao ser alcançada em
  /// vez de piscar na travessia. Sem leitura ([liveness] 0) nada acende.
  double _activation(double from, double to) {
    final distance = cents < from
        ? from - cents
        : cents > to
        ? cents - to
        : 0.0;
    return (1 - distance / _edgeCents).clamp(0.0, 1.0) * liveness;
  }

  /// Faixa de tolerância que reage ao ponteiro: ao ser alcançada ela se ergue
  /// para fora do arco, engrossa, acende com brilho, passa a respirar e mostra
  /// um facho claro sob a ponta do ponteiro.
  void _drawZone(
    Canvas canvas,
    Offset pivot,
    double radius,
    double from,
    double to,
    Color zoneColor,
    double baseWidth,
  ) {
    final activation = _activation(from, to);
    final start = _angleForCents(from) - math.pi / 2;
    final sweep = _angleForCents(to) - _angleForCents(from);
    // Respiração e elevação só na faixa acesa, proporcionais à ativação.
    final breath = math.sin(pulse * 2 * math.pi);
    final lift = radius + activation * (5 + 1.6 * breath);
    final arcRect = Rect.fromCircle(center: pivot, radius: lift);
    final width = baseWidth * (1 + 0.95 * activation) * (1 + 0.06 * breath);
    // Apagada a faixa fica discreta; acesa vai a opaco.
    final alpha = 0.3 + 0.7 * activation;

    if (activation > 0.01) {
      canvas.drawArc(
        arcRect,
        start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width * 2.4
          ..strokeCap = StrokeCap.round
          ..color = zoneColor.withValues(alpha: 0.45 * activation)
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 14),
      );
    }

    canvas.drawArc(
      arcRect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..color = zoneColor.withValues(alpha: alpha),
    );

    if (activation <= 0.01) return;
    // Facho: trecho curto da faixa, sob a ponta do ponteiro, quase branco.
    final beamFrom = math.max(from, cents - _beamCents);
    final beamTo = math.min(to, cents + _beamCents);
    if (beamTo <= beamFrom) return;
    canvas.drawArc(
      arcRect,
      _angleForCents(beamFrom) - math.pi / 2,
      _angleForCents(beamTo) - _angleForCents(beamFrom),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width * 1.2
        ..strokeCap = StrokeCap.round
        ..color = Color.lerp(
          zoneColor,
          Colors.white,
          0.7,
        )!.withValues(alpha: 0.9 * activation)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4),
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
          fontFamily: 'Poppins',
          color: Colors.white.withValues(alpha: 0.45),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final position =
        pivot +
        Offset(math.sin(angle), -math.cos(angle)) * distance -
        Offset(painter.width / 2, painter.height / 2);
    painter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.cents != cents ||
      oldDelegate.color != color ||
      oldDelegate.liveness != liveness ||
      oldDelegate.pulse != pulse;
}
