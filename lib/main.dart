import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lattos_tuner/controllers/tuner_controller.dart';
import 'package:lattos_tuner/services/audio/tuner_audio_service.dart';
import 'package:lattos_tuner/services/preset_repository.dart';
import 'package:lattos_tuner/views/l10n.dart';
import 'package:lattos_tuner/models/tuner_reading.dart';
import 'package:lattos_tuner/views/screens/presets_screen.dart';
import 'package:lattos_tuner/views/screens/tuner_screen.dart';
import 'package:lattos_tuner/views/theme.dart';
import 'package:lattos_tuner/views/widgets/brand_intro.dart';
import 'package:lattos_tuner/views/widgets/liquid_glass.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
    ),
  );
  await LiquidGlassShader.load();
  final prefs = await SharedPreferences.getInstance();
  final controller = TunerController(
    repository: PresetRepository(prefs),
    pitchSource: TunerAudioService(),
  );
  await controller.init();
  runApp(LattosTunerApp(controller: controller));
}

/// Roteiro temporário para as capturas das lojas: percorre as telas sozinho
/// e força o idioma. Só liga com --dart-define=SHOTS=true.
const _shots = bool.fromEnvironment('SHOTS');

class LattosTunerApp extends StatefulWidget {
  const LattosTunerApp({super.key, required this.controller});

  final TunerController controller;

  @override
  State<LattosTunerApp> createState() => _LattosTunerAppState();
}

class _LattosTunerAppState extends State<LattosTunerApp> {
  final GlobalKey<NavigatorState> _navigator = GlobalKey<NavigatorState>();

  TunerController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    if (_shots) _runScript();
  }

  Future<void> _runScript() async {
    await Future<void>.delayed(const Duration(seconds: 12));
    controller.setMode(TargetMode.chromatic);
    await Future<void>.delayed(const Duration(seconds: 6));
    _navigator.currentState?.push(
      MaterialPageRoute<void>(
        builder: (_) => PresetsScreen(controller: controller),
      ),
    );
    await Future<void>.delayed(const Duration(seconds: 5));
    _navigator.currentState?.pop();
    await Future<void>.delayed(const Duration(seconds: 1));
    final context = _navigator.currentContext;
    if (context == null || !context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => CalibrationSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigator,
      locale: _shots ? const Locale('en') : null,
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // O idioma é resolvido automaticamente a partir do idioma do
      // aparelho; inglês é o fallback quando não há tradução.
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // A abertura da marca fica por cima do afinador, que já monta e começa
      // a ouvir por baixo — nada de atraso para quem só quer afinar.
      home: Stack(
        children: [
          TunerScreen(controller: controller),
          const BrandIntro(),
        ],
      ),
    );
  }
}
