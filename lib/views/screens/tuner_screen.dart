import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lattos_tuner/controllers/tuner_controller.dart';
import 'package:lattos_tuner/models/note.dart';
import 'package:lattos_tuner/models/tuner_reading.dart';
import 'package:lattos_tuner/models/tuning_preset.dart';
import 'package:lattos_tuner/services/haptic_guide.dart';
import 'package:lattos_tuner/views/l10n.dart';
import 'package:lattos_tuner/views/screens/preset_editor_screen.dart';
import 'package:lattos_tuner/views/screens/presets_screen.dart';
import 'package:lattos_tuner/views/theme.dart';
import 'package:lattos_tuner/views/widgets/aurora_background.dart';
import 'package:lattos_tuner/views/widgets/brand_lockup.dart';
import 'package:lattos_tuner/views/widgets/confetti_burst.dart';
import 'package:lattos_tuner/views/widgets/liquid_glass.dart';
import 'package:lattos_tuner/views/widgets/note_display.dart';
import 'package:lattos_tuner/views/widgets/string_chips.dart';
import 'package:lattos_tuner/views/widgets/tuner_gauge.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Tela principal: medidor, nota alvo, cordas do preset e status.
///
/// Mantém a tela do aparelho acesa enquanto estiver em primeiro plano.
class TunerScreen extends StatefulWidget {
  const TunerScreen({super.key, required this.controller});

  final TunerController controller;

  @override
  State<TunerScreen> createState() => _TunerScreenState();
}

