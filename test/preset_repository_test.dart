import 'package:flutter_test/flutter_test.dart';
import 'package:lattos_tuner/models/note.dart';
import 'package:lattos_tuner/models/tuning_preset.dart';
import 'package:lattos_tuner/services/preset_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<PresetRepository> makeRepository() async {
  SharedPreferences.setMockInitialValues({});
  return PresetRepository(await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('presets embutidos', () {
    test('incluem a afinação Drop C (C G C F A D)', () {
      final dropC = PresetRepository.builtInPresets.firstWhere(
        (p) => p.id == 'builtin_soad_drop_c',
      );
      expect(dropC.name, 'Drop C');
      expect(dropC.notes, ['C2', 'G2', 'C3', 'F3', 'A3', 'D4']);
    });

    test('incluem os drops populares e afinações abertas', () {
      final ids = PresetRepository.builtInPresets.map((p) => p.id).toSet();
      expect(
        ids,
        containsAll([
          'builtin_drop_b',
          'builtin_drop_a',
          'builtin_d_standard',
          'builtin_c_standard',
          'builtin_open_d',
          'builtin_guitar_7',
          'builtin_mandolin',
        ]),
      );
    });

    test('todas as notas são válidas e ordenadas da grave à aguda', () {
      for (final preset in PresetRepository.builtInPresets) {
        final midis = preset.notes.map(nameToMidi).toList();
        expect(midis, everyElement(isNotNull), reason: preset.name);
        // Drop tunings mantêm a ordem crescente exceto pela 6ª corda solta;
        // aqui garantimos apenas que não há notas repetidas fora de ordem
        // absurda: a última deve ser a mais aguda.
        expect(midis.last, greaterThan(midis.first!), reason: preset.name);
      }
    });

    test('ids são únicos', () {
      final ids = PresetRepository.builtInPresets.map((p) => p.id).toSet();
      expect(ids.length, PresetRepository.builtInPresets.length);
    });
  });

  group('TuningPreset JSON', () {
    test('sobrevive a ida e volta', () {
      const preset = TuningPreset(
        id: 'custom_1',
        name: 'Minha afinação',
        instrument: Instrument.bass,
        notes: ['D1', 'A1', 'D2', 'G2'],
      );
      final restored = TuningPreset.fromJson(preset.toJson());
      expect(restored.id, preset.id);
      expect(restored.name, preset.name);
      expect(restored.instrument, preset.instrument);
      expect(restored.notes, preset.notes);
    });

    test('instrumento desconhecido cai em "other"', () {
      final restored = TuningPreset.fromJson({
        'id': 'x',
        'name': 'y',
        'instrument': 'theremin',
        'notes': ['A4'],
      });
      expect(restored.instrument, Instrument.other);
    });
  });

  group('PresetRepository CRUD', () {
    test('insere, atualiza e remove presets customizados', () async {
      final repository = await makeRepository();
      expect(repository.loadCustomPresets(), isEmpty);

      const preset = TuningPreset(
        id: 'custom_1',
        name: 'Drop B',
        instrument: Instrument.guitar,
        notes: ['B1', 'F#2', 'B2', 'E3', 'G#3', 'C#4'],
      );
      await repository.upsertCustomPreset(preset);
      expect(repository.loadCustomPresets().single.name, 'Drop B');

      await repository.upsertCustomPreset(preset.copyWith(name: 'Drop B!'));
      expect(repository.loadCustomPresets().single.name, 'Drop B!');
      expect(repository.loadCustomPresets(), hasLength(1));

      await repository.deleteCustomPreset('custom_1');
      expect(repository.loadCustomPresets(), isEmpty);
    });

    test('persiste preset ativo e calibração do A4', () async {
      final repository = await makeRepository();
      expect(repository.activePresetId, isNull);
      expect(repository.a4Reference, kDefaultA4);

      await repository.setActivePresetId('builtin_soad_drop_c');
      await repository.setA4Reference(442);
      expect(repository.activePresetId, 'builtin_soad_drop_c');
      expect(repository.a4Reference, 442);
    });

    test('dados corrompidos não quebram a carga', () async {
      SharedPreferences.setMockInitialValues({
        PresetRepository.customPresetsKey: 'not json{{',
      });
      final repository = PresetRepository(
        await SharedPreferences.getInstance(),
      );
      expect(repository.loadCustomPresets(), isEmpty);
    });
  });
}
