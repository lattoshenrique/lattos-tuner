import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audio/tuner_audio_service.dart';
import 'screens/tuner_screen.dart';
import 'services/preset_repository.dart';
import 'services/tuner_controller.dart';
import 'theme.dart';

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
