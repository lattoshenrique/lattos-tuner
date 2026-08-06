import 'package:flutter/material.dart';
import 'package:lattos_tuner/views/theme.dart';
import 'package:lattos_tuner/views/widgets/brand_lockup.dart';

/// Abertura da marca, desenhada por cima do afinador.
///
/// A tela nativa de lançamento mostra só o símbolo (imagem não tem texto);
/// o nome aparece aqui, em widgets. Como o afinador já está montado por
/// baixo, o microfone começa a ouvir durante a abertura — ela é puramente
/// visual e some sozinha.
class BrandIntro extends StatefulWidget {
  const BrandIntro({super.key});

  @override
  State<BrandIntro> createState() => _BrandIntroState();
}

class _BrandIntroState extends State<BrandIntro>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1150),
  );

  late final Animation<double> _entrance = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.26, curve: Curves.easeOutCubic),
  );

  late final Animation<double> _exit = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.7, 1, curve: Curves.easeInCubic),
  );

  bool _done = false;

  @override
  void initState() {
    super.initState();
    _controller.forward().whenComplete(() {
      if (mounted) setState(() => _done = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return const SizedBox.shrink();
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Opacity(
          opacity: 1 - _exit.value,
          // Material (e não ColoredBox) porque a abertura fica fora do
          // Scaffold: sem ele o texto sai com o sublinhado de depuração.
          child: Material(
            color: AppColors.background,
            child: Center(
              child: Opacity(
                opacity: _entrance.value,
                child: Transform.scale(
                  scale: 0.92 + 0.08 * _entrance.value,
                  child: child,
                ),
              ),
            ),
          ),
        ),
        child: const BrandLockup(
          axis: Axis.vertical,
          markSize: 104,
          nameSize: 24,
          showTagline: true,
        ),
      ),
    );
  }
}
