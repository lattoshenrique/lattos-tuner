import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lattos_tuner/controllers/tuner_controller.dart';
import 'package:lattos_tuner/models/note.dart';
import 'package:lattos_tuner/models/pitch_estimate.dart';
import 'package:lattos_tuner/models/tuner_reading.dart';
import 'package:lattos_tuner/models/tuning_preset.dart';
import 'package:lattos_tuner/services/audio/tuner_audio_service.dart';
import 'package:lattos_tuner/services/preset_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakePitchSource implements PitchSource {
  final StreamController<PitchEstimate?> controller =
      StreamController<PitchEstimate?>.broadcast();
  bool grantPermission = true;
  bool started = false;

  @override
  Stream<PitchEstimate?> get pitchStream => controller.stream;

  @override
  Future<bool> start() async {
    started = grantPermission;
    return grantPermission;
  }

  @override
  Future<void> stop() async {
    started = false;
  }

  @override
  Future<void> dispose() async {
    await controller.close();
  }
}

Future<TunerController> makeController({
  Map<String, Object> initialPrefs = const {},
  FakePitchSource? source,
}) async {
  SharedPreferences.setMockInitialValues(initialPrefs);
  final prefs = await SharedPreferences.getInstance();
  final controller = TunerController(
    repository: PresetRepository(prefs),
    pitchSource: source ?? FakePitchSource(),
  );
  await controller.init();
  return controller;
}

PitchEstimate estimateForNote(String note, {double centsOffset = 0}) {
  final midi = nameToMidi(note)!.toDouble();
  return PitchEstimate(
    frequency: midiToFrequency(midi + centsOffset / 100.0),
    probability: 0.95,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('inicia com o preset padrão e restaura o preset ativo salvo', () async {
    final fresh = await makeController();
    expect(fresh.activePreset.id, PresetRepository.builtInPresets.first.id);

    final restored = await makeController(
      initialPrefs: {
        PresetRepository.activePresetKey: 'builtin_soad_drop_c',
      },
    );
    expect(restored.activePreset.name, contains('SOAD'));
  });

  group('leituras', () {
    test('seleciona a corda mais próxima no modo auto (SOAD Drop C)', () async {
      final controller = await makeController();
      await controller.setActivePreset(
        PresetRepository.builtInPresets
            .firstWhere((p) => p.id == 'builtin_soad_drop_c'),
      );

      // 20 cents abaixo de G2: a corda alvo deve ser G2 (índice 1).
      controller.handleEstimate(estimateForNote('G2', centsOffset: -20));
      final reading = controller.reading!;
      expect(reading.stringIndex, 1);
      expect(reading.targetName, 'G2');
      expect(reading.cents, closeTo(-20, 0.5));
      expect(reading.status, TuningStatus.tooLow);
    });

    test('classifica o status por faixas de cents', () async {
      final controller = await makeController();
      final cases = {
        -30.0: TuningStatus.tooLow,
        -10.0: TuningStatus.slightlyLow,
        0.0: TuningStatus.inTune,
        4.0: TuningStatus.inTune,
        10.0: TuningStatus.slightlyHigh,
        30.0: TuningStatus.tooHigh,
      };
      cases.forEach((cents, expected) {
        // Janela de suavização limpa entre casos.
        controller.handleEstimate(null);
        for (var i = 0; i < TunerController.silenceReadingsToClear; i++) {
          controller.handleEstimate(null);
        }
        for (var i = 0; i < TunerController.smoothingWindow; i++) {
          controller.handleEstimate(
            estimateForNote('E2', centsOffset: cents),
          );
        }
        expect(
          controller.reading!.status,
          expected,
          reason: '$cents cents',
        );
      });
    });

    test('modo cromático usa a nota mais próxima, fora do preset', () async {
      final controller = await makeController();
      controller.setMode(TargetMode.chromatic);
      // C#3 não é corda de nenhum preset padrão de guitarra.
      controller.handleEstimate(estimateForNote('C#3', centsOffset: 8));
      expect(controller.reading!.targetName, 'C#3');
      expect(controller.reading!.stringIndex, isNull);
      expect(controller.reading!.cents, closeTo(8, 0.5));
    });

    test('trava de corda manual força o alvo', () async {
      final controller = await makeController();
      controller.toggleStringLock(0); // trava E2
      controller.handleEstimate(estimateForNote('A2'));
      expect(controller.reading!.targetName, 'E2');
      // Destrava: volta ao modo auto.
      controller.toggleStringLock(0);
      expect(controller.mode, TargetMode.auto);
    });

    test('silêncio prolongado limpa a leitura', () async {
      final controller = await makeController();
      controller.handleEstimate(estimateForNote('E2'));
      expect(controller.reading, isNotNull);
      for (var i = 0; i < TunerController.silenceReadingsToClear; i++) {
        controller.handleEstimate(null);
      }
      expect(controller.reading, isNull);
    });

    test('marca cordas como afinadas após leituras estáveis', () async {
      final controller = await makeController();
      expect(controller.tunedStrings, isEmpty);
      for (var i = 0; i < TunerController.stableReadingsToConfirm; i++) {
        controller.handleEstimate(estimateForNote('E2', centsOffset: 1));
      }
      expect(controller.tunedStrings, contains(0));
      expect(controller.allStringsTuned, isFalse);
    });

    test('trocar de preset zera as cordas afinadas', () async {
      final controller = await makeController();
      for (var i = 0; i < TunerController.stableReadingsToConfirm; i++) {
        controller.handleEstimate(estimateForNote('E2'));
      }
      expect(controller.tunedStrings, isNotEmpty);
      await controller.setActivePreset(PresetRepository.builtInPresets[1]);
      expect(controller.tunedStrings, isEmpty);
    });
  });

  group('permissão e ciclo de vida', () {
    test('permissão negada é sinalizada', () async {
      final source = FakePitchSource()..grantPermission = false;
      final controller = await makeController(source: source);
      await controller.start();
      expect(controller.permissionDenied, isTrue);
      expect(controller.isRunning, isFalse);
    });

    test('start/stop controlam a fonte', () async {
      final source = FakePitchSource();
      final controller = await makeController(source: source);
      await controller.start();
      expect(source.started, isTrue);
      expect(controller.isRunning, isTrue);
      await controller.stop();
      expect(source.started, isFalse);
    });
  });

  group('presets customizados', () {
    test('salva, ativa e exclui', () async {
      final controller = await makeController();
      const preset = TuningPreset(
        id: 'custom_test',
        name: 'Drop A',
        instrument: Instrument.guitar,
        notes: ['A1', 'E2', 'A2', 'D3', 'F#3', 'B3'],
      );
      await controller.saveCustomPreset(preset);
      expect(controller.customPresets.single.name, 'Drop A');

      await controller.setActivePreset(preset);
      expect(controller.activePreset.id, 'custom_test');

      // Excluir o preset ativo volta para o padrão.
      await controller.deleteCustomPreset('custom_test');
      expect(controller.customPresets, isEmpty);
      expect(
        controller.activePreset.id,
        PresetRepository.builtInPresets.first.id,
      );
    });
  });

  test('calibração do A4 desloca as frequências-alvo', () async {
    final controller = await makeController();
    await controller.setA4(442);
    // Um E2 gerado com A4=442 deve estar afinado para o controller calibrado.
    final frequency = 442.0 * (midiToFrequency(40) / 440.0);
    controller.handleEstimate(
      PitchEstimate(frequency: frequency, probability: 0.95),
    );
    expect(controller.reading!.cents.abs(), lessThan(0.5));
  });
}
