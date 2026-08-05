import 'package:flutter/material.dart';
import 'package:lattos_tuner/views/theme.dart';

/// Nome da nota alvo em destaque, com transição animada entre notas e anéis
/// pulsantes quando afinado.
class NoteDisplay extends StatefulWidget {
  const NoteDisplay({
    super.key,
    required this.noteName,
    required this.octave,
    required this.color,
    required this.inTune,
  });

  /// Nome da nota sem a oitava (ex.: "C#"), ou null quando ocioso.
  final String? noteName;
  final int? octave;
  final Color color;
  final bool inTune;

  @override
  State<NoteDisplay> createState() => _NoteDisplayState();
}

class _NoteDisplayState extends State<NoteDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didUpdateWidget(NoteDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.inTune && !_pulse.isAnimating) {
      _pulse.repeat();
    } else if (!widget.inTune && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.reset();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final idle = widget.noteName == null;
    return SizedBox(
      width: 190,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) => CustomPaint(
              size: const Size(190, 150),
              painter: _PulsePainter(
                progress: _pulse.value,
                color: widget.color,
                enabled: widget.inTune,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: idle
                ? Icon(
                    Icons.graphic_eq_rounded,
                    key: const ValueKey('idle'),
                    size: 64,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  )
                : Row(
                    key: ValueKey('${widget.noteName}${widget.octave}'),
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.noteName!,
                        style: TextStyle(
                          fontSize: 96,
                          height: 1.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -2,
                          color: widget.color,
                          shadows: [
                            Shadow(
                              color: widget.color.withValues(alpha: 0.55),
                              blurRadius: 32,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 14, left: 4),
                        child: Text(
                          '${widget.octave}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: widget.color.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  _PulsePainter({
    required this.progress,
    required this.color,
    required this.enabled,
  });

  final double progress;
  final Color color;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    if (!enabled) return;
    final center = size.center(Offset.zero);
    // Dois anéis defasados que expandem e desvanecem.
    for (final phase in [0.0, 0.5]) {
      final t = (progress + phase) % 1.0;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = color.withValues(alpha: (1.0 - t) * 0.35);
      canvas.drawCircle(center, 55 + t * 65, paint);
    }
  }

  @override
  bool shouldRepaint(_PulsePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.enabled != enabled ||
      oldDelegate.color != color;
}
