import 'dart:math' as math;
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
    var tau = _absoluteThreshold();
    if (tau == -1) return null;
    tau = _octaveGuard(tau);
    final refinedTau = _parabolicInterpolation(tau);
    if (refinedTau <= 0) return null;
    return PitchEstimate(
      frequency: sampleRate / refinedTau,
      probability: (1.0 - _cmnd[tau]).clamp(0.0, 1.0),
    );
  }

  /// Proteção contra erro de oitava para cima, comum quando o microfone
  /// corta o fundamental grave e o 2º harmônico domina: se o período dobrado
  /// for *nitidamente* mais periódico que o encontrado, ele é o verdadeiro.
  ///
  /// Para um sinal detectado corretamente, o CMND em 2·tau é praticamente
  /// igual ao de tau (todo múltiplo do período é periódico), então as
  /// condições de margem absoluta e relativa não disparam.
  int _octaveGuard(int tau) {
    final doubled = 2 * tau;
    if (doubled >= _halfSize - 1) return tau;
    // Mínimo local em torno de 2·tau.
    final radius = math.max(2, tau ~/ 8);
    var best = doubled;
    final start = math.max(1, doubled - radius);
    final end = math.min(_halfSize - 1, doubled + radius);
    for (var t = start; t <= end; t++) {
      if (_cmnd[t] < _cmnd[best]) best = t;
    }
    final isClearlyBetter =
        _cmnd[best] < threshold &&
        _cmnd[tau] - _cmnd[best] > 0.025 &&
        _cmnd[best] < _cmnd[tau] * 0.7;
    return isClearlyBetter ? best : tau;
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