class _TunerScreenState extends State<TunerScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  /// Guia tátil e o relógio monotônico que o alimenta.
  final HapticGuide _haptics = HapticGuide();
  final Stopwatch _clock = Stopwatch()..start();
  Timer? _hapticTimer;

  int _lastCapturedCount = 0;
  bool _celebrated = false;
  int _celebrationCount = 0;

  TunerController get controller => widget.controller;

  /// Liga/desliga o wakelock sem deixar uma falha do plugin (plataformas
  /// sem suporte, ambiente de teste) derrubar o afinador.
  void _setWakelock(bool enabled) {
    unawaited(
      (enabled ? WakelockPlus.enable() : WakelockPlus.disable()).catchError(
        (_) {},
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller.addListener(_onControllerChange);
    _setWakelock(true);
    // 40 ms é bem mais fino que o pulso mais rápido do guia (110 ms), então o
    // ritmo sai regular sem depender da chegada das leituras.
    _hapticTimer = Timer.periodic(
      const Duration(milliseconds: 40),
      (_) => _pulseHaptics(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.start());
  }

  @override
  void dispose() {
    _setWakelock(false);
    WidgetsBinding.instance.removeObserver(this);
    controller.removeListener(_onControllerChange);
    _hapticTimer?.cancel();
    _entrance.dispose();
    super.dispose();
  }

  /// Vibração que guia a afinação: forte e espaçada longe da nota, leve e
  /// rápida perto dela, com um toque de confirmação ao chegar.
  void _pulseHaptics() {
    final pulse = _haptics.evaluate(
      reading: controller.reading,
      running: controller.isRunning,
      enabled: controller.hapticGuide,
      now: _clock.elapsed,
    );
    switch (pulse) {
      case null:
        return;
      case HapticPulse.light:
        HapticFeedback.selectionClick();
      case HapticPulse.medium:
        HapticFeedback.lightImpact();
      case HapticPulse.heavy:
        HapticFeedback.mediumImpact();
      case HapticPulse.arrival:
        HapticFeedback.heavyImpact();
        // Toque duplo: o segundo bate logo depois e marca a chegada.
        Future.delayed(
          const Duration(milliseconds: 90),
          HapticFeedback.lightImpact,
        );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setWakelock(true);
      controller.start();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _setWakelock(false);
      controller.stop();
    }
  }

  void _onControllerChange() {
    // A chegada na nota já é anunciada pelo guia tátil, antes mesmo de a
    // corda ser confirmada — repetir aqui viraria vibração dupla.
    final capturedCount = controller.capturedMidis.length;
    if (capturedCount > _lastCapturedCount) {
      HapticFeedback.mediumImpact();
    }
    _lastCapturedCount = capturedCount;

    if (controller.allStringsTuned && !_celebrated) {
      _celebrated = true;
      HapticFeedback.heavyImpact();
      setState(() => _celebrationCount++);
    } else if (!controller.allStringsTuned) {
      _celebrated = false;
    }
  }

  Future<void> _openPresets() async {
    controller.stop();
    await Navigator.of(context).push(
      FadeThroughPageRoute(
        builder: (_) => PresetsScreen(controller: controller),
      ),
    );
    controller.start();
  }

  Future<void> _saveCapturedPreset() async {
    final notes = controller.capturedMidis.map(midiToName).toList();
    controller.stop();
    await Navigator.of(context).push(
      SharedAxisVerticalPageRoute(
        builder: (_) => PresetEditorScreen(
          controller: controller,
          base: TuningPreset(
            id: 'capture',
            name: '',
            instrument: Instrument.guitar,
            notes: notes,
          ),
          activateOnSave: true,
        ),
      ),
    );
    controller.start();
  }

  Future<void> _openCalibration() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _CalibrationSheet(controller: controller),
    );
  }

  /// Entrada escalonada dos blocos da tela na abertura do app.
  Widget _entranceSlot(int slot, Widget child) {
    final start = (slot * 0.09).clamp(0.0, 0.6);
    final animation = CurvedAnimation(
      parent: _entrance,
      curve: Interval(
        start,
        (start + 0.4).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final reading = controller.reading;
        final status = reading?.status;
        final accent = statusColor(status);
        final chromatic = controller.mode == TargetMode.chromatic;
        return Scaffold(
          // Uma única captura do fundo serve todas as peças de vidro.
          body: BackdropGroup(
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.6),
                      radius: 1.3,
                      colors: [
                        accent.withValues(alpha: 0.14),
                        AppColors.background,
                      ],
                    ),
                  ),
                ),
                AuroraBackground(accent: accent, audio: controller.audioFrame),
                SafeArea(
                  child: controller.permissionDenied
                      ? _PermissionDeniedView(onRetry: controller.start)
                      : Column(
                          children: [
                            // O botão é uma peça de vidro: quem alinha com a
                            // borda do card é a borda dele, na mesma margem
                            // da tela.
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                              child: _entranceSlot(
                                0,
                                _BrandBar(
                                  controller: controller,
                                  onCalibration: _openCalibration,
                                  onPresets: _openPresets,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  0,
                                  20,
                                  16,
                                ),
                                child: Column(
                                  children: [
                                    // No modo livre o topo sai de cena: sem
                                    // preset, sem cordas — só o afinador,
                                    // pronto para qualquer nota.
                                    ClipRect(
                                      child: AnimatedSize(
                                        duration: const Duration(
                                          milliseconds: 320,
                                        ),
                                        curve: Curves.easeOutCubic,
                                        alignment: Alignment.topCenter,
                                        child: chromatic
                                            ? const SizedBox(
                                                width: double.infinity,
                                              )
                                            : _entranceSlot(
                                                1,
                                                _PresetCard(
                                                  controller: controller,
                                                  onTap: _openPresets,
                                                ),
                                              ),
                                      ),
                                    ),
                                    Expanded(
                                      // O bloco central tem tamanho natural fixo; em
                                      // telas curtas ele encolhe junto em vez de
                                      // estourar, e em telas largas o medidor para
                                      // de crescer. O padding garante respiro mínimo
                                      // entre ele, o preset e o painel de baixo.
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 18,
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _entranceSlot(
                                                2,
                                                SizedBox(
                                                  width: 340,
                                                  child: TunerGauge(
                                                    cents: reading?.cents,
                                                    color: accent,
                                                    active:
                                                        controller.isRunning,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 18),
                                              _entranceSlot(
                                                3,
                                                NoteDisplay(
                                                  noteName: reading == null
                                                      ? null
                                                      : kNoteNames[reading
                                                                .targetMidi %
                                                            12],
                                                  octave: reading == null
                                                      ? null
                                                      : (reading.targetMidi ~/
                                                                12) -
                                                            1,
                                                  color: accent,
                                                  inTune:
                                                      status ==
                                                      TuningStatus.inTune,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              _entranceSlot(
                                                4,
                                                _ReadoutRow(reading: reading),
                                              ),
                                              const SizedBox(height: 26),
                                              _entranceSlot(
                                                5,
                                                _StatusPill(
                                                  controller: controller,
                                                  accent: accent,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    _entranceSlot(
                                      6,
                                      ClipRect(
                                        child: AnimatedSize(
                                          duration: const Duration(
                                            milliseconds: 350,
                                          ),
                                          curve: Curves.easeOutCubic,
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 250,
                                            ),
                                            child: chromatic
                                                ? _CapturePanel(
                                                    key: const ValueKey(
                                                      'capture',
                                                    ),
                                                    controller: controller,
                                                    onSave: _saveCapturedPreset,
                                                  )
                                                : StringChips(
                                                    key: const ValueKey(
                                                      'strings',
                                                    ),
                                                    notes: controller
                                                        .activePreset
                                                        .notes,
                                                    targetIndex:
                                                        reading?.stringIndex,
                                                    lockedIndex: controller
                                                        .lockedStringIndex,
                                                    tunedIndices:
                                                        controller.tunedStrings,
                                                    accentColor: accent,
                                                    onTap: controller
                                                        .toggleStringLock,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    _entranceSlot(
                                      7,
                                      _ModeSwitch(
                                        chromatic: chromatic,
                                        accent: accent,
                                        onChanged: (value) {
                                          HapticFeedback.selectionClick();
                                          controller.setMode(
                                            value
                                                ? TargetMode.chromatic
                                                : TargetMode.auto,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                ConfettiBurst(play: _celebrationCount),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Cabeçalho enxuto no lugar de um AppBar: marca à esquerda e as duas ações
/// (calibração e presets) à direita, ocupando só a altura dos botões.
class _BrandBar extends StatelessWidget {
  const _BrandBar({
    required this.controller,
    required this.onCalibration,
    required this.onPresets,
  });

  final TunerController controller;
  final VoidCallback onCalibration;
  final VoidCallback onPresets;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Flexible(child: BrandLockup()),
        const Spacer(),
        _BarAction(
          tooltip: context.l10n.calibrationTooltip(controller.a4.round()),
          icon: Icons.tune_rounded,
          onPressed: onCalibration,
        ),
        const SizedBox(width: 2),
        _BarAction(
          tooltip: context.l10n.presetsTooltip,
          icon: Icons.library_music_rounded,
          onPressed: onPresets,
        ),
      ],
    );
  }
}

/// Seletor de modo: a pista e a seleção são peças de vidro, e a seleção
/// desliza tingida com a cor do estado atual.
class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({
    required this.chromatic,
    required this.accent,
    required this.onChanged,
  });

  final bool chromatic;
  final Color accent;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    const height = 52.0;
    return SizedBox(
      width: 300,
      height: height,
      child: LiquidGlass(
        radius: 26,
        blur: 20,
        rim: 10,
        brightness: 0.85,
        padding: const EdgeInsets.all(4),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: chromatic
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: SizedBox(
                width: 146,
                height: height - 8,
                child: LiquidGlass(
                  radius: 22,
                  blur: 14,
                  rim: 9,
                  brightness: 1.25,
                  tint: accent,
                  tintOpacity: 0.30,
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _ModeOption(
                    icon: Icons.linear_scale_rounded,
                    label: context.l10n.modeStrings,
                    selected: !chromatic,
                    accent: accent,
                    onTap: () => onChanged(false),
                  ),
                ),
                Expanded(
                  child: _ModeOption(
                    icon: Icons.all_inclusive_rounded,
                    label: context.l10n.modeChromatic,
                    selected: chromatic,
                    accent: accent,
                    onTap: () => onChanged(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? accent : AppColors.textSecondary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 19, color: color),
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 240),
              style: TextStyle(
                fontSize: 15,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botão do cabeçalho: caixa quadrada fixa para os dois ícones ficarem do
/// mesmo tamanho, alinhados entre si e com a mesma área de toque.
class _BarAction extends StatelessWidget {
  const _BarAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 44,
      child: LiquidGlass(
        radius: 22,
        blur: 16,
        rim: 8,
        brightness: 0.8,
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          child: Center(
            child: Icon(icon, size: 21, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

/// Painel do modo cromático: notas capturadas viram um preset novo.
class _CapturePanel extends StatelessWidget {
  const _CapturePanel({
    super.key,
    required this.controller,
    required this.onSave,
  });

  final TunerController controller;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    final midis = controller.capturedMidis;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.fiber_manual_record_rounded,
                size: 10,
                color: AppColors.coral,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.captureTitle.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              if (midis.isNotEmpty)
                TextButton(
                  onPressed: controller.clearCapturedNotes,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(context.l10n.captureClear),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (midis.isEmpty)
            Text(
              context.l10n.captureHint,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            )
          else ...[
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < midis.length; i++)
                  TweenAnimationBuilder<double>(
                    key: ValueKey('captured_${i}_${midis[i]}'),
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) =>
                        Transform.scale(scale: value, child: child),
                    child: InputChip(
                      label: Text(
                        midiToName(midis[i]),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.mint,
                        ),
                      ),
                      onDeleted: () {
                        HapticFeedback.selectionClick();
                        controller.removeCapturedNoteAt(i);
                      },
                      deleteIconColor: AppColors.textSecondary,
                      backgroundColor: AppColors.surfaceBright,
                      side: BorderSide(
                        color: AppColors.mint.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.mint,
                  foregroundColor: const Color(0xFF04291C),
                  minimumSize: const Size.fromHeight(50),
                ),
                icon: const Icon(Icons.bookmark_add_rounded, size: 20),
                label: Text(
                  context.l10n.captureSave,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({required this.controller, required this.onTap});

  final TunerController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final preset = controller.activePreset;
    final allTuned = controller.allStringsTuned;
    return LiquidGlass(
      radius: 24,
      blur: 20,
      rim: 10,
      tint: allTuned ? AppColors.mint : null,
      tintOpacity: 0.10,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Hero(
            tag: 'preset-avatar-${preset.id}',
            child: Material(
              type: MaterialType.transparency,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: allTuned
                        ? [AppColors.mint, const Color(0xFF19B380)]
                        : [AppColors.violet, const Color(0xFF5C4DD6)],
                  ),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: allTuned
                        ? const Icon(
                            Icons.check_rounded,
                            key: ValueKey('tuned'),
                            color: Colors.white,
                          )
                        : Text(
                            '${preset.notes.length}',
                            key: const ValueKey('count'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  preset.displayName(context.l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  allTuned
                      ? context.l10n.instrumentTuned
                      : '${preset.instrument.label(context.l10n)} · '
                            '${preset.notes.join(' ')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: allTuned ? AppColors.mint : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.unfold_more_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _ReadoutRow extends StatelessWidget {
  const _ReadoutRow({required this.reading});

  final TunerReading? reading;

  String _format(
    double value,
    String suffix,
    Locale locale, {
    bool sign = false,
  }) {
    final text = formatDecimal(value.abs(), locale);
    final prefix = sign ? (value < 0 ? '−' : '+') : '';
    return '$prefix$text $suffix';
  }

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 14,
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
      fontFeatures: [FontFeature.tabularFigures()],
    );
    final locale = Localizations.localeOf(context);
    final hz = context.l10n.hzUnit;
    final cents = context.l10n.centsUnit;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: reading == null ? 0.0 : 1.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            reading == null ? '— $hz' : _format(reading!.frequency, hz, locale),
            style: style,
          ),
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              color: AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            reading == null
                ? '— $cents'
                : _format(reading!.cents, cents, locale, sign: true),
            style: style,
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.controller, required this.accent});

  final TunerController controller;
  final Color accent;

  String _text(AppLocalizations l10n) {
    if (!controller.isRunning) return l10n.statusMicPaused;
    final status = controller.reading?.status;
    return switch (status) {
      null => l10n.statusListening,
      TuningStatus.tooLow => l10n.statusTooLow,
      TuningStatus.slightlyLow => l10n.statusSlightlyLow,
      TuningStatus.inTune => l10n.statusInTune,
      TuningStatus.slightlyHigh => l10n.statusSlightlyHigh,
      TuningStatus.tooHigh => l10n.statusTooHigh,
    };
  }

  IconData get _icon {
    if (!controller.isRunning) return Icons.mic_off_rounded;
    final status = controller.reading?.status;
    return switch (status) {
      null => Icons.hearing_rounded,
      TuningStatus.tooLow ||
      TuningStatus.slightlyLow => Icons.keyboard_double_arrow_up_rounded,
      TuningStatus.inTune => Icons.check_circle_rounded,
      TuningStatus.tooHigh ||
      TuningStatus.slightlyHigh => Icons.keyboard_double_arrow_down_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final active = controller.reading != null;
    final inTune = controller.reading?.status == TuningStatus.inTune;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      decoration: BoxDecoration(
        color: active
            ? accent.withValues(alpha: 0.12)
            : AppColors.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: active ? accent.withValues(alpha: 0.45) : AppColors.outline,
        ),
        boxShadow: [
          if (inTune)
            BoxShadow(
              color: accent.withValues(alpha: 0.35),
              blurRadius: 26,
              spreadRadius: -4,
            ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.4),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: Row(
          key: ValueKey(_text(context.l10n)),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icon,
              size: 18,
              color: active ? accent : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              _text(context.l10n),
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: active ? accent : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionDeniedView extends StatelessWidget {
  const _PermissionDeniedView({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.surfaceBright,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.mic_off_rounded,
                size: 44,
                color: AppColors.coral,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.permissionTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.permissionBody,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.permissionRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalibrationSheet extends StatefulWidget {
  const _CalibrationSheet({required this.controller});

  final TunerController controller;

  @override
  State<_CalibrationSheet> createState() => _CalibrationSheetState();
}

class _CalibrationSheetState extends State<_CalibrationSheet> {
  /// Janela de desvios (em cents) medidos no modo "calibrar ouvindo".
  static const int _listenWindow = 8;

  /// Dispersão máxima, em cents, para considerar o tom estável.
  static const double _stableSpreadCents = 5.0;

  late double _value = widget.controller.a4;
  final List<double> _measuredCents = <double>[];
  double? _measuredFrequency;
  int? _measuredMidi;

  TunerController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onReading);
  }

  @override
  void dispose() {
    controller.removeListener(_onReading);
    super.dispose();
  }

  void _onReading() {
    if (!mounted) return;
    final reading = controller.reading;
    if (reading == null) {
      if (_measuredFrequency != null) {
        setState(() {
          _measuredCents.clear();
          _measuredFrequency = null;
          _measuredMidi = null;
        });
      }
      return;
    }
    // Desvio da nota cromática mais próxima sob a calibração atual: se o tom
    // de referência é confiável, esse desvio É o erro de calibração.
    final midi = frequencyToMidi(reading.frequency, a4: controller.a4);
    final nearest = midi.round();
    setState(() {
      _measuredCents.add((midi - nearest) * 100.0);
      while (_measuredCents.length > _listenWindow) {
        _measuredCents.removeAt(0);
      }
      _measuredFrequency = reading.frequency;
      _measuredMidi = nearest;
    });
  }

  bool get _isStable {
    if (_measuredCents.length < _listenWindow ~/ 2 + 2) return false;
    final sorted = List.of(_measuredCents)..sort();
    return sorted.last - sorted.first <= _stableSpreadCents;
  }

  double get _medianMeasuredCents {
    final sorted = List.of(_measuredCents)..sort();
    return sorted[sorted.length ~/ 2];
  }

  void _setA4(double value) {
    HapticFeedback.selectionClick();
    setState(
      () => _value = value.clamp(TunerController.minA4, TunerController.maxA4),
    );
    controller.setA4(_value);
  }

  void _applyMeasured() {
    final correction = math.pow(2.0, _medianMeasuredCents / 1200.0);
    HapticFeedback.mediumImpact();
    _setA4(controller.a4 * correction);
    _measuredCents.clear();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final offsetFrom440 = 1200.0 * math.log(_value / 440.0) / math.ln2;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.calibrationTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.calibrationSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  onPressed: () => _setA4(_value - 0.1),
                  tooltip: '−0,1 ${context.l10n.hzUnit}',
                  icon: const Icon(Icons.remove_rounded),
                ),
                SizedBox(
                  width: 170,
                  child: Column(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Text(
                          '${formatDecimal(_value, locale)} '
                          '${context.l10n.hzUnit}',
                          key: ValueKey((_value * 10).round()),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: AppColors.mint,
                          ),
                        ),
                      ),
                      Text(
                        '${offsetFrom440 < 0 ? '−' : '+'}'
                        '${formatDecimal(offsetFrom440.abs(), locale)} '
                        '${context.l10n.centsUnit}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => _setA4(_value + 0.1),
                  tooltip: '+0,1 ${context.l10n.hzUnit}',
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            Slider(
              value: _value.clamp(415, 466),
              min: 415,
              max: 466,
              activeColor: AppColors.mint,
              onChanged: (value) {
                final snapped = (value * 10).roundToDouble() / 10;
                if (snapped != _value) HapticFeedback.selectionClick();
                setState(() => _value = snapped);
              },
              onChangeEnd: (value) => controller.setA4(_value),
            ),
            Center(
              child: TextButton.icon(
                onPressed: () => _setA4(440),
                icon: const Icon(Icons.restart_alt_rounded, size: 18),
                label: Text(context.l10n.calibrationRestore),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            SwitchListTile.adaptive(
              value: controller.hapticGuide,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                controller.setHapticGuide(value);
                setState(() {});
              },
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.mint,
              secondary: const Icon(
                Icons.vibration_rounded,
                size: 20,
                color: AppColors.violet,
              ),
              title: Text(
                context.l10n.hapticGuideTitle,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                context.l10n.hapticGuideHint,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.graphic_eq_rounded,
                  size: 18,
                  color: AppColors.violet,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.calibrationListenTitle,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.calibrationListenHint,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceBright,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _isStable
                      ? AppColors.mint.withValues(alpha: 0.6)
                      : AppColors.outline,
                ),
              ),
              child: _measuredFrequency == null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.hearing_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.calibrationListening,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Text(
                          '${midiToName(_measuredMidi!)} · '
                          '${formatDecimal(_measuredFrequency!, locale)} '
                          '${context.l10n.hzUnit}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_medianMeasuredCents < 0 ? '−' : '+'}'
                          '${formatDecimal(_medianMeasuredCents.abs(), locale)} '
                          '${context.l10n.centsUnit}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _isStable
                                ? AppColors.mint
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          onPressed: _isStable ? _applyMeasured : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.mint,
                            foregroundColor: const Color(0xFF04291C),
                          ),
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: Text(context.l10n.calibrationApply),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
