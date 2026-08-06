// Gera a mídia das lojas a partir das telas REAIS do app.
//
// Não é um teste: roda sob o harness do flutter_test só para ter um motor de
// renderização, e escreve os PNGs em stores/. Por isso o nome não termina em
// `_test.dart` — `flutter test` não o executa junto com a suíte.
//
//   flutter test test/store_shots.dart
//
// Cada tamanho vem das especificações oficiais (ver stores/README.md): o
// harness ajusta a superfície para os pixels exatos pedidos por cada loja e
// captura, sem redimensionar depois — nada de imagem esticada.

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lattos_tuner/controllers/tuner_controller.dart';
import 'package:lattos_tuner/models/audio_frame.dart';
import 'package:lattos_tuner/models/pitch_estimate.dart';
import 'package:lattos_tuner/models/tuner_reading.dart';
import 'package:lattos_tuner/services/audio/spectrum_analyzer.dart';
import 'package:lattos_tuner/services/audio/tuner_audio_service.dart';
import 'package:lattos_tuner/services/audio/yin_pitch_detector.dart';
import 'package:lattos_tuner/services/preset_repository.dart';
import 'package:lattos_tuner/views/l10n.dart';
import 'package:lattos_tuner/views/screens/presets_screen.dart';
import 'package:lattos_tuner/views/screens/tuner_screen.dart';
import 'package:lattos_tuner/views/theme.dart';
import 'package:lattos_tuner/views/widgets/brand_lockup.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _root = ValueKey('store-shot');

/// Um alvo de captura: pixels exigidos pela loja e a densidade que dá um
/// tamanho lógico plausível para aquele aparelho.
class ShotSize {
  const ShotSize(
    this.folder,
    this.width,
    this.height,
    this.pixelRatio, {
    this.insetTop = 59,
    this.insetBottom = 34,
  });

  final String folder;
  final double width;
  final double height;
  final double pixelRatio;

  /// Área segura (notch e barra inferior) em pixels lógicos.
  final double insetTop;
  final double insetBottom;

  Size get physical => Size(width, height);
}

/// Telas do app que entram na listagem.
enum Shot { tuning, inTune, freeMode, presets, calibration }

const _shotNames = <Shot, String>{
  Shot.tuning: '01-tuning',
  Shot.inTune: '02-in-tune',
  Shot.freeMode: '03-free-mode',
  Shot.presets: '04-presets',
  Shot.calibration: '05-calibration',
};

// Tamanhos oficiais. iPhone/iPad: developer.apple.com/help/app-store-connect/
// reference/screenshot-specifications. Google Play: support.google.com/
// googleplay/android-developer/answer/9866151.
// Tamanhos da Apple (1260x2736 iPhone 6.9", 1284x2778 iPhone 6.5",
// 2064x2752 iPad 13") saem de captura real no simulador — ver stores/README.md.

const _googleSizes = <ShotSize>[
  // 2,8 de densidade dá ~385 pt de largura: as cordas cabem numa linha só,
  // como num celular de verdade.
  ShotSize('google/phone', 1080, 1920, 2.8),
  ShotSize('google/tablet-7', 1080, 1920, 1.8, insetTop: 24, insetBottom: 16),
  ShotSize('google/tablet-10', 1440, 2560, 2, insetTop: 24, insetBottom: 16),
];

const _outputRoot = 'stores';
const _rate = TunerAudioService.analysisSampleRate;
const _windowSize = TunerAudioService.analysisBufferSize;

class _SilentSource implements PitchSource {
  final _pitch = StreamController<PitchEstimate?>.broadcast();
  final _audio = StreamController<AudioFrame>.broadcast();

  @override
  Stream<PitchEstimate?> get pitchStream => _pitch.stream;
  @override
  Stream<AudioFrame> get audioStream => _audio.stream;
  @override
  Future<bool> start() async => true;
  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {
    await _pitch.close();
    await _audio.close();
  }
}

/// Janela de uma corda dedilhada, para o fundo reagir com dados reais.
Float64List _pluckWindow(double frequency, double start) {
  final samples = Float64List(_windowSize);
  for (var i = 0; i < _windowSize; i++) {
    final t = start + i / _rate;
    var sample = 0.0;
    for (var harmonic = 1; harmonic <= 6; harmonic++) {
      sample +=
          math.sin(2 * math.pi * frequency * harmonic * t) /
          (harmonic * harmonic);
    }
    samples[i] = sample * math.exp(-1.2 * t) * 0.3;
  }
  return samples;
}

/// Quadros de áudio de verdade: mesma FFT e mesmo YIN que rodam no app.
List<AudioFrame> _realFrames(double frequency, {int steps = 14}) {
  final spectrum = SpectrumAnalyzer(
    sampleRate: _rate.toDouble(),
    fftSize: _windowSize,
  );
  final detector = YinPitchDetector(
    sampleRate: _rate.toDouble(),
    bufferSize: _windowSize,
  );
  return [
    for (var step = 0; step < steps; step++)
      () {
        final samples = _pluckWindow(frequency, step * 0.047);
        var sumSquares = 0.0;
        for (final sample in samples) {
          sumSquares += sample * sample;
        }
        final estimate = detector.estimate(samples);
        return AudioFrame(
          level: spectrum.levelFromRms(math.sqrt(sumSquares / _windowSize)),
          frequency: estimate?.frequency,
          clarity: estimate?.probability ?? 0,
          bands: spectrum.analyze(samples),
        );
      }(),
  ];
}

