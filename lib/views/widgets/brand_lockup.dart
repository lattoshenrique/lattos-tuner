import 'package:flutter/material.dart';
import 'package:lattos_tuner/views/l10n.dart';
import 'package:lattos_tuner/views/theme.dart';

/// Marca do app montada em tela: o símbolo vem de uma imagem sem texto e o
/// nome é um [Text].
///
/// Nome e assinatura nunca ficam dentro de um PNG — assim eles vivem no l10n,
/// acompanham o tema e a fonte, e uma troca de marca é uma string, não um
/// pacote de imagens para reexportar.
class BrandLockup extends StatelessWidget {
  const BrandLockup({
    super.key,
    this.axis = Axis.horizontal,
    this.markSize = 28,
    this.nameSize = 14.5,
    this.showTagline = false,
  });

  /// Horizontal para o cabeçalho, vertical para a abertura.
  final Axis axis;
  final double markSize;
  final double nameSize;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final horizontal = axis == Axis.horizontal;
    final mark = Image.asset(
      'assets/branding/logo_mark.png',
      width: markSize,
      height: markSize,
    );
    final name = Text(
      context.l10n.tunerTitle,
      textAlign: horizontal ? TextAlign.start : TextAlign.center,
      style: TextStyle(
        fontSize: nameSize,
        fontWeight: FontWeight.w800,
        letterSpacing: nameSize * 0.076,
        color: AppColors.textPrimary,
      ),
    );
    final tagline = showTagline
        ? Padding(
            padding: EdgeInsets.only(top: nameSize * 0.4),
            child: Text(
              context.l10n.tagline,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: nameSize * 0.62,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
                color: AppColors.textSecondary,
              ),
            ),
          )
        : null;

    if (horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          mark,
          SizedBox(width: markSize * 0.32),
          Flexible(
            // scaleDown mantém o wordmark inteiro em telas estreitas ou com
            // traduções mais longas.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [name, if (tagline != null) tagline],
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(height: markSize * 0.2),
        name,
        if (tagline != null) tagline,
      ],
    );
  }
}
