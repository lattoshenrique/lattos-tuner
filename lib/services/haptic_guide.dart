import 'package:lattos_tuner/controllers/tuner_controller.dart';
import 'package:lattos_tuner/models/tuner_reading.dart';

/// Pulso pedido pelo guia tátil, do mais discreto ao mais forte.
enum HapticPulse {
  /// Quase lá: toque leve e rápido.
  light,

  /// Meio do caminho.
  medium,

  /// Longe da nota: batida cheia e espaçada.
  heavy,

  /// Chegou: toque de confirmação, disparado uma única vez por nota.
  arrival,
}

/// Traduz o desvio da corda em vibração, no espírito de um sensor de ré.
///
/// Longe da nota os pulsos são fortes e espaçados; conforme o desvio cai eles
/// ficam mais leves e mais rápidos, até virarem quase um contínuo na borda da
/// zona afinada. Ao entrar na zona, um toque de chegada confirma e o guia se
/// cala — silêncio é a recompensa, e o usuário afina sem olhar para a tela.
///
/// A classe não vibra nada por conta própria nem olha o relógio: quem a usa
/// chama [evaluate] periodicamente com o instante atual e executa o pulso
/// devolvido. Isso mantém a política testável, sem timers nem plugins.
class HapticGuide {
  /// Desvio, em cents, a partir do qual o pulso já está no ritmo mais lento.
  static const double maxCents = 45.0;

  /// Intervalo entre pulsos no desvio máximo.
  static const Duration slowestInterval = Duration(milliseconds: 640);

  /// Intervalo entre pulsos na borda da zona afinada.
  static const Duration fastestInterval = Duration(milliseconds: 110);

  /// Desvio acima do qual o pulso é forte.
  static const double heavyCents = 25.0;

  /// Desvio acima do qual o pulso é médio.
  static const double mediumCents = 12.0;

  int? _target;
  bool _arrived = false;
  Duration? _lastPulse;

  /// Decide o pulso deste instante, ou null quando não há nada a vibrar.
  HapticPulse? evaluate({
    required TunerReading? reading,
    required bool running,
    required bool enabled,
    required Duration now,
  }) {
    if (!enabled || !running || reading == null) {
      reset();
      return null;
    }
    // Trocou de corda/nota: a contagem recomeça, inclusive a confirmação.
    if (reading.targetMidi != _target) {
      _target = reading.targetMidi;
      _arrived = false;
      _lastPulse = null;
    }
    if (reading.status == TuningStatus.inTune) {
      if (_arrived) return null;
      _arrived = true;
      _lastPulse = now;
      return HapticPulse.arrival;
    }
    _arrived = false;
    final cents = reading.cents.abs();
    final last = _lastPulse;
    if (last != null && now - last < _intervalFor(cents)) return null;
    _lastPulse = now;
    return _strengthFor(cents);
  }

  /// Esquece a nota atual (microfone parado, tela saindo de cena).
  void reset() {
    _target = null;
    _arrived = false;
    _lastPulse = null;
  }

  Duration _intervalFor(double cents) {
    const inTune = TunerController.inTuneCents;
    final t = ((cents - inTune) / (maxCents - inTune)).clamp(0.0, 1.0);
    final micros =
        fastestInterval.inMicroseconds +
        (slowestInterval.inMicroseconds - fastestInterval.inMicroseconds) * t;
    return Duration(microseconds: micros.round());
  }

  HapticPulse _strengthFor(double cents) {
    if (cents >= heavyCents) return HapticPulse.heavy;
    if (cents >= mediumCents) return HapticPulse.medium;
    return HapticPulse.light;
  }
}
