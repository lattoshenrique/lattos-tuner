// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NoAd Tuner';

  @override
  String get tunerTitle => 'NOAD TUNER';

  @override
  String get tagline => 'Tune freely. No ads. Ever.';

  @override
  String calibrationTooltip(int hz) {
    return 'Calibration (A4 = $hz Hz)';
  }

  @override
  String get presetsTooltip => 'Tuning presets';

  @override
  String get statusMicPaused => 'Microphone paused';

  @override
  String get statusListening => 'Play a string…';

  @override
  String get statusTooLow => 'Too low — tighten the string';

  @override
  String get statusSlightlyLow => 'Almost there — tighten slightly';

  @override
  String get statusInTune => 'In tune!';

  @override
  String get statusSlightlyHigh => 'Almost there — loosen slightly';

  @override
  String get statusTooHigh => 'Too high — loosen the string';

  @override
  String get instrumentTuned => 'Instrument in tune! 🤘';

  @override
  String get modeStrings => 'Strings';

  @override
  String get modeChromatic => 'Free';

  @override
  String get captureTitle => 'Tuning capture';

  @override
  String get captureClear => 'Clear';

  @override
  String get captureHint =>
      'Tune each string freely — when a note settles, it lands here. Play from the lowest string to the highest, then save it as a preset.';

  @override
  String get captureSave => 'Save as preset';

  @override
  String get hzUnit => 'Hz';

  @override
  String get centsUnit => 'cents';

  @override
  String get permissionTitle => 'No microphone access';

  @override
  String get permissionBody =>
      'To tune your instrument, NoAd Tuner needs to hear the strings. Grant microphone permission in your device settings.';

  @override
  String get permissionRetry => 'Try again';

  @override
  String get calibrationTitle => 'Reference calibration';

  @override
  String get calibrationSubtitle => 'A4 frequency (default: 440 Hz)';

  @override
  String get calibrationRestore => 'Restore 440 Hz';

  @override
  String get calibrationListenTitle => 'Calibrate with a reference tone';

  @override
  String get calibrationListenHint =>
      'Play a steady reference tone nearby (tuning fork, piano, another tuner) and hold it.';

  @override
  String get calibrationListening => 'Listening…';

  @override
  String get calibrationApply => 'Apply';

  @override
  String get hapticGuideTitle => 'Guide vibration';

  @override
  String get hapticGuideHint =>
      'Vibrates faster as the string gets closer, and confirms when it lands.';

  @override
  String get presetsTitle => 'Tunings';

  @override
  String get sectionMyPresets => 'My presets';

  @override
  String get sectionBuiltIn => 'Standard tunings';

  @override
  String get filterAll => 'All';

  @override
  String get newPreset => 'New preset';

  @override
  String get emptyCustom =>
      'Create your first preset with the tuning you use — duplicate a standard tuning or capture your instrument\'s tuning in the tuner\'s chromatic mode.';

  @override
  String get emptyCustomFiltered =>
      'No presets of yours for this instrument yet — create one with the button below or capture a tuning in the tuner\'s chromatic mode.';

  @override
  String get menuEdit => 'Edit';

  @override
  String get menuDuplicate => 'Duplicate';

  @override
  String get menuDuplicateEdit => 'Duplicate & edit';

  @override
  String get menuDelete => 'Delete';

  @override
  String get deleteDialogTitle => 'Delete preset?';

  @override
  String deleteDialogBody(String name) {
    return '\"$name\" will be permanently removed.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get editorTitleNew => 'New preset';

  @override
  String get editorTitleEdit => 'Edit preset';

  @override
  String get save => 'Save';

  @override
  String get presetNameLabel => 'Preset name';

  @override
  String get presetNameHint => 'e.g. My Drop B tuning';

  @override
  String get sectionInstrument => 'Instrument';

  @override
  String get sectionStrings => 'Strings — lowest to highest';

  @override
  String get addString => 'Add string';

  @override
  String get semitoneDown => 'Half step down';

  @override
  String get semitoneUp => 'Half step up';

  @override
  String get removeString => 'Remove string';

  @override
  String get errorPresetName => 'Give the preset a name.';

  @override
  String get errorPresetStrings => 'Add at least one string.';

  @override
  String copyName(String name) {
    return '$name (copy)';
  }

  @override
  String get instrumentGuitar => 'Guitar';

  @override
  String get instrumentBass => 'Bass';

  @override
  String get instrumentUkulele => 'Ukulele';

  @override
  String get instrumentCavaquinho => 'Cavaquinho';

  @override
  String get instrumentOther => 'Other';

  @override
  String get presetStandardGuitar => 'Standard (E A D G B E)';

  @override
  String get presetDropC => 'Drop C';

  @override
  String get presetDropD => 'Drop D';

  @override
  String get presetHalfStepDown => 'Half step down (Eb)';

  @override
  String get presetDropCSharp => 'Drop C#';

  @override
  String get presetDropB => 'Drop B';

  @override
  String get presetDropA => 'Drop A';

  @override
  String get presetOpenD => 'Open D';

  @override
  String get presetDStandard => 'Whole step down (D)';

  @override
  String get presetCStandard => 'C standard';

  @override
  String get presetDadgad => 'DADGAD';

  @override
  String get presetOpenG => 'Open G';

  @override
  String get presetGuitar7 => '7-string (B E A D G B E)';

  @override
  String get presetBassStandard => 'Bass – Standard (E A D G)';

  @override
  String get presetBass5 => 'Bass – 5 strings';

  @override
  String get presetUkulele => 'Ukulele – Standard (G C E A)';

  @override
  String get presetCavaquinho => 'Cavaquinho (D G B D)';

  @override
  String get presetMandolin => 'Mandolin (G D A E)';
}
