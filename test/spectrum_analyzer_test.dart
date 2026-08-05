import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lattos_tuner/models/audio_frame.dart';
import 'package:lattos_tuner/services/audio/spectrum_analyzer.dart';

Float64List sine(double frequency, double sampleRate, int length) {
  final samples = Float64List(length);
  for (var i = 0; i < length; i++) {
    samples[i] = 0.5 * math.sin(2 * math.pi * frequency * i / sampleRate);
  }
  return samples;
}

void main() {
  const sampleRate = 22050.0;
  const fftSize = 4096;

  SpectrumAnalyzer analyzer() =>
      SpectrumAnalyzer(sampleRate: sampleRate, fftSize: fftSize);

  int peakBand(Float64List bands) {
    var best = 0;
    for (var i = 1; i < bands.length; i++) {
      if (bands[i] > bands[best]) best = i;
    }
    return best;
  }

  /// Banda log-espaçada que contém [frequency], na mesma grade do analisador.
  int bandOf(double frequency) {
    final ratio = math.pow(5000.0 / 55.0, 1 / AudioFrame.bandCount);
    var lower = 55.0;
    for (var band = 0; band < AudioFrame.bandCount; band++) {
      final upper = lower * ratio;
      if (frequency >= lower && frequency < upper) return band;
      lower = upper;
    }
    return AudioFrame.bandCount - 1;
  }

  test('a banda de pico acompanha a frequência do tom', () {
    final spectrum = analyzer();
    for (final frequency in [110.0, 440.0, 1318.5]) {
      final bands = spectrum.analyze(sine(frequency, sampleRate, fftSize));
      // Uma banda de tolerância cobre o vazamento da janela de Hann.
      expect(
        (peakBand(bands) - bandOf(frequency)).abs(),
        lessThanOrEqualTo(1),
        reason: 'pico fora de lugar para $frequency Hz',
      );
    }
  });

  test('duas notas simultâneas acendem as duas bandas', () {
    final spectrum = analyzer();
    final low = sine(110.0, sampleRate, fftSize);
    final high = sine(880.0, sampleRate, fftSize);
    final mix = Float64List(fftSize);
    for (var i = 0; i < fftSize; i++) {
      mix[i] = (low[i] + high[i]) / 2;
    }
    final bands = spectrum.analyze(mix);
    final quiet = bands[bandOf(300.0)];
    expect(bands[bandOf(110.0)], greaterThan(quiet + 0.2));
    expect(bands[bandOf(880.0)], greaterThan(quiet + 0.2));
  });

  test('silêncio zera as bandas e o nível', () {
    final spectrum = analyzer();
    final bands = spectrum.analyze(Float64List(fftSize));
    expect(bands.every((value) => value == 0), isTrue);
    expect(spectrum.levelFromRms(0), 0);
    expect(spectrum.levelFromRms(0.3), greaterThan(0.5));
  });
}
