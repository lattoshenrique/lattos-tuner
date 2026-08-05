import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lattos_tuner/models/audio_frame.dart';
import 'package:lattos_tuner/views/theme.dart';

/// Fundo vivo: manchas de luz desfocadas que respiram com o áudio real do
/// microfone.
///
/// Nada de forma de onda desenhada — o que se move é o próprio gradiente: a
/// energia das bandas graves/médias/agudas incha cada mancha, o ataque de uma
/// nota dá um leve empurrão para fora e a fundamental detectada desloca o
/// brilho central e tinge a cor. Tudo em constantes de tempo longas, para o
/// movimento ser percebido como respiração, não como animação.
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({
    super.key,
    required this.accent,
    required this.audio,
  });

  /// Cor do estado de afinação.
  final Color accent;

  /// Quadros de áudio publicados pelo controller (~20 por segundo).
  final ValueListenable<AudioFrame> audio;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  /// Envelopes lentos: sobe em ~0,2 s e desce em ~0,9 s. Rápido o bastante
  /// para acompanhar a nota, lento o bastante para não piscar.
  static const double _attack = 0.20;
  static const double _release = 0.90;

  late final _AuroraState _visuals = _AuroraState(accent: widget.accent);
  late final Ticker _ticker;

  Duration _lastElapsed = Duration.zero;

  /// Piso de ruído do ambiente, em nível perceptual: desce rápido no silêncio
  /// e sobe devagar, então o fundo reage ao que MUDA, não ao chiado constante.
  double _noiseFloor = 0.35;
  double _previousLevel = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _visuals.dispose();
    super.dispose();
  }

  /// Aproximação exponencial de [target], independente da taxa de quadros.
  static double _towards(
    double current,
    double target,
    double dt,
    double attack,
    double release,
  ) {
    final tau = target > current ? attack : release;
    return current + (target - current) * (1 - math.exp(-dt / tau));
  }

  void _onTick(Duration elapsed) {
    var dt = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    // Primeiro quadro e volta do segundo plano trazem saltos enormes.
    if (dt <= 0 || dt > 0.1) dt = 1 / 60;

    final frame = widget.audio.value;
    final visuals = _visuals;

    _noiseFloor = _towards(_noiseFloor, frame.level, dt, 6.0, 0.30);
    final headroom = math.max(0.18, 1 - _noiseFloor);
    double aboveFloor(double value) =>
        ((value - _noiseFloor - 0.02) / headroom).clamp(0.0, 1.0);

    final level = aboveFloor(frame.level);
    visuals.level = _towards(visuals.level, level, dt, _attack, _release);
    visuals.clarity = _towards(visuals.clarity, frame.clarity, dt, 0.3, 0.9);
    for (var i = 0; i < visuals.bands.length; i++) {
      final band = i < frame.bands.length ? aboveFloor(frame.bands[i]) : 0.0;
      visuals.bands[i] = _towards(visuals.bands[i], band, dt, _attack, _release);
    }

    final frequency = frame.frequency;
    if (frequency != null && frequency > 0) {
      // Suavização em escala log: subir uma oitava custa o mesmo que descer.
      visuals.logFrequency +=
          (math.log(frequency) - visuals.logFrequency) *
          (1 - math.exp(-dt / 0.5));
      visuals.pitchColor = _pitchColor(math.exp(visuals.logFrequency));
    }

    // Ataque de nota (palhetada): salto de energia entre dois quadros vira um
    // empurrão que se dissolve em ~1,5 s.
    if (level - _previousLevel > 0.06) {
      visuals.swell = math.min(1, visuals.swell + (level - _previousLevel) * 3);
    }
    _previousLevel = level;
    visuals.swell = _towards(visuals.swell, 0, dt, 1.5, 1.5);

    visuals.drift += dt;
    visuals.accent = Color.lerp(
      visuals.accent,
      widget.accent,
      (dt * 2.5).clamp(0.0, 1.0),
    )!;

    visuals.repaint();
  }

  /// Cor associada à classe da nota: cada semitom gira 30° no círculo de
  /// matizes, então cada frequência tinge o fundo de um jeito.
  static Color _pitchColor(double frequency) {
    final midi = 69 + 12 * (math.log(frequency / 440) / math.ln2);
    final pitchClass = ((midi.round() % 12) + 12) % 12;
    return HSLColor.fromAHSL(
      1,
      (265 + pitchClass * 30) % 360,
      0.68,
      0.62,
    ).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _AuroraPainter(_visuals),
      ),
    );
  }
}

