import 'dart:typed_data';

/// Retrato de uma janela de áudio recém-analisada, usado pelos elementos
/// visuais que reagem ao som real do microfone.
///
/// É emitido para toda janela — inclusive as sem pitch detectável — para que
/// o fundo continue respondendo a ruído, palhetadas e acordes.
class AudioFrame {
  const AudioFrame({
    required this.level,
    required this.frequency,
    required this.clarity,
    required this.bands,
  });

  /// Quantidade de bandas do espectro compacto entregue à UI.
  static const int bandCount = 24;

  /// Quadro de silêncio (usado quando o microfone está parado).
  static final AudioFrame silent = AudioFrame(
    level: 0,
    frequency: null,
    clarity: 0,
    bands: Float64List(bandCount),
  );

  /// Energia total da janela em escala perceptual (0 = silêncio, 1 = alto).
  final double level;

  /// Fundamental estimada em Hz, ou null quando a janela não é periódica.
  final double? frequency;

  /// Confiança da estimativa de pitch (0..1).
  final double clarity;

  /// Energia por banda log-espaçada, cada valor entre 0 e 1.
  final Float64List bands;

  /// Energia média das [count] bandas a partir de [start] (0 quando vazio).
  double bandRange(int start, int count) {
    final end = (start + count).clamp(0, bands.length);
    if (start >= end) return 0;
    var sum = 0.0;
    for (var i = start; i < end; i++) {
      sum += bands[i];
    }
    return sum / (end - start);
  }
}
