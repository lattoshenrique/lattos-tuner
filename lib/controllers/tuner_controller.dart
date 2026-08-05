import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:lattos_tuner/models/note.dart';
import 'package:lattos_tuner/models/pitch_estimate.dart';
import 'package:lattos_tuner/models/tuner_reading.dart';
import 'package:lattos_tuner/models/tuning_preset.dart';
import 'package:lattos_tuner/services/audio/tuner_audio_service.dart';
import 'package:lattos_tuner/services/preset_repository.dart';

/// Orquestra a fonte de pitch, o preset ativo e o estado exibido pela UI.
class TunerController extends ChangeNotifier {
  TunerController({
    required PresetRepository repository,
    required PitchSource pitchSource,
  })  : _repository = repository,
        _pitchSource = pitchSource;

  /// Desvio máximo, em cents, considerado afinado.
  static const double inTuneCents = 5.0;

  /// Desvio máximo, em cents, considerado "quase lá".
  static const double slightlyOffCents = 15.0;

  /// Quantas leituras consecutivas afinadas marcam a corda como concluída.
  static const int stableReadingsToConfirm = 3;

  /// Janela da mediana usada para suavizar a frequência exibida.
  static const int smoothingWindow = 5;

  /// Leituras nulas consecutivas antes de limpar o display.
  static const int silenceReadingsToClear = 10;

  final PresetRepository _repository;
  final PitchSource _pitchSource;
  final Queue<double> _recentFrequencies = Queue<double>();

  StreamSubscription<PitchEstimate?>? _subscription;
  List<TuningPreset> _customPresets = [];
  late TuningPreset _activePreset;
  double _a4 = kDefaultA4;
  TargetMode _mode = TargetMode.auto;
  int? _lockedStringIndex;
  TunerReading? _reading;
  final Set<int> _tunedStrings = <int>{};
  int _silenceCount = 0;
  int _stableCount = 0;
  int? _stableStringIndex;
  bool _running = false;
  bool _permissionDenied = false;
  bool _initialized = false;

  List<TuningPreset> get builtInPresets => PresetRepository.builtInPresets;
  List<TuningPreset> get customPresets => List.unmodifiable(_customPresets);
  TuningPreset get activePreset => _activePreset;
  double get a4 => _a4;
  TargetMode get mode => _mode;
  int? get lockedStringIndex => _lockedStringIndex;
  TunerReading? get reading => _reading;
  Set<int> get tunedStrings => Set.unmodifiable(_tunedStrings);
  bool get isRunning => _running;
  bool get permissionDenied => _permissionDenied;
  bool get allStringsTuned =>
      _mode != TargetMode.chromatic &&
      _tunedStrings.length == _activePreset.notes.length;

