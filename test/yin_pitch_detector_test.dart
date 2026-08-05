import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lattos_tuner/audio/yin_pitch_detector.dart';
import 'package:lattos_tuner/models/note.dart';

Float64List sineWave(
  double frequency,
  double sampleRate,
  int length, {
  double amplitude = 0.5,
  List<double> harmonics = const [],
}) {
  final buffer = Float64List(length);
  for (var i = 0; i < length; i++) {
    final t = i / sampleRate;
    var sample = amplitude * math.sin(2 * math.pi * frequency * t);
    for (var h = 0; h < harmonics.length; h++) {
      sample +=
          harmonics[h] * math.sin(2 * math.pi * frequency * (h + 2) * t);
    }
    buffer[i] = sample;
  }
  return buffer;
}

void main() {
  const sampleRate = 22050.0;
  const bufferSize = 4096;
  final detector =
      YinPitchDetector(sampleRate: sampleRate, bufferSize: bufferSize);

  group('YinPitchDetector', () {
    test('detecta senoides puras nas frequências das cordas', () {
      // E1 (baixo), C2 (Drop C), E2, A2, D3, G3, B3, E4, A4.
      const frequencies = [
        41.203,
        65.406,
        82.407,
        110.0,
        146.83,
        196.0,
        246.94,
        329.63,
        440.0,
      ];
      for (final frequency in frequencies) {
        final estimate =
            detector.estimate(sineWave(frequency, sampleRate, bufferSize));
        expect(estimate, isNotNull, reason: '$frequency Hz não detectado');
        final cents = centsBetween(estimate!.frequency, frequency);
        expect(
          cents.abs(),
          lessThan(2.0),
          reason: '$frequency Hz detectado como ${estimate.frequency} Hz '
              '(${cents.toStringAsFixed(2)} cents)',
        );
      }
    });

    test('detecta tons com harmônicos (timbre de corda)', () {
      final buffer = sineWave(
        110.0,
        sampleRate,
        bufferSize,
        amplitude: 0.5,
        harmonics: [0.3, 0.2, 0.1],
      );
      final estimate = detector.estimate(buffer);
      expect(estimate, isNotNull);
      expect(
        centsBetween(estimate!.frequency, 110.0).abs(),
        lessThan(2.0),
      );
      expect(estimate.probability, greaterThan(0.85));
    });

    test('retorna null para silêncio', () {
      expect(detector.estimate(Float64List(bufferSize)), isNull);
    });

    test('retorna null para ruído branco', () {
      final random = math.Random(42);
      final noise = Float64List(bufferSize);
      for (var i = 0; i < bufferSize; i++) {
        noise[i] = random.nextDouble() * 0.6 - 0.3;
      }
      expect(detector.estimate(noise), isNull);
    });
  });
}
