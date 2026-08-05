import 'package:flutter/material.dart';
import 'package:lattos_tuner/models/tuner_reading.dart';

/// Paleta do app: fundo profundo, verde-menta para "afinado", violeta como
/// acento neutro e âmbar/coral para desvios.
abstract final class AppColors {
  static const Color background = Color(0xFF060A12);
  static const Color surface = Color(0xFF0E1420);
  static const Color surfaceBright = Color(0xFF17202F);
  static const Color outline = Color(0x14FFFFFF);
  static const Color mint = Color(0xFF2EE6A8);
  static const Color violet = Color(0xFF8A7BFF);
  static const Color amber = Color(0xFFFFC24B);
  static const Color coral = Color(0xFFFF5A6E);
  static const Color textPrimary = Color(0xFFF2F6FF);
  static const Color textSecondary = Color(0xFF8B96AB);
}

/// Cor associada ao estado de afinação (violeta quando ocioso).
Color statusColor(TuningStatus? status) => switch (status) {
  null => AppColors.violet,
  TuningStatus.inTune => AppColors.mint,
  TuningStatus.slightlyLow || TuningStatus.slightlyHigh => AppColors.amber,
  TuningStatus.tooLow || TuningStatus.tooHigh => AppColors.coral,
};

ThemeData buildAppTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.mint,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.mint,
        onPrimary: const Color(0xFF04291C),
        secondary: AppColors.violet,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        error: AppColors.coral,
        outlineVariant: AppColors.outline,
      );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    // Fonte da marca (Google Fonts, licença OFL, embarcada como asset).
    fontFamily: 'Poppins',
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.outline),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceBright,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.mint, width: 1.4),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.surfaceBright,
      contentTextStyle: const TextStyle(color: AppColors.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.outline),
  );
}

/// Transição shared-axis vertical (padrão Material Motion): a tela nova
/// desliza de baixo enquanto a anterior recua sutilmente. Boa para fluxos
/// de criação/edição.
class SharedAxisVerticalPageRoute<T> extends PageRouteBuilder<T> {
  SharedAxisVerticalPageRoute({required WidgetBuilder builder})
    : super(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          final recede = CurvedAnimation(
            parent: secondaryAnimation,
            curve: Curves.easeInOutCubic,
          );
          return SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.10),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween(
                  begin: Offset.zero,
                  end: const Offset(0, -0.03),
                ).animate(recede),
                child: child,
              ),
            ),
          );
        },
      );
}

/// Transição fade-through (padrão Material Motion) para navegação entre
/// telas de nível superior.
class FadeThroughPageRoute<T> extends PageRouteBuilder<T> {
  FadeThroughPageRoute({required WidgetBuilder builder})
    : super(
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween(begin: 0.94, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      );
}
