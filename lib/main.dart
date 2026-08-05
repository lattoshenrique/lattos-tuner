import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lattos_tuner/controllers/tuner_controller.dart';
import 'package:lattos_tuner/services/audio/tuner_audio_service.dart';
import 'package:lattos_tuner/services/preset_repository.dart';
import 'package:lattos_tuner/views/screens/tuner_screen.dart';
import 'package:lattos_tuner/views/theme.dart';
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
  final prefs = await SharedPreferences.getInstance();
  final controller = TunerController(
    repository: PresetRepository(prefs),
    pitchSource: TunerAudioService(),
  );
  await controller.init();
  runApp(LattosTunerApp(controller: controller));
}

class LattosTunerApp extends StatelessWidget {
  const LattosTunerApp({super.key, required this.controller});

  final TunerController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lattos Tuner',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: TunerScreen(controller: controller),
    );
  }
}
