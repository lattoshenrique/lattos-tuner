// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Lattos Tuner';

  @override
  String get tunerTitle => 'LATTOS TUNER';

  @override
  String calibrationTooltip(int hz) {
    return 'Kalibrierung (A4 = $hz Hz)';
  }

  @override
  String get presetsTooltip => 'Stimmungs-Presets';

  @override
  String get statusMicPaused => 'Mikrofon pausiert';

  @override
  String get statusListening => 'Spiel eine Saite…';

  @override
  String get statusTooLow => 'Zu tief — Saite spannen';

  @override
  String get statusSlightlyLow => 'Fast — etwas spannen';

  @override
  String get statusInTune => 'Gestimmt!';

  @override
  String get statusSlightlyHigh => 'Fast — etwas lockern';

  @override
  String get statusTooHigh => 'Zu hoch — Saite lockern';

  @override
  String get instrumentTuned => 'Instrument gestimmt! 🤘';

  @override
  String get modeStrings => 'Saiten';

  @override
  String get modeChromatic => 'Chromatisch';

  @override
  String get captureTitle => 'Stimmungs-Aufnahme';

  @override
  String get captureClear => 'Leeren';

  @override
  String get captureHint =>
      'Stimme jede Saite frei — sobald ein Ton stabil ist, erscheint er hier. Spiele von der tiefsten zur höchsten Saite und speichere dann als Preset.';

  @override
  String get captureSave => 'Als Preset speichern';

  @override
  String get hzUnit => 'Hz';

  @override
  String get centsUnit => 'Cent';

  @override
  String get permissionTitle => 'Kein Mikrofonzugriff';

  @override
  String get permissionBody =>
      'Um dein Instrument zu stimmen, muss Lattos Tuner die Saiten hören. Erteile die Mikrofonberechtigung in den Geräteeinstellungen.';

  @override
  String get permissionRetry => 'Erneut versuchen';

  @override
  String get calibrationTitle => 'Referenz-Kalibrierung';

  @override
  String get calibrationSubtitle => 'A4-Frequenz (Standard: 440 Hz)';

  @override
  String get calibrationRestore => '440 Hz wiederherstellen';

  @override
  String get presetsTitle => 'Stimmungen';

  @override
  String get sectionMyPresets => 'Meine Presets';

  @override
  String get sectionBuiltIn => 'Standard-Stimmungen';

  @override
  String get filterAll => 'Alle';

  @override
  String get newPreset => 'Neues Preset';

  @override
  String get emptyCustom =>
      'Erstelle dein erstes Preset mit deiner Stimmung — dupliziere eine Standard-Stimmung oder nimm die Stimmung deines Instruments im chromatischen Modus auf.';

  @override
  String get emptyCustomFiltered =>
      'Noch keine eigenen Presets für dieses Instrument — erstelle eines über den Button unten oder nimm eine Stimmung im chromatischen Modus auf.';

  @override
  String get menuEdit => 'Bearbeiten';

  @override
  String get menuDuplicate => 'Duplizieren';

  @override
  String get menuDuplicateEdit => 'Duplizieren & bearbeiten';

  @override
  String get menuDelete => 'Löschen';

  @override
  String get deleteDialogTitle => 'Preset löschen?';

  @override
  String deleteDialogBody(String name) {
    return '„$name“ wird dauerhaft entfernt.';
  }

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get editorTitleNew => 'Neues Preset';

  @override
  String get editorTitleEdit => 'Preset bearbeiten';

  @override
  String get save => 'Speichern';

  @override
  String get presetNameLabel => 'Preset-Name';

  @override
  String get presetNameHint => 'z. B. Meine Drop-B-Stimmung';

  @override
  String get sectionInstrument => 'Instrument';

  @override
  String get sectionStrings => 'Saiten — von der tiefsten zur höchsten';

  @override
  String get addString => 'Saite hinzufügen';

  @override
  String get semitoneDown => 'Halbton tiefer';

  @override
  String get semitoneUp => 'Halbton höher';

  @override
  String get removeString => 'Saite entfernen';

  @override
  String get errorPresetName => 'Gib dem Preset einen Namen.';

  @override
  String get errorPresetStrings => 'Füge mindestens eine Saite hinzu.';

  @override
  String copyName(String name) {
    return '$name (Kopie)';
  }

  @override
  String get instrumentGuitar => 'Gitarre';

  @override
  String get instrumentBass => 'Bass';

  @override
  String get instrumentUkulele => 'Ukulele';

  @override
  String get instrumentCavaquinho => 'Cavaquinho';

  @override
  String get instrumentOther => 'Andere';

  @override
  String get presetStandardGuitar => 'Standard (E A D G B E)';

  @override
  String get presetSoad => 'SOAD – Drop C';

  @override
  String get presetDropD => 'Drop D';

  @override
  String get presetHalfStepDown => 'Halbton tiefer (Eb)';

  @override
  String get presetDropCSharp => 'Drop C#';

  @override
  String get presetDadgad => 'DADGAD';

  @override
  String get presetOpenG => 'Open G';

  @override
  String get presetBassStandard => 'Bass – Standard (E A D G)';

  @override
  String get presetBass5 => 'Bass – 5 Saiten';

  @override
  String get presetUkulele => 'Ukulele – Standard (G C E A)';

  @override
  String get presetCavaquinho => 'Cavaquinho (D G B D)';
}