Future<void> _loadFonts() async {
  // Ícones do Material: sem carregar, todo Icon vira um quadrado vazio.
  final icons = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await icons.load();

  final loader = FontLoader('Poppins');
  for (final font in const [
    'Poppins-Regular',
    'Poppins-Medium',
    'Poppins-SemiBold',
    'Poppins-Bold',
    'Poppins-ExtraBold',
  ]) {
    loader.addFont(rootBundle.load('assets/fonts/$font.ttf'));
  }
  await loader.load();
}

Future<void> _write(WidgetTester tester, String path, double pixelRatio) async {
  final boundary =
      tester.renderObject(find.byKey(_root)) as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final file = File('$_outputRoot/$path')
      ..createSync(recursive: true)
      ..writeAsBytesSync(data!.buffer.asUint8List());
    // ignore: avoid_print
    print('  ${file.path}');
  });
}

Widget _wrap(Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: buildAppTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: RepaintBoundary(key: _root, child: child),
);

/// Deixa o app assentar: entrada dos blocos, envelopes do fundo, ondas.
Future<void> _settle(WidgetTester tester, {int frames = 90}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Entrega os quadros no ritmo real e converge a leitura exibida.
Future<void> _play(
  WidgetTester tester,
  TunerController controller,
  double frequency, {
  int repeats = 12,
}) async {
  final frames = _realFrames(frequency);
  for (var i = 0; i < math.max(repeats, frames.length); i++) {
    controller.handleAudioFrame(frames[i % frames.length]);
    controller.handleEstimate(
      PitchEstimate(frequency: frequency, probability: 0.97),
    );
    await tester.pump(const Duration(milliseconds: 48));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('gera as capturas das lojas', (tester) async {
    await _loadFonts();

    for (final size in _googleSizes) {
      // ignore: avoid_print
      print('${size.folder}  ${size.width.toInt()}x${size.height.toInt()}');
      tester.view.physicalSize = size.physical;
      tester.view.devicePixelRatio = size.pixelRatio;
      // Notch e barra inferior: sem isso o cabeçalho encosta no topo e a
      // captura não representa o aparelho.
      tester.view.padding = FakeViewPadding(
        top: size.insetTop * size.pixelRatio,
        bottom: size.insetBottom * size.pixelRatio,
      );

      for (final shot in Shot.values) {
        SharedPreferences.setMockInitialValues({});
        final controller = TunerController(
          repository: PresetRepository(await SharedPreferences.getInstance()),
          pitchSource: _SilentSource(),
        );
        await controller.init();
        await controller.start();
        if (shot == Shot.freeMode) controller.setMode(TargetMode.chromatic);

        await tester.pumpWidget(
          _wrap(
            shot == Shot.presets
                ? PresetsScreen(controller: controller)
                : TunerScreen(controller: controller),
          ),
        );
        await _settle(tester);

        switch (shot) {
          case Shot.tuning:
            // A2 uns 22 cents acima: ponteiro fora da zona, fundo reagindo.
            await _play(tester, controller, 110.0 * 1.0128);
          case Shot.inTune:
            await _play(tester, controller, 110.0, repeats: 20);
          case Shot.freeMode:
            for (final note in [146.83, 196.0, 246.94]) {
              await _play(tester, controller, note, repeats: 6);
            }
          case Shot.presets:
            break;
          case Shot.calibration:
            // A folha montada direto: bater no botão dependeria de hit test
            // sobre o vidro, e aqui o que interessa é o conteúdo dela.
            await tester.pumpWidget(
              _wrap(
                Stack(
                  children: [
                    TunerScreen(controller: controller),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Material(
                        color: AppColors.surface,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: CalibrationSheet(controller: controller),
                      ),
                    ),
                  ],
                ),
              ),
            );
        }
        await _settle(tester, frames: 30);
        await _write(
          tester,
          '${size.folder}/${_shotNames[shot]}.png',
          size.pixelRatio,
        );
        controller.dispose();
      }
    }

    // Gráfico de destaque da Play Store: a marca sobre o fundo do app.
    const feature = ShotSize('google/feature-graphic', 1024, 500, 1);
    tester.view.physicalSize = feature.physical;
    tester.view.devicePixelRatio = feature.pixelRatio;
    tester.view.padding = FakeViewPadding.zero;
    await tester.pumpWidget(
      _wrap(
        const ColoredBox(
          color: AppColors.background,
          child: Center(
            child: BrandLockup(
              axis: Axis.vertical,
              markSize: 132,
              nameSize: 34,
              showTagline: true,
            ),
          ),
        ),
      ),
    );
    await _settle(tester, frames: 20);
    await _write(tester, 'google/feature-graphic-1024x500.png', 1);

    tester.view.reset();
  });
}
