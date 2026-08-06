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
  /// Envelopes: sobe em ~0,12 s e desce em ~0,6 s. Rápido o bastante para a
  /// nota "empurrar" o fundo de forma perceptível, lento o bastante para o
  /// movimento continuar lendo como respiração, não como pisca-pisca.
  static const double _attack = 0.12;
  static const double _release = 0.60;

  late final _AuroraState _visuals = _AuroraState(accent: widget.accent);
  late final Ticker _ticker;

  Duration _lastElapsed = Duration.zero;

  /// Piso de ruído do ambiente, em nível perceptual: desce rápido no silêncio
  /// e sobe devagar, então o fundo reage ao que MUDA, não ao chiado constante.
  double _noiseFloor = 0.35;
  double _previousLevel = 0;
  double _sinceRepaint = 0;

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
      visuals.bands[i] = _towards(
        visuals.bands[i],
        band,
        dt,
        _attack,
        _release,
      );
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
    // empurrão que se dissolve em ~1,1 s.
    if (level - _previousLevel > 0.05) {
      visuals.swell = math.min(1, visuals.swell + (level - _previousLevel) * 5);
    }
    _previousLevel = level;
    visuals.swell = _towards(visuals.swell, 0, dt, 1.1, 1.1);

    visuals.drift += dt;
    visuals.accent = Color.lerp(
      visuals.accent,
      widget.accent,
      (dt * 2.5).clamp(0.0, 1.0),
    )!;

    // Repinta a ~30 fps: são derivas lentas e envelopes, e cada repintura do
    // fundo obriga todas as peças de vidro acima a refazerem a captura.
    _sinceRepaint += dt;
    if (_sinceRepaint >= 0.032) {
      _sinceRepaint = 0;
      visuals.repaint();
    }
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
  _AuroraState({required Color accent}) : accent = accent, pitchColor = accent;

  final Float64List bands = Float64List(AudioFrame.bandCount);

  double level = 0;
  double clarity = 0;
  double logFrequency = math.log(110);

  /// Sobra do ataque da última nota (0..1), que empurra as manchas para fora.
  double swell = 0;
  double drift = 0;
  Color accent;
  Color pitchColor;

  /// Energia da banda mais forte do trecho (graves, médias ou agudas).
  ///
  /// Pico e não média: a energia de uma nota se concentra na fundamental e em
  /// poucos harmônicos, então a média de oito bandas diluía justamente o que
  /// deveria mover o fundo.
  double bandPeak(int start, int count) {
    var peak = 0.0;
    for (var i = start; i < start + count && i < bands.length; i++) {
      if (bands[i] > peak) peak = bands[i];
    }
    return peak;
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
    final bass = visuals.bandPeak(0, 8);
    final mid = visuals.bandPeak(8, 8);
    final treble = visuals.bandPeak(16, 8);
    final level = visuals.level;
    final swell = visuals.swell;

    // A cor da nota só entra quando há pitch confiável; fora isso vale o
    // estado de afinação.
    final glow = Color.lerp(
      visuals.accent,
      visuals.pitchColor,
      0.55 * visuals.clarity,
    )!;

    // Duas fases lentas e incomensuráveis: o conjunto nunca repete o mesmo
    // desenho, o que evita a sensação de loop.
    final slow = 2 * math.pi * (visuals.drift / 26);
    final slower = 2 * math.pi * (visuals.drift / 41);

    // Mancha principal (graves): a que mais respira com o corpo da nota.
    _blob(
      canvas,
      Offset(
        width * (0.30 + 0.15 * math.sin(slow) - 0.06 * swell),
        height * (0.17 + 0.05 * math.cos(slower * 1.3) - 0.05 * bass),
      ),
      width * (0.42 + 0.12 * bass + 0.08 * swell),
      glow,
      0.11 + 0.17 * bass + 0.09 * swell,
    );

    // Mancha violeta (médios), do lado oposto.
    _blob(
      canvas,
      Offset(
        width * (0.78 - 0.13 * math.cos(slow * 0.7) + 0.06 * swell),
        height * (0.30 + 0.07 * math.sin(slower)),
      ),
      width * (0.36 + 0.11 * mid),
      AppColors.violet,
      0.09 + 0.14 * mid,
    );

    // Base larga (agudos e volume geral): sustenta o gradiente embaixo.
    _blob(
      canvas,
      Offset(
        width * (0.5 + 0.18 * math.sin(slower * 0.6 + 1.7)),
        height * (0.80 + 0.03 * math.cos(slow * 0.9) - 0.04 * level),
      ),
      width * (0.48 + 0.10 * treble),
      glow,
      0.06 + 0.12 * treble + 0.07 * level,
    );

    // Brilho da nota: sobe e desce conforme a fundamental — grave embaixo,
    // agudo em cima — e só aparece quando há pitch estável.
    if (visuals.clarity > 0.01) {
      final octaves = (math.exp(visuals.logFrequency) / 55).clamp(1.0, 64.0);
      final position = (math.log(octaves) / math.ln2 / 5).clamp(0.0, 1.0);
      _blob(
        canvas,
        Offset(
          width * (0.5 + 0.06 * math.sin(slow * 1.4)),
          height * (0.72 - 0.45 * position),
        ),
        width * (0.26 + 0.11 * level + 0.09 * swell),
        glow,
        (0.09 + 0.16 * level) * visuals.clarity,
      );
    }

    _paintBottomShadow(canvas, width, height);
  }

  /// Mancha de luz difusa: círculo com desfoque, que no Impeller tem caminho
  /// rápido para formas simples (medido: bem mais barato que um gradiente
  /// radial grande, que gera overdraw em tela cheia).
  void _blob(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double alpha,
  ) {
    if (alpha <= 0.004) return;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: alpha)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 60),
    );
  }

  /// Sombra do rodapé com a borda ondulando devagar.
  ///
  /// Não são linhas desenhadas: é a própria penumbra que sobe e desce em
  /// camadas de maré, cada uma com fase e velocidade próprias, para o pé da
  /// tela nunca ficar com um corte estático. No silêncio a maré é mais alta;
  /// com som ela recua e cede espaço ao que reage à nota.
  void _paintBottomShadow(Canvas canvas, double width, double height) {
    final idle = (1 - visuals.level * 1.6).clamp(0.0, 1.0);
    const layers = <(double, double, double, double)>[
      // (altura relativa da crista, ciclos, velocidade, opacidade)
      (0.76, 1.10, 0.13, 0.45),
      (0.85, 1.70, -0.09, 0.65),
      (0.93, 0.80, 0.06, 0.9),
    ];
    const steps = 40;
    for (var layer = 0; layer < layers.length; layer++) {
      final (base, cycles, speed, weight) = layers[layer];
      final phase = visuals.drift * speed * 2 * math.pi + layer * 1.9;
      final amplitude = height * (0.012 + 0.010 * idle) * (1 - layer * 0.2);
      final crest = height * base - height * 0.02 * idle;
      final path = Path()..moveTo(0, crest);
      for (var step = 0; step <= steps; step++) {
        final t = step / steps;
        path.lineTo(
          width * t,
          crest +
              math.sin(t * cycles * 2 * math.pi + phase) * amplitude +
              // Segunda harmônica lenta: a crista nunca repete o mesmo perfil.
              math.sin(t * cycles * 4 * math.pi - phase * 0.6) *
                  amplitude *
                  0.35,
        );
      }
      path
        ..lineTo(width, height)
        ..lineTo(0, height)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background.withValues(alpha: 0),
              AppColors.background.withValues(alpha: 0.85 * weight),
            ],
          ).createShader(Rect.fromLTRB(0, crest - amplitude * 2, width, height))
          // Sem esse desfoque a crista do caminho vira um corte seco na
          // sombra. É barato: sigma pequeno em três caminhos, nada perto dos
          // sigmas grandes das manchas.
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 12),
      );
    }
  }

  // Repinta pelo Listenable do ticker, não pela troca de painter.
  @override
  bool shouldRepaint(_AuroraPainter oldDelegate) =>
      oldDelegate.visuals != visuals;
}
