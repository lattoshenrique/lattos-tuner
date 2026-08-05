// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Lattos Tuner';

  @override
  String get tunerTitle => 'LATTOS TUNER';

  @override
  String calibrationTooltip(int hz) {
    return 'Calibración (A4 = $hz Hz)';
  }

  @override
  String get presetsTooltip => 'Presets de afinación';

  @override
  String get statusMicPaused => 'Micrófono en pausa';

  @override
  String get statusListening => 'Toca una cuerda…';

  @override
  String get statusTooLow => 'Demasiado grave — tensa la cuerda';

  @override
  String get statusSlightlyLow => 'Casi — tensa un poco';

  @override
  String get statusInTune => '¡Afinado!';

  @override
  String get statusSlightlyHigh => 'Casi — afloja un poco';

  @override
  String get statusTooHigh => 'Demasiado agudo — afloja la cuerda';

  @override
  String get instrumentTuned => '¡Instrumento afinado! 🤘';

  @override
  String get modeStrings => 'Cuerdas';

  @override
  String get modeChromatic => 'Cromático';

  @override
  String get captureTitle => 'Captura de afinación';

  @override
  String get captureClear => 'Borrar';

  @override
  String get captureHint =>
      'Afina cada cuerda libremente: cuando una nota se estabiliza, aparece aquí. Toca de la cuerda más grave a la más aguda y luego guárdala como preset.';

  @override
  String get captureSave => 'Guardar como preset';

  @override
  String get hzUnit => 'Hz';

  @override
  String get centsUnit => 'cents';

  @override
  String get permissionTitle => 'Sin acceso al micrófono';

  @override
  String get permissionBody =>
      'Para afinar tu instrumento, Lattos Tuner necesita escuchar las cuerdas. Concede el permiso de micrófono en los ajustes del dispositivo.';

  @override
  String get permissionRetry => 'Reintentar';

  @override
  String get calibrationTitle => 'Calibración de referencia';

  @override
  String get calibrationSubtitle => 'Frecuencia del A4 (por defecto: 440 Hz)';

  @override
  String get calibrationRestore => 'Restaurar 440 Hz';

  @override
  String get presetsTitle => 'Afinaciones';

  @override
  String get sectionMyPresets => 'Mis presets';

  @override
  String get sectionBuiltIn => 'Afinaciones estándar';

  @override
  String get filterAll => 'Todos';

  @override
  String get newPreset => 'Nuevo preset';

  @override
  String get emptyCustom =>
      'Crea tu primer preset con la afinación que usas: duplica una afinación estándar o captura la afinación de tu instrumento en el modo cromático del afinador.';

  @override
  String get emptyCustomFiltered =>
      'Aún no tienes presets para este instrumento: crea uno con el botón de abajo o captura una afinación en el modo cromático del afinador.';

  @override
  String get menuEdit => 'Editar';

  @override
  String get menuDuplicate => 'Duplicar';

  @override
  String get menuDuplicateEdit => 'Duplicar y editar';

  @override
  String get menuDelete => 'Eliminar';

  @override
  String get deleteDialogTitle => '¿Eliminar preset?';

  @override
  String deleteDialogBody(String name) {
    return '\"$name\" se eliminará permanentemente.';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get editorTitleNew => 'Nuevo preset';

  @override
  String get editorTitleEdit => 'Editar preset';

  @override
  String get save => 'Guardar';

  @override
  String get presetNameLabel => 'Nombre del preset';

  @override
  String get presetNameHint => 'ej.: Mi afinación Drop B';

  @override
  String get sectionInstrument => 'Instrumento';

  @override
  String get sectionStrings => 'Cuerdas — de la más grave a la más aguda';

  @override
  String get addString => 'Añadir cuerda';

  @override
  String get semitoneDown => 'Medio tono abajo';

  @override
  String get semitoneUp => 'Medio tono arriba';

  @override
  String get removeString => 'Quitar cuerda';

  @override
  String get errorPresetName => 'Ponle un nombre al preset.';

  @override
  String get errorPresetStrings => 'Añade al menos una cuerda.';

  @override
  String copyName(String name) {
    return '$name (copia)';
  }

  @override
  String get instrumentGuitar => 'Guitarra';

  @override
  String get instrumentBass => 'Bajo';

  @override
  String get instrumentUkulele => 'Ukelele';

  @override
  String get instrumentCavaquinho => 'Cavaquinho';

  @override
  String get instrumentOther => 'Otro';

  @override
  String get presetStandardGuitar => 'Estándar (E A D G B E)';

  @override
  String get presetSoad => 'SOAD – Drop C';

  @override
  String get presetDropD => 'Drop D';

  @override
  String get presetHalfStepDown => 'Medio tono abajo (Eb)';

  @override
  String get presetDropCSharp => 'Drop C#';

  @override
  String get presetDadgad => 'DADGAD';

  @override
  String get presetOpenG => 'Open G';

  @override
  String get presetBassStandard => 'Bajo – Estándar (E A D G)';

  @override
  String get presetBass5 => 'Bajo – 5 cuerdas';

  @override
  String get presetUkulele => 'Ukelele – Estándar (G C E A)';

  @override
  String get presetCavaquinho => 'Cavaquinho (D G B D)';
}
