import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lattos_tuner/views/theme.dart';

/// Explosão de confetes disparada quando [play] é incrementado — usada na
/// celebração de "instrumento afinado".
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key, required this.play});

  /// Contador de disparos: cada incremento reproduz a animação uma vez.
  final int play;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  static const int _particleCount = 42;
  static const List<Color> _palette = [
    AppColors.mint,
    AppColors.violet,
    AppColors.amber,
    AppColors.coral,
    Colors.white,
  ];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  late final List<_Particle> _particles = _generateParticles();

  List<_Particle> _generateParticles() {
    final random = math.Random(1337);
    return List.generate(_particleCount, (i) {
      // Leque para cima, com ligeira assimetria.
      final angle = -math.pi / 2 + (random.nextDouble() - 0.5) * math.pi * 1.1;
      return _Particle(
        angle: angle,
        speed: 220 + random.nextDouble() * 260,
        size: 5 + random.nextDouble() * 5,
        spin: (random.nextDouble() - 0.5) * 14,
        color: _palette[i % _palette.length],
      );
    });
  }

  @override
  void didUpdateWidget(ConfettiBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play != oldWidget.play && widget.play > 0) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (!_controller.isAnimating) return const SizedBox.shrink();
          return CustomPaint(
            size: Size.infinite,
            painter: _ConfettiPainter(
              progress: _controller.value,
              particles: _particles,
            ),
          );
        },
      ),
    );
  }
}

class _Particle {
  const _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.spin,
    required this.color,
  });

  final double angle;
  final double speed;
  final double size;
  final double spin;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.particles});

  final double progress;
  final List<_Particle> particles;

  static const double _gravity = 560.0;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height * 0.45);
    // Desaceleração do impulso inicial + queda por gravidade.
    final travel = Curves.easeOutCubic.transform(progress);
    final alpha = progress < 0.55 ? 1.0 : (1.0 - (progress - 0.55) / 0.45);
    final paint = Paint();
    for (final particle in particles) {
      final distance = particle.speed * travel;
      final position =
          origin +
          Offset(
            math.cos(particle.angle) * distance,
            math.sin(particle.angle) * distance +
                _gravity * progress * progress * 0.5,
          );
      paint.color = particle.color.withValues(alpha: alpha.clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(particle.spin * progress);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size * 0.55,
          ),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
