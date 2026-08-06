// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'NoAd Tuner';

  @override
  String get tunerTitle => 'NOAD TUNER';

  @override
  String get tagline => 'Tune freely. No ads. Ever.';

  @override
  String calibrationTooltip(int hz) {
    return 'Calibrage (A4 = $hz Hz)';
  }

  @override
  String get presetsTooltip => 'Presets d\'accordage';

  @override
  String get statusMicPaused => 'Micro en pause';

  @override
  String get statusListening => 'Jouez une corde…';

  @override
  String get statusTooLow => 'Trop bas — tendez la corde';

  @override
  String get statusSlightlyLow => 'Presque — tendez légèrement';

  @override
  String get statusInTune => 'Accordé !';

  @override
  String get statusSlightlyHigh => 'Presque — détendez légèrement';

  @override
  String get statusTooHigh => 'Trop haut — détendez la corde';

  @override
  String get instrumentTuned => 'Instrument accordé ! 🤘';

  @override
  String get modeStrings => 'Cordes';

  @override
  String get modeChromatic => 'Libre';

  @override
  String get captureTitle => 'Capture d\'accordage';

  @override
  String get captureClear => 'Effacer';

  @override
  String get captureHint =>
      'Accordez chaque corde librement : quand une note se stabilise, elle apparaît ici. Jouez de la corde la plus grave à la plus aiguë, puis enregistrez comme preset.';

  @override
  String get captureSave => 'Enregistrer comme preset';

  @override
  String get hzUnit => 'Hz';

  @override
  String get centsUnit => 'cents';

  @override
  String get permissionTitle => 'Pas d\'accès au micro';

  @override
  String get permissionBody =>
      'Pour accorder votre instrument, NoAd Tuner doit entendre les cordes. Accordez la permission micro dans les réglages de l\'appareil.';

  @override
  String get permissionRetry => 'Réessayer';

  @override
  String get calibrationTitle => 'Calibrage de référence';

  @override
  String get calibrationSubtitle => 'Fréquence du A4 (par défaut : 440 Hz)';

  @override
  String get calibrationRestore => 'Rétablir 440 Hz';

  @override
  String get calibrationListenTitle => 'Calibrer avec un son de référence';

  @override
  String get calibrationListenHint =>
      'Jouez un son de référence stable à proximité (diapason, piano, autre accordeur) et tenez-le.';

  @override
  String get calibrationListening => 'Écoute…';

  @override
  String get calibrationApply => 'Appliquer';

  @override
  String get hapticGuideTitle => 'Vibration guide';

  @override
  String get hapticGuideHint =>
      'Vibre plus vite à mesure que la corde approche et confirme quand elle est juste.';

  @override
  String get presetsTitle => 'Accordages';

  @override
  String get sectionMyPresets => 'Mes presets';

  @override
  String get sectionBuiltIn => 'Accordages standard';

  @override
  String get filterAll => 'Tous';

  @override
  String get newPreset => 'Nouveau preset';

  @override
  String get emptyCustom =>
      'Créez votre premier preset avec l\'accordage que vous utilisez : dupliquez un accordage standard ou capturez l\'accordage de votre instrument en mode chromatique.';

  @override
  String get emptyCustomFiltered =>
      'Aucun preset pour cet instrument pour l\'instant : créez-en un avec le bouton ci-dessous ou capturez un accordage en mode chromatique.';

  @override
  String get menuEdit => 'Modifier';

  @override
  String get menuDuplicate => 'Dupliquer';

  @override
  String get menuDuplicateEdit => 'Dupliquer et modifier';

  @override
  String get menuDelete => 'Supprimer';

  @override
  String get deleteDialogTitle => 'Supprimer le preset ?';

  @override
  String deleteDialogBody(String name) {
    return '« $name » sera supprimé définitivement.';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get editorTitleNew => 'Nouveau preset';

  @override
  String get editorTitleEdit => 'Modifier le preset';

  @override
  String get save => 'Enregistrer';

  @override
  String get presetNameLabel => 'Nom du preset';

  @override
  String get presetNameHint => 'ex. : Mon accordage Drop B';

  @override
  String get sectionInstrument => 'Instrument';

  @override
  String get sectionStrings => 'Cordes — de la plus grave à la plus aiguë';

  @override
  String get addString => 'Ajouter une corde';

  @override
  String get semitoneDown => 'Demi-ton en dessous';

  @override
  String get semitoneUp => 'Demi-ton au-dessus';

  @override
  String get removeString => 'Retirer la corde';

  @override
  String get errorPresetName => 'Donnez un nom au preset.';

  @override
  String get errorPresetStrings => 'Ajoutez au moins une corde.';

  @override
  String copyName(String name) {
    return '$name (copie)';
  }

  @override
  String get instrumentGuitar => 'Guitare';

  @override
  String get instrumentBass => 'Basse';

  @override
  String get instrumentUkulele => 'Ukulélé';

  @override
  String get instrumentCavaquinho => 'Cavaquinho';

  @override
  String get instrumentOther => 'Autre';

  @override
  String get presetStandardGuitar => 'Standard (E A D G B E)';

  @override
  String get presetDropC => 'Drop C';

  @override
  String get presetDropD => 'Drop D';

  @override
  String get presetHalfStepDown => 'Demi-ton en dessous (Eb)';

  @override
  String get presetDropCSharp => 'Drop C#';

  @override
  String get presetDropB => 'Drop B';

  @override
  String get presetDropA => 'Drop A';

  @override
  String get presetOpenD => 'Open D';

  @override
  String get presetDStandard => 'Un ton en dessous (D)';

  @override
  String get presetCStandard => 'Standard en C';

  @override
  String get presetDadgad => 'DADGAD';

  @override
  String get presetOpenG => 'Open G';

  @override
  String get presetGuitar7 => '7 cordes (B E A D G B E)';

  @override
  String get presetBassStandard => 'Basse – Standard (E A D G)';

  @override
  String get presetBass5 => 'Basse – 5 cordes';

  @override
  String get presetUkulele => 'Ukulélé – Standard (G C E A)';

  @override
  String get presetCavaquinho => 'Cavaquinho (D G B D)';

  @override
  String get presetMandolin => 'Mandoline (G D A E)';
}
