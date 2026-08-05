import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lattos_tuner/controllers/tuner_controller.dart';
import 'package:lattos_tuner/models/note.dart';
import 'package:lattos_tuner/models/tuner_reading.dart';
import 'package:lattos_tuner/views/screens/presets_screen.dart';
import 'package:lattos_tuner/views/theme.dart';
import 'package:lattos_tuner/views/widgets/note_display.dart';
import 'package:lattos_tuner/views/widgets/string_chips.dart';
import 'package:lattos_tuner/views/widgets/tuner_gauge.dart';

/// Tela principal: medidor, nota alvo, cordas do preset e status.
class TunerScreen extends StatefulWidget {
  const TunerScreen({super.key, required this.controller});

  final TunerController controller;

  @override
  State<TunerScreen> createState() => _TunerScreenState();
}

class _TunerScreenState extends State<TunerScreen>
    with WidgetsBindingObserver {
  int _lastTunedCount = 0;
  bool _celebrated = false;

  TunerController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller.addListener(_onControllerChange);
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.start());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.removeListener(_onControllerChange);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      controller.start();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      controller.stop();
    }
  }

  void _onControllerChange() {
    final tunedCount = controller.tunedStrings.length;
    if (tunedCount > _lastTunedCount) {
      HapticFeedback.mediumImpact();
    }
    _lastTunedCount = tunedCount;
    if (controller.allStringsTuned && !_celebrated) {
      _celebrated = true;
      HapticFeedback.heavyImpact();
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final reading = controller.reading;
        final status = reading?.status;
        final accent = statusColor(status);
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text('LATTOS TUNER'),
            actions: [
              IconButton(
                tooltip: 'Calibração (A4 = ${controller.a4.round()} Hz)',
                icon: const Icon(Icons.tune_rounded),
                onPressed: _openCalibration,
              ),
              IconButton(
                tooltip: 'Presets de afinação',
                icon: const Icon(Icons.library_music_rounded),
                onPressed: _openPresets,
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.6),
                radius: 1.3,
                colors: [
                  accent.withValues(alpha: 0.16),
                  AppColors.background,
                ],
              ),
            ),
            child: SafeArea(
              child: controller.permissionDenied
                  ? _PermissionDeniedView(onRetry: controller.start)
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: Column(
                        children: [
                          _PresetCard(
                            controller: controller,
                            onTap: _openPresets,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TunerGauge(
                                  cents: reading?.cents,
                                  color: accent,
                                  active: controller.isRunning,
                                ),
                                const SizedBox(height: 8),
                                NoteDisplay(
                                  noteName: reading == null
                                      ? null
                                      : kNoteNames[reading.targetMidi % 12],
                                  octave: reading == null
                                      ? null
                                      : (reading.targetMidi ~/ 12) - 1,
                                  color: accent,
                                  inTune: status == TuningStatus.inTune,
                                ),
                                const SizedBox(height: 4),
                                _ReadoutRow(reading: reading),
                                const SizedBox(height: 12),
                                _StatusPill(
                                  controller: controller,
                                  accent: accent,
                                ),
                              ],
                            ),
                          ),
                          if (controller.mode != TargetMode.chromatic)
                            StringChips(
                              notes: controller.activePreset.notes,
                              targetIndex: reading?.stringIndex,
                              lockedIndex: controller.lockedStringIndex,
                              tunedIndices: controller.tunedStrings,
                              accentColor: accent,
                              onTap: controller.toggleStringLock,
                            ),
                          const SizedBox(height: 16),
                          SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment(
                                value: false,
                                label: Text('Cordas'),
                                icon: Icon(Icons.linear_scale_rounded),
                              ),
                              ButtonSegment(
                                value: true,
                                label: Text('Cromático'),
                                icon: Icon(Icons.piano_rounded),
                              ),
                            ],
                            selected: {
                              controller.mode == TargetMode.chromatic,
                            },
                            onSelectionChanged: (selection) {
                              HapticFeedback.selectionClick();
                              controller.setMode(
                                selection.first
                                    ? TargetMode.chromatic
                                    : TargetMode.auto,
                              );
                            },
                            style: SegmentedButton.styleFrom(
                              selectedBackgroundColor:
                                  accent.withValues(alpha: 0.18),
                              selectedForegroundColor: accent,
                              foregroundColor: AppColors.textSecondary,
                              side: const BorderSide(color: AppColors.outline),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
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
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              AnimatedContainer(
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preset.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      allTuned
                          ? 'Instrumento afinado! 🤘'
                          : '${preset.instrument.label} · '
                              '${preset.notes.join(' ')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: allTuned
                            ? AppColors.mint
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.unfold_more_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadoutRow extends StatelessWidget {
  const _ReadoutRow({required this.reading});

  final TunerReading? reading;

  String _format(double value, String suffix, {bool sign = false}) {
    final text = value.abs().toStringAsFixed(1).replaceAll('.', ',');
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
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: reading == null ? 0.0 : 1.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            reading == null ? '— Hz' : _format(reading!.frequency, 'Hz'),
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
                ? '— cents'
                : _format(reading!.cents, 'cents', sign: true),
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

  String get _text {
    if (!controller.isRunning) return 'Microfone pausado';
    final status = controller.reading?.status;
    return switch (status) {
      null => 'Toque uma corda…',
      TuningStatus.tooLow => 'Muito baixo — aperte a corda',
      TuningStatus.slightlyLow => 'Quase lá — aperte de leve',
      TuningStatus.inTune => 'Afinado!',
      TuningStatus.slightlyHigh => 'Quase lá — solte de leve',
      TuningStatus.tooHigh => 'Muito alto — solte a corda',
    };
  }

  IconData get _icon {
    if (!controller.isRunning) return Icons.mic_off_rounded;
    final status = controller.reading?.status;
    return switch (status) {
      null => Icons.hearing_rounded,
      TuningStatus.tooLow || TuningStatus.slightlyLow =>
        Icons.keyboard_double_arrow_up_rounded,
      TuningStatus.inTune => Icons.check_circle_rounded,
      TuningStatus.tooHigh || TuningStatus.slightlyHigh =>
        Icons.keyboard_double_arrow_down_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final active = controller.reading != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: active
            ? accent.withValues(alpha: 0.14)
            : AppColors.surfaceBright,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: active ? accent.withValues(alpha: 0.5) : AppColors.outline,
        ),
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
          key: ValueKey(_text),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icon,
              size: 18,
              color: active ? accent : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              _text,
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
            const Text(
              'Sem acesso ao microfone',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Para afinar seu instrumento, o Lattos Tuner precisa ouvir '
              'o som das cordas. Conceda a permissão de microfone nas '
              'configurações do aparelho.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
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
  late double _value = widget.controller.a4;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Calibração da referência',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Frequência do A4 (padrão: 440 Hz)',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Text(
                '${_value.round()} Hz',
                key: ValueKey(_value.round()),
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: AppColors.mint,
                ),
              ),
            ),
            Slider(
              value: _value.roundToDouble(),
              min: 415,
              max: 466,
              divisions: 51,
              activeColor: AppColors.mint,
              onChanged: (value) {
                if (value.round() != _value.round()) {
                  HapticFeedback.selectionClick();
                }
                setState(() => _value = value);
              },
              onChangeEnd: (value) =>
                  widget.controller.setA4(value.roundToDouble()),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() => _value = 440);
                widget.controller.setA4(440);
              },
              icon: const Icon(Icons.restart_alt_rounded, size: 18),
              label: const Text('Restaurar 440 Hz'),
            ),
          ],
        ),
      ),
    );
  }
}
