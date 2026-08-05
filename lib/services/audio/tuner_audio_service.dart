import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:lattos_tuner/models/audio_frame.dart';
import 'package:lattos_tuner/models/pitch_estimate.dart';
import 'package:lattos_tuner/services/audio/spectrum_analyzer.dart';
import 'package:lattos_tuner/services/audio/yin_pitch_detector.dart';
import 'package:record/record.dart';

/// Fonte de estimativas de pitch. Abstração que permite substituir o
/// microfone por dados sintéticos em testes.
abstract class PitchSource {
  /// Emite uma estimativa por janela de análise; null significa silêncio ou
  /// ausência de pitch detectável.
  Stream<PitchEstimate?> get pitchStream;

  /// Emite um quadro por janela de análise, com energia e espectro do áudio
  /// real — inclusive quando não há pitch. Alimenta as visualizações.
  Stream<AudioFrame> get audioStream;

  Future<bool> start();

  Future<void> stop();

  Future<void> dispose();
}

/// Captura áudio do microfone (PCM16 mono a 44,1 kHz), decima para
/// 22,05 kHz e emite estimativas de pitch via YIN.
class TunerAudioService implements PitchSource {
  TunerAudioService({AudioRecorder Function()? recorderFactory})
    : _recorderFactory = recorderFactory ?? AudioRecorder.new;

  static const int captureSampleRate = 44100;
  static const int decimationFactor = 2;
  static const int analysisSampleRate = captureSampleRate ~/ decimationFactor;
  static const int analysisBufferSize = 4096;
  static const int analysisHopSize = 1024;
  static const double minFrequency = 25.0;
  static const double maxFrequency = 2000.0;

  /// RMS mínimo absoluto: abaixo disso nem vale rodar o YIN. Bem baixo de
  /// propósito, para não deixar microfones pouco sensíveis "surdos".
  static const double absoluteMinRms = 0.0015;

  /// Fator sobre o piso de ruído medido para aceitar uma leitura de pitch.
  static const double noiseGateFactor = 1.8;

  /// Piso de ruído inicial, antes de qualquer medição.
  static const double initialNoiseFloor = 0.002;

  /// Coeficiente do passa-altas de 1 polo (~20 Hz em 44,1 kHz), que remove
  /// offset DC e rumble de manuseio antes da análise.
  static const double highPassCoefficient = 0.99715;

  // Criado sob demanda: o construtor do plugin abre um MethodChannel, o que
  // exige a plataforma nativa disponível.
  final AudioRecorder Function() _recorderFactory;
  AudioRecorder? _recorder;
  final YinPitchDetector _detector = YinPitchDetector(
    sampleRate: analysisSampleRate.toDouble(),
    bufferSize: analysisBufferSize,
  );

  final SpectrumAnalyzer _spectrum = SpectrumAnalyzer(
    sampleRate: analysisSampleRate.toDouble(),
    fftSize: analysisBufferSize,
  );

  final StreamController<PitchEstimate?> _pitchController =
      StreamController<PitchEstimate?>.broadcast();
  final StreamController<AudioFrame> _audioController =
      StreamController<AudioFrame>.broadcast();
  final List<double> _window = <double>[];
  StreamSubscription<Uint8List>? _subscription;
  double? _pendingSample;
  int? _leftoverByte;
  double _highPassPrevIn = 0;
  double _highPassPrevOut = 0;
  double _noiseFloor = initialNoiseFloor;
  bool _running = false;

  @override
  Stream<PitchEstimate?> get pitchStream => _pitchController.stream;

  @override
  Stream<AudioFrame> get audioStream => _audioController.stream;

  bool get isRunning => _running;

