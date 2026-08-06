import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:lattos_tuner/views/theme.dart';

/// Carrega e serve o shader de refração das peças de vidro.
///
/// `ImageFilter.shader` só existe com Impeller; onde não houver (Skia antigo,
/// falha de compilação), [filter] devolve null e o vidro cai para o desfoque
/// simples, sem quebrar a tela.
abstract final class LiquidGlassShader {
  static ui.FragmentProgram? _program;
  static bool _unavailable = false;

  /// Carrega o programa uma vez, no start do app.
  static Future<void> load() async {
    if (_program != null || _unavailable) return;
    try {
      _program = await ui.FragmentProgram.fromAsset(
        'shaders/liquid_glass.frag',
      );
    } catch (error) {
      _unavailable = true;
      debugPrint('Liquid glass sem shader de refração: $error');
    }
  }

  /// Filtro de refração para uma peça com esses parâmetros, ou null quando o
  /// shader não está disponível.
  static ui.ImageFilter? filter({
    required double radius,
    required double rim,
    required double strength,
    required double chroma,
    required double edgeSaturation,
    required double edgeGain,
    required double bodySaturation,
  }) {
    final program = _program;
    if (program == null || _unavailable) return null;
    try {
      // Índices 0 e 1 são o vec2 de tamanho, preenchido pela engine.
      final shader = program.fragmentShader()
        ..setFloat(2, radius)
        ..setFloat(3, rim)
        ..setFloat(4, strength)
        ..setFloat(5, chroma)
        ..setFloat(6, edgeSaturation)
        ..setFloat(7, edgeGain)
        ..setFloat(8, bodySaturation);
      return ui.ImageFilter.shader(shader);
    } catch (error) {
      _unavailable = true;
      debugPrint('Liquid glass sem shader de refração: $error');
      return null;
    }
  }
}

/// Superfície de vidro no espírito do Liquid Glass da Apple.
///
/// Camadas, na ordem em que o vidro real se comporta:
///
/// 1. o corpo, que borra e satura o que está atrás — vidro recolhe luz;
/// 2. a refração de borda, feita por shader: perto do contorno a imagem de
///    trás é puxada para dentro, com leve dispersão cromática;
/// 3. o especular e o fio de luz no topo, mais a sombra interna embaixo, que
///    dão espessura e direção à luz;
/// 4. o conteúdo.
///
/// Envolva a tela num [BackdropGroup] para que todas as peças compartilhem uma
/// única captura do fundo em vez de uma por peça.
class LiquidGlass extends StatefulWidget {
  const LiquidGlass({
    super.key,
    required this.child,
    this.radius = 24,
    this.blur = 26,
    this.rim = 14,
    this.padding = EdgeInsets.zero,
    this.tint,
    this.tintOpacity = 0.12,
    this.brightness = 1,
    this.onTap,
    this.refract = true,
  });

  final Widget child;

  /// Raio dos cantos. Cantos generosos são parte da linguagem do material.
  final double radius;

  /// Desfoque do corpo.
  final double blur;

  /// Espessura, em pixels, da faixa de borda que refrata.
  final double rim;

  final EdgeInsets padding;

  /// Cor que tinge o vidro (estado de afinação, seleção). Sem ela o vidro é
  /// neutro e mostra só o que está atrás.
  final Color? tint;
  final double tintOpacity;

  /// Multiplicador do brilho das bordas e do especular, para peças pequenas
  /// poderem brilhar um pouco mais.
  final double brightness;

  final VoidCallback? onTap;

  /// Peça pesada (captura o fundo, borra e refrata) ou leve (só o véu e os
  /// brilhos). Cada peça pesada custa uma captura do fundo por quadro, então
  /// as pequenas — chips, botões de ícone, o polegar do seletor — usam a
  /// versão leve: sobre um fundo já escuro a diferença é mínima e o ganho de
  /// desempenho é grande.
  final bool refract;

  @override
  State<LiquidGlass> createState() => _LiquidGlassState();
}