/// Estado suavizado compartilhado com o painter. Vive fora do ciclo de build:
/// o ticker atualiza os campos e chama [repaint], sem reconstruir widget algum.
class _AuroraState extends ChangeNotifier {
  _AuroraState({required Color accent})
    : accent = accent,
      pitchColor = accent;

  final Float64List bands = Float64List(AudioFrame.bandCount);

  double level = 0;
  double clarity = 0;
  double logFrequency = math.log(110);

  /// Sobra do ataque da última nota (0..1), que empurra as manchas para fora.
  double swell = 0;
  double drift = 0;
  Color accent;
  Color pitchColor;

  /// Energia média de um trecho de bandas (graves, médias ou agudas).
  double bandRange(int start, int count) {
    var sum = 0.0;
    for (var i = start; i < start + count && i < bands.length; i++) {
      sum += bands[i];
    }
    return sum / count;
  }

  void repaint() => notifyListeners();
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter(this.visuals) : super(repaint: visuals);

  final _AuroraState visuals;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final bass = visuals.bandRange(0, 8);
    final mid = visuals.bandRange(8, 8);
    final treble = visuals.bandRange(16, 8);
    final level = visuals.level;
    final swell = visuals.swell;

    // A cor da nota só entra quando há pitch confiável; fora isso vale o
    // estado de afinação.
    final glow = Color.lerp(
      visuals.accent,
      visuals.pitchColor,
      0.40 * visuals.clarity,
    )!;

    // Duas fases lentas e incomensuráveis: o conjunto nunca repete o mesmo
    // desenho, o que evita a sensação de loop.
    final slow = 2 * math.pi * (visuals.drift / 26);
    final slower = 2 * math.pi * (visuals.drift / 41);

    final paint = Paint()
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 80);

    // Mancha principal (graves): a que mais respira com o corpo da nota.
    paint.color = glow.withValues(alpha: 0.10 + 0.07 * bass + 0.04 * swell);
    canvas.drawCircle(
      Offset(
        width * (0.30 + 0.15 * math.sin(slow) - 0.03 * swell),
        height * (0.17 + 0.05 * math.cos(slower * 1.3) - 0.02 * bass),
      ),
      width * (0.42 + 0.05 * bass + 0.04 * swell),
      paint,
    );

    // Mancha violeta (médios), do lado oposto.
    paint.color = AppColors.violet.withValues(alpha: 0.08 + 0.05 * mid);
    canvas.drawCircle(
      Offset(
        width * (0.78 - 0.13 * math.cos(slow * 0.7) + 0.03 * swell),
        height * (0.30 + 0.07 * math.sin(slower)),
      ),
      width * (0.36 + 0.05 * mid),
      paint,
    );

    // Base larga (agudos e volume geral): sustenta o gradiente embaixo.
    paint.color = glow.withValues(alpha: 0.05 + 0.05 * treble + 0.03 * level);
    canvas.drawCircle(
      Offset(
        width * (0.5 + 0.18 * math.sin(slower * 0.6 + 1.7)),
        height * (0.80 + 0.03 * math.cos(slow * 0.9)),
      ),
      width * (0.48 + 0.04 * treble),
      paint,
    );

    // Brilho da nota: sobe e desce conforme a fundamental — grave embaixo,
    // agudo em cima — e só aparece quando há pitch estável.
    if (visuals.clarity > 0.01) {
      final octaves = (math.exp(visuals.logFrequency) / 55).clamp(1.0, 64.0);
      final position = (math.log(octaves) / math.ln2 / 5).clamp(0.0, 1.0);
      paint.color = glow.withValues(
        alpha: (0.05 + 0.07 * level) * visuals.clarity,
      );
      canvas.drawCircle(
        Offset(
          width * (0.5 + 0.06 * math.sin(slow * 1.4)),
          height * (0.72 - 0.45 * position),
        ),
        width * (0.26 + 0.06 * level + 0.05 * swell),
        paint,
      );
    }
  }

  // Repinta pelo Listenable do ticker, não pela troca de painter.
  @override
  bool shouldRepaint(_AuroraPainter oldDelegate) =>
      oldDelegate.visuals != visuals;
}