  @override
  Future<bool> start() async {
    if (_running) return true;
    final recorder = _recorder ??= _recorderFactory();
    if (!await recorder.hasPermission()) return false;
    final stream = await recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: captureSampleRate,
        numChannels: 1,
        // Processamentos de voz distorcem o sinal sustentado de uma corda;
        // um afinador precisa do áudio o mais cru possível.
        autoGain: false,
        echoCancel: false,
        noiseSuppress: false,
        androidConfig: AndroidRecordConfig(
          // VOICE_RECOGNITION evita o AGC/supressão de ruído que muitos
          // aparelhos aplicam à fonte padrão do microfone, e é suportada
          // de forma muito mais ampla que UNPROCESSED.
          audioSource: AndroidAudioSource.voiceRecognition,
        ),
      ),
    );
    _subscription = stream.listen(processChunk);
    _running = true;
    return true;
  }

  @override
  Future<void> stop() async {
    if (!_running) return;
    _running = false;
    await _subscription?.cancel();
    _subscription = null;
    await _recorder?.stop();
    _window.clear();
    _pendingSample = null;
    _leftoverByte = null;
    _highPassPrevIn = 0;
    _highPassPrevOut = 0;
    _noiseFloor = initialNoiseFloor;
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _recorder?.dispose();
    await _pitchController.close();
    await _audioController.close();
  }

  /// Processa um bloco PCM16 little-endian mono. Exposto para testes.
  @visibleForTesting
  void processChunk(Uint8List chunk) {
    // Blocos podem chegar com tamanho ímpar; o byte excedente pertence ao
    // primeiro frame do bloco seguinte.
    var bytes = chunk;
    final leftover = _leftoverByte;
    if (leftover != null) {
      bytes = Uint8List(chunk.lengthInBytes + 1)
        ..[0] = leftover
        ..setRange(1, chunk.lengthInBytes + 1, chunk);
      _leftoverByte = null;
    }
    _leftoverByte = bytes.lengthInBytes.isOdd ? bytes.last : null;
    final sampleCount = bytes.lengthInBytes ~/ 2;
    final data = ByteData.sublistView(bytes, 0, sampleCount * 2);
    for (var i = 0; i < sampleCount; i++) {
      final raw = data.getInt16(i * 2, Endian.little) / 32768.0;
      // Passa-altas de 1 polo (~20 Hz): remove offset DC e rumble de
      // manuseio, que atrapalham o gate de silêncio.
      final sample =
          raw - _highPassPrevIn + highPassCoefficient * _highPassPrevOut;
      _highPassPrevIn = raw;
      _highPassPrevOut = sample;
      // Decimação por 2 com média de pares (filtro anti-aliasing simples).
      final pending = _pendingSample;
      if (pending == null) {
        _pendingSample = sample;
      } else {
        _window.add((pending + sample) / 2.0);
        _pendingSample = null;
      }
    }
    while (_window.length >= analysisBufferSize) {
      _analyzeWindow();
      _window.removeRange(0, analysisHopSize);
    }
  }

  void _analyzeWindow() {
    final buffer = Float64List(analysisBufferSize);
    var sumSquares = 0.0;
    for (var i = 0; i < analysisBufferSize; i++) {
      final sample = _window[i];
      buffer[i] = sample;
      sumSquares += sample * sample;
    }
    final rms = math.sqrt(sumSquares / analysisBufferSize);
    if (rms < absoluteMinRms) {
      _emitFrame(rms: rms, buffer: null, accepted: null);
      _pitchController.add(null);
      return;
    }
    final estimate = _detector.estimate(buffer);
    if (estimate == null ||
        estimate.frequency < minFrequency ||
        estimate.frequency > maxFrequency) {
      // Janela com energia mas sem periodicidade: é ruído — atualiza o piso
      // usado pelo gate adaptativo.
      _noiseFloor = (_noiseFloor * 0.9 + rms * 0.1).clamp(absoluteMinRms, 0.2);
      // Ruído ainda tem espectro: a visualização reage a ele, o afinador não.
      _emitFrame(rms: rms, buffer: buffer, accepted: null);
      _pitchController.add(null);
      return;
    }
    // Gate adaptativo: exige que o sinal periódico esteja acima do piso de
    // ruído do ambiente, sem penalizar microfones pouco sensíveis.
    if (rms < _noiseFloor * noiseGateFactor) {
      _emitFrame(rms: rms, buffer: buffer, accepted: null);
      _pitchController.add(null);
      return;
    }
    _emitFrame(rms: rms, buffer: buffer, accepted: estimate);
    _pitchController.add(estimate);
  }

  /// Publica o retrato visual da janela. Sem ouvintes, pula a FFT — a
  /// visualização é a única consumidora e ela nem sempre está montada.
  void _emitFrame({
    required double rms,
    required Float64List? buffer,
    required PitchEstimate? accepted,
  }) {
    if (!_audioController.hasListener) return;
    _audioController.add(
      AudioFrame(
        level: _spectrum.levelFromRms(rms),
        frequency: accepted?.frequency,
        clarity: accepted?.probability ?? 0,
        bands: buffer == null
            ? Float64List(AudioFrame.bandCount)
            : _spectrum.analyze(buffer),
      ),
    );
  }
}
