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
  }) : _repository = repository,
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

  /// Proximidade, em cents, dentro da qual uma corda é escolhida direto por
  /// distância, sem heurística de direção.
  static const double stringSnapCents = 140.0;

  /// Variação de cents na janela recente que caracteriza o usuário
  /// apertando ou soltando a tarraxa.
  static const double trendThresholdCents = 25.0;

  /// Quantidade de leituras usadas para estimar a tendência do pitch.
  static const int trendWindow = 8;

  /// Salto de cents entre leituras que indica uma nota nova (outra corda),
  /// zerando a suavização e a tendência.
  static const double noteJumpCents = 250.0;

  /// Máximo de notas capturadas ao criar um preset pela tela do afinador.
  static const int maxCapturedNotes = 12;

  final PresetRepository _repository;
  final PitchSource _pitchSource;
  final Queue<double> _recentFrequencies = Queue<double>();
  final Queue<double> _trendFrequencies = Queue<double>();
  final List<int> _capturedMidis = <int>[];

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
  int? _stableTargetMidi;
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

  /// Notas capturadas no modo cromático para criar um preset (ordem tocada).
  List<int> get capturedMidis => List.unmodifiable(_capturedMidis);
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
    _activePreset =
        _findPreset(activeId) ?? PresetRepository.builtInPresets.first;
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
    // Um salto grande de pitch significa outra corda/nota: a suavização e a
    // tendência da nota anterior deixam de valer.
    if (_recentFrequencies.isNotEmpty &&
        centsBetween(estimate.frequency, _recentFrequencies.last).abs() >
            noteJumpCents) {
      _recentFrequencies.clear();
      _trendFrequencies.clear();
    }
    _recentFrequencies.addLast(estimate.frequency);
    while (_recentFrequencies.length > smoothingWindow) {
      _recentFrequencies.removeFirst();
    }
    _trendFrequencies.addLast(estimate.frequency);
    while (_trendFrequencies.length > trendWindow) {
      _trendFrequencies.removeFirst();
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
          : _selectStringIndex(frequency);
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

  /// Escolhe a corda alvo do preset para a frequência tocada.
  ///
  /// Perto de uma corda (dentro de [stringSnapCents]) vale a proximidade.
  /// Na zona ambígua entre duas cordas, a direção decide: se o pitch está
  /// subindo, o alvo é a corda acima; descendo, a de baixo; sem movimento,
  /// mantém o alvo anterior ou assume que o usuário está descendo para uma
  /// afinação mais grave — o caso típico de sair do padrão para Drop C
  /// (ex.: E2 solto deve mirar C2 e pedir para soltar, não G2 e apertar).
  int _selectStringIndex(double frequency) {
    var nearestIndex = 0;
    var nearestDistance = double.infinity;
    int? belowIndex;
    var belowDistance = double.infinity;
    int? aboveIndex;
    var aboveDistance = double.infinity;
    for (var i = 0; i < _activePreset.notes.length; i++) {
      final midi = nameToMidi(_activePreset.notes[i]);
      if (midi == null) continue;
      final target = midiToFrequency(midi.toDouble(), a4: _a4);
      final cents = centsBetween(frequency, target);
      if (cents.abs() < nearestDistance) {
        nearestDistance = cents.abs();
        nearestIndex = i;
      }
      if (cents >= 0 && cents < belowDistance) {
        belowDistance = cents;
        belowIndex = i;
      }
      if (cents < 0 && -cents < aboveDistance) {
        aboveDistance = -cents;
        aboveIndex = i;
      }
    }
    if (nearestDistance <= stringSnapCents) return nearestIndex;
    if (belowIndex == null || aboveIndex == null) return nearestIndex;
    final trend = _pitchTrendCents();
    if (trend >= trendThresholdCents) return aboveIndex;
    if (trend <= -trendThresholdCents) return belowIndex;
    final previous = _reading?.stringIndex;
    if (previous == belowIndex || previous == aboveIndex) return previous!;
    return belowIndex;
  }

  /// Tendência do pitch na janela recente, em cents (positivo = subindo).
  double _pitchTrendCents() {
    if (_trendFrequencies.length < 4) return 0;
    final samples = _trendFrequencies.toList();
    final half = samples.length ~/ 2;
    final older = samples.sublist(0, half)..sort();
    final newer = samples.sublist(half)..sort();
    return centsBetween(newer[newer.length ~/ 2], older[older.length ~/ 2]);
  }

  TuningStatus _statusForCents(double cents) {
    if (cents.abs() <= inTuneCents) return TuningStatus.inTune;
    if (cents <= -slightlyOffCents) return TuningStatus.tooLow;
    if (cents >= slightlyOffCents) return TuningStatus.tooHigh;
    return cents < 0 ? TuningStatus.slightlyLow : TuningStatus.slightlyHigh;
  }

  void _trackStability(TunerReading reading) {
    if (reading.status == TuningStatus.inTune &&
        reading.targetMidi == _stableTargetMidi) {
      _stableCount++;
    } else {
      _stableTargetMidi = reading.targetMidi;
      _stableCount = reading.status == TuningStatus.inTune ? 1 : 0;
    }
    if (_stableCount != stableReadingsToConfirm) return;
    final index = reading.stringIndex;
    if (index != null) {
      _tunedStrings.add(index);
    } else if (_mode == TargetMode.chromatic) {
      _captureNote(reading.targetMidi);
    }
  }

  void _captureNote(int midi) {
    if (_capturedMidis.length >= maxCapturedNotes) return;
    if (_capturedMidis.isNotEmpty && _capturedMidis.last == midi) return;
    _capturedMidis.add(midi);
  }

  /// Remove uma nota capturada (índice na lista exibida).
  void removeCapturedNoteAt(int index) {
    if (index < 0 || index >= _capturedMidis.length) return;
    _capturedMidis.removeAt(index);
    notifyListeners();
  }

  void clearCapturedNotes() {
    if (_capturedMidis.isEmpty) return;
    _capturedMidis.clear();
    notifyListeners();
  }

  void _clearReading() {
    _reading = null;
    _recentFrequencies.clear();
    _trendFrequencies.clear();
    _silenceCount = 0;
    _stableCount = 0;
    _stableTargetMidi = null;
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