  /// Carrega estado persistido. Deve ser chamado antes do primeiro uso.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _a4 = _repository.a4Reference;
    _customPresets = _repository.loadCustomPresets();
    final activeId = _repository.activePresetId;
    _activePreset = _findPreset(activeId) ?? PresetRepository.builtInPresets.first;
    _subscription = _pitchSource.pitchStream.listen(handleEstimate);
  }

  TuningPreset? _findPreset(String? id) {
    if (id == null) return null;
    for (final preset in PresetRepository.builtInPresets) {
      if (preset.id == id) return preset;
    }
    for (final preset in _customPresets) {
      if (preset.id == id) return preset;
    }
    return null;
  }

  Future<void> start() async {
    if (_running) return;
    final granted = await _pitchSource.start();
    _permissionDenied = !granted;
    _running = granted;
    notifyListeners();
  }

  Future<void> stop() async {
    if (!_running) return;
    _running = false;
    await _pitchSource.stop();
    _clearReading();
    notifyListeners();
  }

  Future<void> setActivePreset(TuningPreset preset) async {
    if (preset.id == _activePreset.id) return;
    _activePreset = preset;
    _resetSession();
    await _repository.setActivePresetId(preset.id);
    notifyListeners();
  }

  void setMode(TargetMode mode) {
    if (mode == _mode) return;
    _mode = mode;
    if (mode != TargetMode.manual) _lockedStringIndex = null;
    notifyListeners();
  }

  /// Alterna o travamento manual em uma corda: tocar de novo volta ao auto.
  void toggleStringLock(int index) {
    if (_mode == TargetMode.manual && _lockedStringIndex == index) {
      _mode = TargetMode.auto;
      _lockedStringIndex = null;
    } else {
      _mode = TargetMode.manual;
      _lockedStringIndex = index;
    }
    notifyListeners();
  }

  Future<void> setA4(double value) async {
    _a4 = value;
    await _repository.setA4Reference(value);
    _resetSession();
    notifyListeners();
  }

  Future<void> saveCustomPreset(TuningPreset preset) async {
    await _repository.upsertCustomPreset(preset);
    _customPresets = _repository.loadCustomPresets();
    if (preset.id == _activePreset.id) {
      _activePreset = preset;
      _resetSession();
    }
    notifyListeners();
  }

  Future<void> deleteCustomPreset(String id) async {
    await _repository.deleteCustomPreset(id);
    _customPresets = _repository.loadCustomPresets();
    if (_activePreset.id == id) {
      await setActivePreset(PresetRepository.builtInPresets.first);
      return;
    }
    notifyListeners();
  }

  /// Consome uma estimativa da fonte de pitch. Exposto para testes.
  @visibleForTesting
  void handleEstimate(PitchEstimate? estimate) {
    if (estimate == null) {
      _silenceCount++;
      if (_silenceCount >= silenceReadingsToClear && _reading != null) {
        _clearReading();
        notifyListeners();
      }
      return;
    }
    _silenceCount = 0;
    _recentFrequencies.addLast(estimate.frequency);
    while (_recentFrequencies.length > smoothingWindow) {
      _recentFrequencies.removeFirst();
    }
    final frequency = _medianFrequency();
    _reading = _buildReading(frequency);
    _trackStability(_reading!);
    notifyListeners();
  }

  double _medianFrequency() {
    final sorted = _recentFrequencies.toList()..sort();
    final middle = sorted.length ~/ 2;
    if (sorted.length.isOdd) return sorted[middle];
    return (sorted[middle - 1] + sorted[middle]) / 2.0;
  }

  TunerReading _buildReading(double frequency) {
    int targetMidi;
    int? stringIndex;
    if (_mode == TargetMode.chromatic || _activePreset.notes.isEmpty) {
      targetMidi = frequencyToMidi(frequency, a4: _a4).round();
    } else {
      stringIndex = _mode == TargetMode.manual && _lockedStringIndex != null
          ? _lockedStringIndex!
          : _nearestStringIndex(frequency);
      targetMidi = nameToMidi(_activePreset.notes[stringIndex]) ?? 69;
    }
    final targetFrequency = midiToFrequency(targetMidi.toDouble(), a4: _a4);
    final cents = centsBetween(frequency, targetFrequency);
    return TunerReading(
      frequency: frequency,
      targetMidi: targetMidi,
      cents: cents,
      status: _statusForCents(cents),
      stringIndex: stringIndex,
    );
  }

  int _nearestStringIndex(double frequency) {
    var bestIndex = 0;
    var bestDistance = double.infinity;
    for (var i = 0; i < _activePreset.notes.length; i++) {
      final midi = nameToMidi(_activePreset.notes[i]);
      if (midi == null) continue;
      final target = midiToFrequency(midi.toDouble(), a4: _a4);
      final distance = centsBetween(frequency, target).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  TuningStatus _statusForCents(double cents) {
    if (cents.abs() <= inTuneCents) return TuningStatus.inTune;
    if (cents <= -slightlyOffCents) return TuningStatus.tooLow;
    if (cents >= slightlyOffCents) return TuningStatus.tooHigh;
    return cents < 0 ? TuningStatus.slightlyLow : TuningStatus.slightlyHigh;
  }

  void _trackStability(TunerReading reading) {
    final index = reading.stringIndex;
    if (index == null) return;
    if (reading.status == TuningStatus.inTune && index == _stableStringIndex) {
      _stableCount++;
    } else {
      _stableStringIndex = index;
      _stableCount = reading.status == TuningStatus.inTune ? 1 : 0;
    }
    if (_stableCount >= stableReadingsToConfirm) {
      _tunedStrings.add(index);
    }
  }

  void _clearReading() {
    _reading = null;
    _recentFrequencies.clear();
    _silenceCount = 0;
    _stableCount = 0;
    _stableStringIndex = null;
  }

  void _resetSession() {
    _tunedStrings.clear();
    _lockedStringIndex = null;
    if (_mode == TargetMode.manual) _mode = TargetMode.auto;
    _clearReading();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _pitchSource.dispose();
    super.dispose();
  }
}
