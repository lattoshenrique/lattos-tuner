import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lattos_tuner/controllers/tuner_controller.dart';
import 'package:lattos_tuner/views/theme.dart';
import 'package:lattos_tuner/views/widgets/tuner_gauge.dart';

const _boundary = ValueKey('gauge');

/// Renderiza o medidor num desvio fixo e devolve o brilho médio da metade
/// superior, onde ficam as faixas de tolerância.
Future<double> zonesBrightness(WidgetTester tester, double? cents) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ColoredBox(
        color: AppColors.background,
        child: Center(
          child: RepaintBoundary(
            key: _boundary,
            child: SizedBox(
              width: 340,
              child: TunerGauge(cents: cents, color: AppColors.mint),
            ),
          ),
        ),
      ),
    ),
  );
  // Passa da animação do ponteiro e cai num ponto fixo da respiração.
  await tester.pump(const Duration(milliseconds: 800));

  final boundary =
      tester.renderObject(find.byKey(_boundary)) as RenderRepaintBoundary;
  final average = await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    final pixels = data!.buffer.asUint8List();
    // Só a faixa horizontal do arco superior, onde estão as três barras.
    final width = boundary.size.width.round();
    final rows = (boundary.size.height * 0.35).round();
    var sum = 0.0;
    var count = 0;
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < width; x++) {
        final offset = (y * width + x) * 4;
        sum += pixels[offset] + pixels[offset + 1] + pixels[offset + 2];
        count++;
      }
    }
    return sum / count / 3;
  });
  return average!;
}

void main() {
  testWidgets('a faixa sob o ponteiro acende', (tester) async {
    final idle = await zonesBrightness(tester, null);
    final far = await zonesBrightness(tester, 40);
    final amber = await zonesBrightness(
      tester,
      (TunerController.inTuneCents + TunerController.slightlyOffCents) / 2,
    );
    final mint = await zonesBrightness(tester, 0);

    // ignore: avoid_print
    print('ocioso $idle | longe $far | âmbar $amber | menta $mint');
    // Sem leitura nada acende, mesmo com o ponteiro parado no centro.
    expect(idle, lessThan(mint));
    // Longe das faixas elas ficam no estado de repouso.
    expect(far, lessThan(amber));
    expect(far, lessThan(mint));
  });

  testWidgets('a faixa acesa respira enquanto o ponteiro fica nela', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 340,
            child: TunerGauge(cents: 0, color: AppColors.mint),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    // A respiração é um ticker contínuo: sempre há quadro pendente.
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.binding.hasScheduledFrame, isTrue);
  });
}
