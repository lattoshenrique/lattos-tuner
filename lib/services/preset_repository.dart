import 'dart:convert';

import 'package:lattos_tuner/models/note.dart';
import 'package:lattos_tuner/models/tuning_preset.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistência dos presets customizados, do preset ativo e da calibração
/// do A4, usando [SharedPreferences].
class PresetRepository {
  PresetRepository(this._prefs);

  static const String customPresetsKey = 'custom_presets_v1';
  static const String activePresetKey = 'active_preset_id';
  static const String a4ReferenceKey = 'a4_reference';
  static const String hapticGuideKey = 'haptic_guide_enabled';

  static const List<TuningPreset> builtInPresets = [
    TuningPreset(
      id: 'builtin_guitar_standard',
      name: 'Padrão (E A D G B E)',
      instrument: Instrument.guitar,
      notes: ['E2', 'A2', 'D3', 'G3', 'B3', 'E4'],
      isBuiltIn: true,
    ),
    TuningPreset(
      // O id preserva o nome histórico ("SOAD") para não invalidar o
      // preset ativo salvo em versões anteriores.
      id: 'builtin_soad_drop_c',
      name: 'Drop C',
      instrument: Instrument.guitar,
      notes: ['C2', 'G2', 'C3', 'F3', 'A3', 'D4'],
      isBuiltIn: true,
    ),
    TuningPreset(
      id: 'builtin_drop_d',
      name: 'Drop D',
      instrument: Instrument.guitar,
      notes: ['D2', 'A2', 'D3', 'G3', 'B3', 'E4'],
      isBuiltIn: true,
    ),
    TuningPreset(
      id: 'builtin_half_step_down',
      name: 'Meio tom abaixo (Eb)',
      instrument: Instrument.guitar,
      notes: ['D#2', 'G#2', 'C#3', 'F#3', 'A#3', 'D#4'],
      isBuiltIn: true,
    ),
    TuningPreset(
      id: 'builtin_drop_c_sharp',
      name: 'Drop C#',
      instrument: Instrument.guitar,
      notes: ['C#2', 'G#2', 'C#3', 'F#3', 'A#3', 'D#4'],
      isBuiltIn: true,
    ),
    TuningPreset(
      id: 'builtin_drop_b',
      name: 'Drop B',
      instrument: Instrument.guitar,
      notes: ['B1', 'F#2', 'B2', 'E3', 'G#3', 'C#4'],
      isBuiltIn: true,
    ),
    TuningPreset(
      id: 'builtin_drop_a',
      name: 'Drop A',
      instrument: Instrument.guitar,
      notes: ['A1', 'E2', 'A2', 'D3', 'F#3', 'B3'],
      isBuiltIn: true,
    ),
    TuningPreset(
      id: 'builtin_d_standard',
      name: 'Um tom abaixo (D)',
      instrument: Instrument.guitar,
      notes: ['D2', 'G2', 'C3', 'F3', 'A3', 'D4'],
      isBuiltIn: true,
    ),
    TuningPreset(
      id: 'builtin_c_standard',
      name: 'Padrão em C',
      instrument: Instrument.guitar,
      notes: ['C2', 'F2', 'A#2', 'D#3', 'G3', 'C4'],
      isBuiltIn: true,
    ),
    TuningPreset(
      id: 'builtin_dadgad',
      name: 'DADGAD',
      instrument: Instrument.guitar,
      notes: ['D2', 'A2', 'D3', 'G3', 'A3', 'D4'],
      isBuiltIn: true,
    ),
    TuningPreset(
      id: 'builtin_open_g',
      name: 'Open G',
      instrument: Instrument.guitar,
      notes: ['D2', 'G2', 'D3', 'G3', 'B3', 'D4'],
      isBuiltIn: true,
    ),
    TuningPreset(
      id: 'builtin_open_d',
      name: 'Open D',
      instrument: Instrument.guitar,
      notes: ['D2', 'A2', 'D3', 'F#3', 'A3', 'D4'],
      isBuiltIn: true,
    ),
    TuningPreset(
      id: 'builtin_guitar_7',
      name: '7 cordas (B E A D G B E)',
      instrument: Instrument.guitar,
      notes: ['B1', 'E2', 'A2', 'D3', 'G3', 'B3', 'E4'],
      isBuiltIn: true,
    ),
    TuningPreset(
      id: 'builtin_bass_standard',
      name: 'Baixo – Padrão (E A D G)',
      instrument: Instrument.bass,
      notes: ['E1', 'A1', 'D2', 'G2'],
      isBuiltIn: true,
    ),
    TuningPreset(
      id: 'builtin_bass_5_strings',
      name: 'Baixo – 5 cordas',
      instrument: Instrument.bass,
      notes: ['B0', 'E1', 'A1', 'D2', 'G2'],
      isBuiltIn: true,
    ),
    TuningPreset(
      id: 'builtin_ukulele',
      name: 'Ukulele – Padrão (G C E A)',
      instrument: Instrument.ukulele,
      notes: ['G4', 'C4', 'E4', 'A4'],
      isBuiltIn: true,
    ),
    TuningPreset(
      id: 'builtin_cavaquinho',
      name: 'Cavaquinho (D G B D)',
      instrument: Instrument.cavaquinho,
      notes: ['D4', 'G4', 'B4', 'D5'],
      isBuiltIn: true,
    ),
    TuningPreset(
      id: 'builtin_mandolin',
      name: 'Bandolim (G D A E)',
      instrument: Instrument.other,
      notes: ['G3', 'D4', 'A4', 'E5'],
      isBuiltIn: true,
    ),
  ];

  final SharedPreferences _prefs;

  List<TuningPreset> loadCustomPresets() {
    final raw = _prefs.getString(customPresetsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => TuningPreset.fromJson(item as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return [];
    }
  }

  Future<void> _saveCustomPresets(List<TuningPreset> presets) async {
    final encoded = jsonEncode(presets.map((p) => p.toJson()).toList());
    await _prefs.setString(customPresetsKey, encoded);
  }

  /// Insere ou atualiza (por id) um preset customizado.
  Future<void> upsertCustomPreset(TuningPreset preset) async {
    final presets = loadCustomPresets();
    final index = presets.indexWhere((p) => p.id == preset.id);
    if (index == -1) {
      presets.add(preset);
    } else {
      presets[index] = preset;
    }
    await _saveCustomPresets(presets);
  }

  Future<void> deleteCustomPreset(String id) async {
    final presets = loadCustomPresets()..removeWhere((p) => p.id == id);
    await _saveCustomPresets(presets);
  }

  String? get activePresetId => _prefs.getString(activePresetKey);

  Future<void> setActivePresetId(String id) =>
      _prefs.setString(activePresetKey, id);

  double get a4Reference => _prefs.getDouble(a4ReferenceKey) ?? kDefaultA4;

  Future<void> setA4Reference(double value) =>
      _prefs.setDouble(a4ReferenceKey, value);

  /// Guia tátil ligado por padrão: é o que permite afinar sem olhar a tela.
  bool get hapticGuide => _prefs.getBool(hapticGuideKey) ?? true;

  Future<void> setHapticGuide(bool value) =>
      _prefs.setBool(hapticGuideKey, value);
}
