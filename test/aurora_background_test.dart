import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lattos_tuner/models/audio_frame.dart';
import 'package:lattos_tuner/views/theme.dart';
import 'package:lattos_tuner/views/widgets/aurora_background.dart';

const _boundary = ValueKey('aurora-boundary');

AudioFrame frame({
  required double level,
  double? frequency,
  double clarity = 0,
}) => AudioFrame(
  level: level,
  frequency: frequency,
  clarity: clarity,
  bands: Float64List.fromList(List<double>.filled(AudioFrame.bandCount, level)),
);

/// Brilho médio do fundo renderizado (0..255).
///
/// A codificação da imagem precisa do relógio real, por isso o [runAsync].
Future<double> brightness(WidgetTester tester) async {
  final boundary =
      tester.renderObject(find.byKey(_boundary)) as RenderRepaintBoundary;
  final average = await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    final pixels = data!.buffer.asUint8List();
    var sum = 0.0;
    for (var i = 0; i < pixels.length; i += 4) {
      sum += pixels[i] + pixels[i + 1] + pixels[i + 2];
    }
    return sum / (pixels.length / 4) / 3;
  });
  return average!;
}

Future<void> settleAudio(WidgetTester tester) async {
  for (var i = 0; i < 90; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testWidgets('o fundo acende com a energia do áudio e apaga no silêncio', (
    tester,
  ) async {
    final audio = ValueNotifier<AudioFrame>(AudioFrame.silent);
    addTearDown(audio.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: ColoredBox(
          color: AppColors.background,
          child: RepaintBoundary(
            key: _boundary,
            child: SizedBox(
              width: 300,
              height: 600,
              child: AuroraBackground(
                accent: AppColors.violet,
                audio: audio,
              ),
            ),
          ),
        ),
      ),
    );
    await settleAudio(tester);
    final quiet = await brightness(tester);

    // Nota forte e limpa: as manchas incham e ganham a cor da nota.
    audio.value = frame(level: 0.95, frequency: 440, clarity: 0.9);
    await settleAudio(tester);
    final loud = await brightness(tester);
    expect(
      loud,
      greaterThan(quiet * 1.5),
      reason: 'o fundo deveria reagir ao áudio de forma perceptível',
    );

    // Volta ao silêncio: o envelope desce sozinho.
    audio.value = AudioFrame.silent;
    await settleAudio(tester);
    expect(await brightness(tester), lessThan(loud));
  });

  testWidgets('notas diferentes pintam o fundo de formas diferentes', (
    tester,
  ) async {
    final audio = ValueNotifier<AudioFrame>(AudioFrame.silent);
    addTearDown(audio.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: ColoredBox(
          color: AppColors.background,
          child: RepaintBoundary(
            key: _boundary,
            child: SizedBox(
              width: 300,
              height: 600,
              child: AuroraBackground(accent: AppColors.mint, audio: audio),
            ),
          ),
        ),
      ),
    );

    audio.value = frame(level: 0.9, frequency: 82.41, clarity: 0.95);
    await settleAudio(tester);
    final low = await brightness(tester);

    audio.value = frame(level: 0.9, frequency: 659.26, clarity: 0.95);
    await settleAudio(tester);
    final high = await brightness(tester);

    // Mesma energia, alturas diferentes: cor e posição do brilho mudam.
    expect((high - low).abs(), greaterThan(0.5));
  });
}
