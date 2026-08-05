/// Resultado de uma estimativa de pitch produzida pela camada de áudio.
class PitchEstimate {
  const PitchEstimate({required this.frequency, required this.probability});

  /// Frequência fundamental estimada, em Hz.
  final double frequency;

  /// Confiança da estimativa, entre 0 e 1.
  final double probability;
}
