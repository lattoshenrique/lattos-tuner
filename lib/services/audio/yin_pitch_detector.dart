import 'dart:typed_data';

import 'package:lattos_tuner/models/pitch_estimate.dart';

/// Detector de pitch usando o algoritmo YIN
/// (de Cheveigné & Kawahara, 2002).
///
/// Opera sobre janelas de [bufferSize] amostras mono normalizadas em
/// [-1, 1]. O maior período detectável é `bufferSize / 2` amostras, ou seja,
/// a menor frequência detectável é `2 * sampleRate / bufferSize`.
class YinPitchDetector {
  YinPitchDetector({
    required this.sampleRate,
    this.bufferSize = 4096,
    this.threshold = 0.12,
  }) : _halfSize = bufferSize ~/ 2,
       _cmnd = Float64List(bufferSize ~/ 2);

  final double sampleRate;
  final int bufferSize;

  /// Limiar absoluto da função de diferença normalizada: valores menores
  /// indicam periodicidade mais forte.
  final double threshold;

  final int _halfSize;

  /// Função de diferença média cumulativa normalizada (reutilizada entre
  /// chamadas para evitar alocações).
  final Float64List _cmnd;

  /// Estima o pitch de [buffer]. Retorna null quando nenhum pitch
  /// suficientemente periódico é encontrado.
  PitchEstimate? estimate(Float64List buffer) {
    assert(buffer.length >= bufferSize);
    _cumulativeMeanNormalizedDifference(buffer);
    final tau = _absoluteThreshold();
    if (tau == -1) return null;
    final refinedTau = _parabolicInterpolation(tau);
    if (refinedTau <= 0) return null;
    return PitchEstimate(
      frequency: sampleRate / refinedTau,
      probability: (1.0 - _cmnd[tau]).clamp(0.0, 1.0),
    );
  }

  void _cumulativeMeanNormalizedDifference(Float64List x) {
    _cmnd[0] = 1.0;
    var runningSum = 0.0;
    for (var tau = 1; tau < _halfSize; tau++) {
      var difference = 0.0;
      for (var i = 0; i < _halfSize; i++) {
        final delta = x[i] - x[i + tau];
        difference += delta * delta;
      }
      runningSum += difference;
      _cmnd[tau] = runningSum == 0 ? 1.0 : difference * tau / runningSum;
    }
  }

  int _absoluteThreshold() {
    for (var tau = 2; tau < _halfSize; tau++) {
      if (_cmnd[tau] < threshold) {
        // Desce até o mínimo local para não superestimar a frequência.
        while (tau + 1 < _halfSize && _cmnd[tau + 1] < _cmnd[tau]) {
          tau++;
        }
        return tau;
      }
    }
    return -1;
  }

  double _parabolicInterpolation(int tau) {
    if (tau <= 0 || tau >= _halfSize - 1) return tau.toDouble();
    final s0 = _cmnd[tau - 1];
    final s1 = _cmnd[tau];
    final s2 = _cmnd[tau + 1];
    final denominator = 2.0 * (s0 - 2.0 * s1 + s2);
    if (denominator == 0) return tau.toDouble();
    return tau + (s0 - s2) / denominator;
  }
}