class _LiquidGlassState extends State<LiquidGlass>
    with SingleTickerProviderStateMixin {
  /// Varredura da luz: o brilho entra correndo a borda em vez de aparecer
  /// pronto. Rápido de propósito — vidro reage à luz na hora.
  late final AnimationController _shine = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 460),
  )..forward();

  @override
  void didUpdateWidget(LiquidGlass oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Mudou de estado (seleção, afinou): a luz corre a peça de novo.
    if (oldWidget.tint != widget.tint) _shine.forward(from: 0.35);
  }

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  /// Realce de saturação e luz do que passa pelo vidro: material translúcido
  /// recolhe e concentra a luz do que está atrás.
  /// Nada de clarear para branco: a matriz é saturação pura (1,55) com um
  /// ganho suave de luz (1,10), então o vidro devolve a MESMA cor do que está
  /// atrás, só mais viva — é assim que vidro se comporta.
  static const ColorFilter _lightCollector = ColorFilter.matrix(<double>[
    1.576, -0.433, -0.044, 0, 0, //
    -0.129, 1.272, -0.044, 0, 0, //
    -0.129, -0.433, 1.661, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);

  @override
  Widget build(BuildContext context) {
    final radius = widget.radius;
    final rim = widget.rim;
    final shape = BorderRadius.circular(radius);
    final content = Padding(padding: widget.padding, child: widget.child);
    final refraction = widget.refract
        ? LiquidGlassShader.filter(
            radius: radius,
            rim: rim,
            strength: rim * 0.9,
            chroma: 0.4,
            edgeSaturation: 0.9,
            edgeGain: 0.5,
            bodySaturation: 1.18,
          )
        : null;
    final blurFilter = ui.ImageFilter.blur(
      sigmaX: widget.blur,
      sigmaY: widget.blur,
    );
    return ClipRRect(
      borderRadius: shape,
      child: Stack(
        children: [
          if (!widget.refract)
            // Peça leve: um véu do tom do fundo no lugar da captura.
            Positioned.fill(
              child: ColoredBox(
                color: AppColors.surfaceBright.withValues(alpha: 0.34),
              ),
            )
          else
            Positioned.fill(
              child: BackdropFilter(
                // BackdropFilter comum, e não .grouped: o modo agrupado ignora
                // filtros de shader, e é o shader que faz a refração.
                // Sem shader (Skia), o vidro cai para desfoque + saturação.
                filter: refraction == null
                    ? ui.ImageFilter.compose(
                        outer: _lightCollector,
                        inner: blurFilter,
                      )
                    // Borra primeiro, entorta a borda depois.
                    : ui.ImageFilter.compose(
                        outer: refraction,
                        inner: blurFilter,
                      ),
                child: const SizedBox.expand(),
              ),
            ),
          Positioned.fill(
            child: TweenAnimationBuilder<Color?>(
              // Troca de tinta também é transição, não corte seco. Sem tinta
              // o alvo é transparente — e transparente vira "sem tinta" no
              // painter, para não pintar um véu preto.
              tween: ColorTween(end: widget.tint ?? const Color(0x00FFFFFF)),
              duration: const Duration(milliseconds: 280),
              builder: (context, tint, _) => AnimatedBuilder(
                animation: _shine,
                builder: (context, _) => CustomPaint(
                  painter: _GlassPainter(
                    radius: radius,
                    tint: (tint == null || tint.a == 0) ? null : tint,
                    tintOpacity: widget.tintOpacity,
                    brightness: widget.brightness,
                    shine: Curves.easeOutCubic.transform(_shine.value),
                    heavy: widget.refract,
                  ),
                ),
              ),
            ),
          ),
          if (widget.onTap == null)
            content
          else
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: shape,
                highlightColor: Colors.white.withValues(alpha: 0.04),
                splashColor: Colors.white.withValues(alpha: 0.06),
                child: content,
              ),
            ),
        ],
      ),
    );
  }
}

class _GlassPainter extends CustomPainter {
  _GlassPainter({
    required this.radius,
    required this.tint,
    required this.tintOpacity,
    required this.brightness,
    required this.shine,
    required this.heavy,
  });

  final double radius;
  final Color? tint;
  final double tintOpacity;
  final double brightness;

  /// 0 = luz ainda entrando, 1 = assentada.
  final double shine;

  /// Peça pesada paga desfoque na sombra interna; a leve usa gradiente.
  final bool heavy;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(bounds, Radius.circular(radius));

    // Corpo: um véu claríssimo, mais presente na quina de cima. O que dá
    // corpo à peça é o que se vê ATRAVÉS dela, não uma camada opaca por cima.
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.045 * brightness),
            Colors.white.withValues(alpha: 0.004),
            Colors.white.withValues(alpha: 0.014 * brightness),
          ],
          stops: const [0, 0.5, 1],
        ).createShader(bounds),
    );

    final tintColor = tint;
    if (tintColor != null) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              tintColor.withValues(alpha: tintOpacity),
              tintColor.withValues(alpha: tintOpacity * 0.35),
            ],
          ).createShader(bounds),
      );
    }

    canvas.save();
    canvas.clipRRect(rrect);

    // Sombra interna na base: o vidro tem espessura, e a luz que entra por
    // cima não chega embaixo. Nas peças leves ela é um gradiente, para não
    // pagar um passe de desfoque por peça em cada quadro.
    if (heavy) {
      canvas.drawRRect(
        rrect.shift(const Offset(0, 12)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 16
          ..color = Colors.black.withValues(alpha: 0.20)
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 10),
      );
    } else {
      canvas.drawRRect(
        rrect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.center,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0),
              Colors.black.withValues(alpha: 0.22),
            ],
          ).createShader(bounds),
      );
    }

    // Especular: um risco de luz que ENTRA correndo a peça e assenta na quina
    // de cima. É a varredura que faz o vidro parecer reagir à luz.
    final sweep = -1.4 + 2.3 * shine;
    canvas.drawRRect(
      rrect.deflate(1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 + 1.4 * (1 - shine)
        ..shader = LinearGradient(
          begin: Alignment(sweep - 0.5, -1),
          end: Alignment(sweep + 1.1, 0.15),
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(
              alpha: (0.30 + 0.35 * (1 - shine)) * brightness,
            ),
            Colors.white.withValues(alpha: 0.05 * brightness),
            Colors.white.withValues(alpha: 0),
          ],
          stops: const [0, 0.22, 0.5, 1],
        ).createShader(bounds)
        ..maskFilter = ui.MaskFilter.blur(
          ui.BlurStyle.normal,
          1.4 + 2 * (1 - shine),
        ),
    );
    canvas.restore();

    // Fio de contorno: fecha a peça sem pesar.
    canvas.drawRRect(
      rrect.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.16 * brightness * shine),
            Colors.white.withValues(alpha: 0.03 * shine),
            Colors.white.withValues(alpha: 0.07 * brightness * shine),
          ],
          stops: const [0, 0.5, 1],
        ).createShader(bounds),
    );
  }

  @override
  bool shouldRepaint(_GlassPainter oldDelegate) =>
      oldDelegate.radius != radius ||
      oldDelegate.tint != tint ||
      oldDelegate.tintOpacity != tintOpacity ||
      oldDelegate.brightness != brightness ||
      oldDelegate.shine != shine ||
      oldDelegate.heavy != heavy;
}
