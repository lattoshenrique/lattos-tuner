import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lattos_tuner/controllers/tuner_controller.dart';
import 'package:lattos_tuner/models/pitch_estimate.dart';
import 'package:lattos_tuner/services/audio/tuner_audio_service.dart';
import 'package:lattos_tuner/services/preset_repository.dart';
import 'package:lattos_tuner/views/l10n.dart';
import 'package:lattos_tuner/views/screens/tuner_screen.dart';
import 'package:lattos_tuner/views/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SilentPitchSource implements PitchSource {
  final StreamController<PitchEstimate?> _controller =
      StreamController<PitchEstimate?>.broadcast();

  @override
  Stream<PitchEstimate?> get pitchStream => _controller.stream;

  @override
  Future<bool> start() async => true;

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async => _controller.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('tela do afinador exibe marca, logo e preset ativo', (
    tester,
  ) async {
    // Viewport de celular típico.
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final controller = TunerController(
      repository: PresetRepository(await SharedPreferences.getInstance()),
      pitchSource: _SilentPitchSource(),
    );
    await controller.init();

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TunerScreen(controller: controller),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.tunerTitle), findsOneWidget);
    expect(find.text(l10n.tagline), findsOneWidget);

    // A marca aparece no app bar.
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName ==
                'assets/branding/logo_mark.png',
      ),
      findsOneWidget,
    );

    // Preset padrão e a fonte da marca aplicada pelo tema.
    expect(find.textContaining('Standard'), findsWidgets);
    expect(buildAppTheme().textTheme.bodyMedium?.fontFamily, 'Poppins');

    controller.dispose();
  });
}
