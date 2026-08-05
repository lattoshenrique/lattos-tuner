import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lattos_tuner/models/note.dart';
import 'package:lattos_tuner/models/pitch_estimate.dart';
import 'package:lattos_tuner/services/audio/tuner_audio_service.dart';

/// Gera PCM16 little-endian mono a 44,1 kHz.
Uint8List pcm16Sine(
  double frequency,
  int sampleCount, {
  double amplitude = 0.4,
}) {
  final data = ByteData(sampleCount * 2);
  for (var i = 0; i < sampleCount; i++) {
    final t = i / TunerAudioService.captureSampleRate;
    final sample = (amplitude * 32767 * math.sin(2 * math.pi * frequency * t))
        .round();
    data.setInt16(i * 2, sample, Endian.little);
  }
  return data.buffer.asUint8List();
}

void main() {
  group('TunerAudioService.processChunk', () {
    test('emite pitch correto para uma senoide de 110 Hz', () async {
      final service = TunerAudioService();
      final estimates = <PitchEstimate?>[];
      final subscription = service.pitchStream.listen(estimates.add);

      // 1 s de áudio entregue em pedaços de tamanho irregular, como um
      // stream real de microfone.
      final audio = pcm16Sine(110.0, TunerAudioService.captureSampleRate);
      const chunkSize = 3001;
      for (var offset = 0; offset < audio.length; offset += chunkSize) {
        final end = math.min(offset + chunkSize, audio.length);
        service.processChunk(Uint8List.sublistView(audio, offset, end));
      }
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      final detected = estimates.whereType<PitchEstimate>().toList();
      expect(detected, isNotEmpty);
      for (final estimate in detected) {
        expect(centsBetween(estimate.frequency, 110.0).abs(), lessThan(3.0));
      }
    });

    test('emite null para silêncio', () async {
      final service = TunerAudioService();
      final estimates = <PitchEstimate?>[];
      final subscription = service.pitchStream.listen(estimates.add);

      service.processChunk(Uint8List(TunerAudioService.captureSampleRate));
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(estimates, isNotEmpty);
      expect(estimates.every((e) => e == null), isTrue);
    });
  });
}
