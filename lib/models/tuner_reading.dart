import 'package:lattos_tuner/models/note.dart';

/// Situação da nota tocada em relação ao alvo.
enum TuningStatus { tooLow, slightlyLow, inTune, slightlyHigh, tooHigh }

/// Modo de escolha do alvo de afinação.
enum TargetMode {
  /// Corda do preset mais próxima da frequência detectada.
  auto,

  /// Corda travada manualmente pelo usuário.
  manual,

  /// Nota cromática mais próxima, ignorando o preset.
  chromatic,
}

/// Leitura pronta para exibição: frequência suavizada, alvo e desvio.
class TunerReading {
  const TunerReading({
    required this.frequency,
    required this.targetMidi,
    required this.cents,
    required this.status,
    this.stringIndex,
  });

  final double frequency;
  final int targetMidi;

  /// Desvio em cents em relação ao alvo (negativo = abaixo do alvo).
  final double cents;

  final TuningStatus status;

  /// Índice da corda alvo no preset, ou null no modo cromático.
  final int? stringIndex;

  String get targetName => midiToName(targetMidi);
}
