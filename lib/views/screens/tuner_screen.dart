import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lattos_tuner/controllers/tuner_controller.dart';
import 'package:lattos_tuner/models/note.dart';
import 'package:lattos_tuner/models/tuner_reading.dart';
import 'package:lattos_tuner/models/tuning_preset.dart';
import 'package:lattos_tuner/views/l10n.dart';
import 'package:lattos_tuner/views/screens/preset_editor_screen.dart';
import 'package:lattos_tuner/views/screens/presets_screen.dart';
import 'package:lattos_tuner/views/theme.dart';
import 'package:lattos_tuner/views/widgets/aurora_background.dart';
import 'package:lattos_tuner/views/widgets/confetti_burst.dart';
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

  int _lastTunedCount = 0;
  int _lastCapturedCount = 0;
  bool _celebrated = false;
  int _celebrationCount = 0;

  TunerController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller.addListener(_onControllerChange);
    WakelockPlus.enable();
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.start());
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    WidgetsBinding.instance.removeObserver(this);
    controller.removeListener(_onControllerChange);
    _entrance.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WakelockPlus.enable();
      controller.start();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      WakelockPlus.disable();
      controller.stop();
    }
  }

  void _onControllerChange() {
    final tunedCount = controller.tunedStrings.length;
    if (tunedCount > _lastTunedCount) {
      HapticFeedback.mediumImpact();
    }
    _lastTunedCount = tunedCount;

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
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.l10n.tunerTitle),
                Text(
                  context.l10n.tagline,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: AppColors.textSecondary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: context.l10n.calibrationTooltip(controller.a4.round()),
                icon: const Icon(Icons.tune_rounded),
                onPressed: _openCalibration,
              ),
              IconButton(
                tooltip: context.l10n.presetsTooltip,
                icon: const Icon(Icons.library_music_rounded),
                onPressed: _openPresets,
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: Stack(
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
              AuroraBackground(accent: accent),
              SafeArea(
                child: controller.permissionDenied
                    ? _PermissionDeniedView(onRetry: controller.start)
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        child: Column(
                          children: [
                            _entranceSlot(
                              0,
                              _PresetCard(
                                controller: controller,
                                onTap: _openPresets,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _entranceSlot(
                                    1,
                                    TunerGauge(
                                      cents: reading?.cents,
                                      color: accent,
                                      active: controller.isRunning,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _entranceSlot(
                                    2,
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
                                  ),
                                  const SizedBox(height: 4),
                                  _entranceSlot(
                                    3,
                                    _ReadoutRow(reading: reading),
                                  ),
                                  const SizedBox(height: 12),
                                  _entranceSlot(
                                    4,
                                    _StatusPill(
                                      controller: controller,
                                      accent: accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _entranceSlot(
                              5,
                              ClipRect(
                                child: AnimatedSize(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeOutCubic,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    child: chromatic
                                        ? _CapturePanel(
                                            key: const ValueKey('capture'),
                                            controller: controller,
                                            onSave: _saveCapturedPreset,
                                          )
                                        : StringChips(
                                            key: const ValueKey('strings'),
                                            notes:
                                                controller.activePreset.notes,
                                            targetIndex: reading?.stringIndex,
                                            lockedIndex:
                                                controller.lockedStringIndex,
                                            tunedIndices:
                                                controller.tunedStrings,
                                            accentColor: accent,
                                            onTap: controller.toggleStringLock,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _entranceSlot(
                              6,
                              SegmentedButton<bool>(
                                segments: [
                                  ButtonSegment(
                                    value: false,
                                    label: Text(context.l10n.modeStrings),
                                    icon: const Icon(
                                      Icons.linear_scale_rounded,
                                    ),
                                  ),
                                  ButtonSegment(
                                    value: true,
                                    label: Text(context.l10n.modeChromatic),
                                    icon: const Icon(Icons.piano_rounded),
                                  ),
                                ],
                                selected: {chromatic},
                                onSelectionChanged: (selection) {
                                  HapticFeedback.selectionClick();
                                  controller.setMode(
                                    selection.first
                                        ? TargetMode.chromatic
                                        : TargetMode.auto,
                                  );
                                },
                                style: SegmentedButton.styleFrom(
                                  selectedBackgroundColor: accent.withValues(
                                    alpha: 0.18,
                                  ),
                                  selectedForegroundColor: accent,
                                  foregroundColor: AppColors.textSecondary,
                                  side: const BorderSide(
                                    color: AppColors.outline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              ConfettiBurst(play: _celebrationCount),
            ],
          ),
        );
      },
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
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
          const SizedBox(height: 8),
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
              spacing: 8,
              runSpacing: 8,
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
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.mint,
                  foregroundColor: const Color(0xFF04291C),
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
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              const SizedBox(width: 12),
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
                    const SizedBox(height: 2),
                    Text(
                      allTuned
                          ? context.l10n.instrumentTuned
                          : '${preset.instrument.label(context.l10n)} · '
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: active
            ? accent.withValues(alpha: 0.14)
            : AppColors.surfaceBright,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: active ? accent.withValues(alpha: 0.5) : AppColors.outline,
        ),
        boxShadow: [
          if (inTune)
            BoxShadow(
              color: accent.withValues(alpha: 0.4),
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
