import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lattos_tuner/models/audio_frame.dart';
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

    test('detecta sinal fraco (microfone pouco sensível)', () async {
      final service = TunerAudioService();
      final estimates = <PitchEstimate?>[];
      final subscription = service.pitchStream.listen(estimates.add);

      // Amplitude bem abaixo do antigo gate fixo de RMS.
      final audio = pcm16Sine(
        110.0,
        TunerAudioService.captureSampleRate,
        amplitude: 0.006,
      );
      service.processChunk(audio);
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      final detected = estimates.whereType<PitchEstimate>().toList();
      expect(detected, isNotEmpty);
      for (final estimate in detected) {
        expect(centsBetween(estimate.frequency, 110.0).abs(), lessThan(3.0));
      }
    });

    test('publica quadros de áudio com energia e espectro reais', () async {
      final service = TunerAudioService();
      final frames = <AudioFrame>[];
      final subscription = service.audioStream.listen(frames.add);

      service.processChunk(
        pcm16Sine(220.0, TunerAudioService.captureSampleRate),
      );
      await Future<void>.delayed(Duration.zero);

      expect(frames, isNotEmpty);
      final loud = frames.where((frame) => frame.frequency != null).toList();
      expect(loud, isNotEmpty);
      for (final frame in loud) {
        expect(frame.level, greaterThan(0.5));
        // A energia se concentra nos graves/médios, não nos agudos.
        expect(frame.bandRange(0, 12), greaterThan(frame.bandRange(12, 12)));
      }

      // Silêncio depois do tom: nível e bandas voltam ao chão.
      frames.clear();
      service.processChunk(Uint8List(TunerAudioService.captureSampleRate));
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(frames, isNotEmpty);
      expect(frames.last.level, lessThan(0.2));
      expect(frames.last.frequency, isNull);
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
