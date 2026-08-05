import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:lattos_tuner/models/pitch_estimate.dart';
import 'package:lattos_tuner/services/audio/yin_pitch_detector.dart';
import 'package:record/record.dart';

/// Fonte de estimativas de pitch. Abstração que permite substituir o
/// microfone por dados sintéticos em testes.
abstract class PitchSource {
  /// Emite uma estimativa por janela de análise; null significa silêncio ou
  /// ausência de pitch detectável.
  Stream<PitchEstimate?> get pitchStream;

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
  static const double silenceRmsThreshold = 0.006;
  static const double minFrequency = 25.0;
  static const double maxFrequency = 2000.0;

  // Criado sob demanda: o construtor do plugin abre um MethodChannel, o que
  // exige a plataforma nativa disponível.
  final AudioRecorder Function() _recorderFactory;
  AudioRecorder? _recorder;
  final YinPitchDetector _detector = YinPitchDetector(
    sampleRate: analysisSampleRate.toDouble(),
    bufferSize: analysisBufferSize,
  );

  final StreamController<PitchEstimate?> _pitchController =
      StreamController<PitchEstimate?>.broadcast();
  final List<double> _window = <double>[];
  StreamSubscription<Uint8List>? _subscription;
  double? _pendingSample;
  int? _leftoverByte;
  bool _running = false;

  @override
  Stream<PitchEstimate?> get pitchStream => _pitchController.stream;

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
        // Processamentos de voz distorcem a frequência; um afinador precisa
        // do sinal cru.
        autoGain: false,
        echoCancel: false,
        noiseSuppress: false,
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
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _recorder?.dispose();
    await _pitchController.close();
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
      final sample = data.getInt16(i * 2, Endian.little) / 32768.0;
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
    if (rms < silenceRmsThreshold) {
      _pitchController.add(null);
      return;
    }
    final estimate = _detector.estimate(buffer);
    if (estimate == null ||
        estimate.frequency < minFrequency ||
        estimate.frequency > maxFrequency) {
      _pitchController.add(null);
      return;
    }
    _pitchController.add(estimate);
  }
}
