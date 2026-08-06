import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lattos_tuner/models/note.dart';
import 'package:lattos_tuner/models/pitch_estimate.dart';
import 'package:lattos_tuner/services/audio/tuner_audio_service.dart';

/// Corda dedilhada sintética: fundamental + harmônicos com decaimento
/// exponencial, como um pluck real.
Uint8List pluck(
  double frequency, {
  double seconds = 2.0,
  double amplitude = 0.30,
  double decay = 2.0,
  double fundamentalGain = 1.0,
}) {
  const rate = TunerAudioService.captureSampleRate;
  final count = (rate * seconds).round();
  final data = ByteData(count * 2);
  for (var i = 0; i < count; i++) {
    final t = i / rate;
    var sample = 0.0;
    for (var harmonic = 1; harmonic <= 6; harmonic++) {
      final gain =
          (harmonic == 1 ? fundamentalGain : 1.0) / (harmonic * harmonic);
      sample += gain * math.sin(2 * math.pi * frequency * harmonic * t);
    }
    sample *= math.exp(-decay * t) * amplitude;
    data.setInt16(
      i * 2,
      (sample.clamp(-1.0, 1.0) * 32767).round(),
      Endian.little,
    );
  }
  return data.buffer.asUint8List();
}

/// Ruído de banda larga: raspar de palheta, mão na corda, ambiente.
Uint8List noise(double seconds, double amplitude) {
  const rate = TunerAudioService.captureSampleRate;
  final count = (rate * seconds).round();
  final data = ByteData(count * 2);
  final random = math.Random(7);
  for (var i = 0; i < count; i++) {
    data.setInt16(
      i * 2,
      ((random.nextDouble() * 2 - 1) * amplitude * 32767).round(),
      Endian.little,
    );
  }
  return data.buffer.asUint8List();
}

/// Toca trechos em sequência no MESMO serviço — o gate adaptativo carrega
/// estado de um trecho para o outro, como no uso real — e devolve as
/// estimativas de cada trecho.
Future<List<List<PitchEstimate>>> play(List<Uint8List> parts) async {
  final service = TunerAudioService();
  final result = <List<PitchEstimate>>[];
  for (final part in parts) {
    final estimates = <PitchEstimate?>[];
    final subscription = service.pitchStream.listen(estimates.add);
    const chunk = 4096;
    for (var offset = 0; offset < part.length; offset += chunk) {
      final end = math.min(offset + chunk, part.length);
      service.processChunk(Uint8List.sublistView(part, offset, end));
    }
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();
    result.add(estimates.whereType<PitchEstimate>().toList());
  }
  return result;
}

void main() {
  test('detecta todas as notas úteis, do bordão ao agudo', () async {
    const notes = <String, double>{
      'E2': 82.41,
      'A2': 110.0,
      'D3': 146.83,
      'G3': 196.0,
      'B3': 246.94,
      'E4': 329.63,
      'A4': 440.0,
      'B4': 493.88,
      'E5': 659.25,
      'A5': 880.0,
      'E6': 1318.51,
    };
    for (final entry in notes.entries) {
      final detected = (await play([pluck(entry.value)])).single;
      expect(detected, isNotEmpty, reason: '${entry.key} não foi detectada');
      for (final estimate in detected) {
        expect(
          centsBetween(estimate.frequency, entry.value).abs(),
          lessThan(3.0),
          reason: '${entry.key} fora de precisão',
        );
      }
    }
  });

  test('corda aguda fraca sobrevive ao ruído que levanta o gate', () async {
    // Regressão: o gate por energia de banda larga zerava a aguda depois de
    // um ruído, porque ela carrega menos energia que o próprio ruído.
    final high = pluck(659.25, amplitude: 0.06, decay: 3.0);
    final alone = (await play([high])).single;
    final afterNoise = (await play([noise(1.0, 0.12), high])).last;
    final afterLoudBass = (await play([
      pluck(82.41, amplitude: 0.45, decay: 1.0),
      high,
    ])).last;

    expect(alone, isNotEmpty);
    expect(
      afterNoise.length,
      greaterThan(alone.length ~/ 2),
      reason: 'ruído anterior não pode calar a corda aguda',
    );
    expect(
      afterLoudBass.length,
      greaterThan(alone.length ~/ 2),
      reason: 'bordão forte não pode calar a corda aguda seguinte',
    );
    // As 3 primeiras janelas de cada trecho ainda carregam amostras do trecho
    // anterior (janela de 4096 com salto de 1024), então não valem para
    // conferir precisão.
    for (final estimate in [
      ...afterNoise.skip(3),
      ...afterLoudBass.skip(3),
    ]) {
      expect(centsBetween(estimate.frequency, 659.25).abs(), lessThan(3.0));
    }
  });

  test('aguda com fundamental abafado continua sendo detectada', () async {
    for (final frequency in [329.63, 659.25, 880.0]) {
      final detected = (await play([
        pluck(frequency, fundamentalGain: 0.15),
      ])).single;
      expect(detected, isNotEmpty);
      for (final estimate in detected) {
        expect(centsBetween(estimate.frequency, frequency).abs(), lessThan(3.0));
      }
    }
  });

  test('ruído de banda larga nunca vira nota', () async {
    for (final amplitude in [0.05, 0.15, 0.4]) {
      final detected = (await play([noise(2.0, amplitude)])).single;
      expect(detected, isEmpty, reason: 'ruído $amplitude virou pitch');
    }
  });
}
