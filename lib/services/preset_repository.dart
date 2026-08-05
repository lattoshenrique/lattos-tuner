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

  static const List<TuningPreset> builtInPresets = [
    TuningPreset(
      id: 'builtin_guitar_standard',
      name: 'Padrão (E A D G B E)',
      instrument: Instrument.guitar,
      notes: ['E2', 'A2', 'D3', 'G3', 'B3', 'E4'],
      isBuiltIn: true,
    ),
    TuningPreset(
      id: 'builtin_soad_drop_c',
      name: 'SOAD – Drop C',
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
}
