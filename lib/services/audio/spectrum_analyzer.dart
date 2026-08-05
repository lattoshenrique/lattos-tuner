import 'dart:math' as math;
import 'dart:typed_data';

import 'package:lattos_tuner/models/audio_frame.dart';

/// Espectro compacto de uma janela de áudio: FFT radix-2 seguida de
/// agregação em bandas log-espaçadas, na resolução que a UI consegue mostrar.
///
/// Serve à visualização, não à detecção de pitch (essa é do YIN): o resultado
/// é energia por banda já em escala perceptual (dB normalizado).
class SpectrumAnalyzer {
  SpectrumAnalyzer({
    required this.sampleRate,
    required this.fftSize,
    this.bandCount = AudioFrame.bandCount,
    this.minFrequency = 55.0,
    this.maxFrequency = 5000.0,
    this.floorDb = -72.0,
  }) : assert(fftSize > 0 && (fftSize & (fftSize - 1)) == 0, 'fftSize = 2^n'),
       _real = Float64List(fftSize),
       _imaginary = Float64List(fftSize),
       _window = Float64List(fftSize),
       _cos = Float64List(fftSize ~/ 2),
       _sin = Float64List(fftSize ~/ 2),
       _bandStart = Int32List(bandCount),
       _bandEnd = Int32List(bandCount) {
    for (var i = 0; i < fftSize; i++) {
      // Janela de Hann: reduz o vazamento espectral entre bandas vizinhas.
      _window[i] = 0.5 - 0.5 * math.cos(2 * math.pi * i / (fftSize - 1));
    }
    for (var i = 0; i < fftSize ~/ 2; i++) {
      final angle = -2 * math.pi * i / fftSize;
      _cos[i] = math.cos(angle);
      _sin[i] = math.sin(angle);
    }
    // Bandas log-espaçadas: uma oitava ocupa sempre a mesma largura visual.
    final binWidth = sampleRate / fftSize;
    final ratio = math.pow(maxFrequency / minFrequency, 1 / bandCount);
    var lower = minFrequency;
    for (var band = 0; band < bandCount; band++) {
      final upper = lower * ratio;
      final start = (lower / binWidth).floor().clamp(1, fftSize ~/ 2 - 1);
      // Toda banda cobre pelo menos um bin, mesmo nas graves (onde a
      // resolução da FFT é mais larga que a própria banda).
      final end = math.max(
        start + 1,
        (upper / binWidth).ceil().clamp(1, fftSize ~/ 2),
      );
      _bandStart[band] = start;
      _bandEnd[band] = end;
      lower = upper;
    }
  }

  final double sampleRate;
  final int fftSize;
  final int bandCount;
  final double minFrequency;
  final double maxFrequency;

  /// Nível, em dB, mapeado para 0 na saída (abaixo disso é silêncio visual).
  final double floorDb;

  final Float64List _real;
  final Float64List _imaginary;
  final Float64List _window;
  final Float64List _cos;
  final Float64List _sin;
  final Int32List _bandStart;
  final Int32List _bandEnd;

  /// Energia por banda (0..1) das primeiras [fftSize] amostras de [samples].
  Float64List analyze(Float64List samples) {
    final count = math.min(samples.length, fftSize);
    for (var i = 0; i < count; i++) {
      _real[i] = samples[i] * _window[i];
      _imaginary[i] = 0;
    }
    for (var i = count; i < fftSize; i++) {
      _real[i] = 0;
      _imaginary[i] = 0;
    }
    _transform();

    final bands = Float64List(bandCount);
    // Normaliza pela janela: uma senoide de amplitude 1 dá magnitude ~1.
    final scale = 4.0 / fftSize;
    for (var band = 0; band < bandCount; band++) {
      var peak = 0.0;
      for (var bin = _bandStart[band]; bin < _bandEnd[band]; bin++) {
        final re = _real[bin];
        final im = _imaginary[bin];
        final magnitude = math.sqrt(re * re + im * im) * scale;
        if (magnitude > peak) peak = magnitude;
      }
      final db = 20 * (math.log(peak + 1e-12) / math.ln10);
      bands[band] = ((db - floorDb) / -floorDb).clamp(0.0, 1.0);
    }
    return bands;
  }

  /// Converte um RMS de janela para a mesma escala perceptual das bandas.
  double levelFromRms(double rms) {
    final db = 20 * (math.log(rms + 1e-12) / math.ln10);
    return ((db - floorDb) / -floorDb).clamp(0.0, 1.0);
  }

  /// FFT iterativa de Cooley-Tukey, in-place, sobre [_real]/[_imaginary].
  void _transform() {
    final n = fftSize;
    for (var i = 1, j = 0; i < n; i++) {
      var bit = n >> 1;
      while (j & bit != 0) {
        j ^= bit;
        bit >>= 1;
      }
      j ^= bit;
      if (i < j) {
        final tempReal = _real[i];
        _real[i] = _real[j];
        _real[j] = tempReal;
        final tempImaginary = _imaginary[i];
        _imaginary[i] = _imaginary[j];
        _imaginary[j] = tempImaginary;
      }
    }
    for (var length = 2; length <= n; length <<= 1) {
      final half = length >> 1;
      final step = n ~/ length;
      for (var start = 0; start < n; start += length) {
        for (var offset = 0; offset < half; offset++) {
          final twiddle = offset * step;
          final cos = _cos[twiddle];
          final sin = _sin[twiddle];
          final top = start + offset;
          final bottom = top + half;
          final realBottom = _real[bottom] * cos - _imaginary[bottom] * sin;
          final imaginaryBottom = _real[bottom] * sin + _imaginary[bottom] * cos;
          _real[bottom] = _real[top] - realBottom;
          _imaginary[bottom] = _imaginary[top] - imaginaryBottom;
          _real[top] += realBottom;
          _imaginary[top] += imaginaryBottom;
        }
      }
    }
  }
}
