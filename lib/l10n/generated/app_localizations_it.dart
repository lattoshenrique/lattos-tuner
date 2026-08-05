// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Forever Tuner';

  @override
  String get tunerTitle => 'FOREVER TUNER';

  @override
  String get tagline => 'Tune freely. No ads. Ever.';

  @override
  String calibrationTooltip(int hz) {
    return 'Calibrazione (A4 = $hz Hz)';
  }

  @override
  String get presetsTooltip => 'Preset di accordatura';

  @override
  String get statusMicPaused => 'Microfono in pausa';

  @override
  String get statusListening => 'Suona una corda…';

  @override
  String get statusTooLow => 'Troppo basso — tendi la corda';

  @override
  String get statusSlightlyLow => 'Quasi — tendi leggermente';

  @override
  String get statusInTune => 'Accordato!';

  @override
  String get statusSlightlyHigh => 'Quasi — allenta leggermente';

  @override
  String get statusTooHigh => 'Troppo alto — allenta la corda';

  @override
  String get instrumentTuned => 'Strumento accordato! 🤘';

  @override
  String get modeStrings => 'Corde';

  @override
  String get modeChromatic => 'Cromatico';

  @override
  String get captureTitle => 'Cattura accordatura';

  @override
  String get captureClear => 'Svuota';

  @override
  String get captureHint =>
      'Accorda ogni corda liberamente: quando una nota si stabilizza, appare qui. Suona dalla corda più grave alla più acuta, poi salva come preset.';

  @override
  String get captureSave => 'Salva come preset';

  @override
  String get hzUnit => 'Hz';

  @override
  String get centsUnit => 'cent';

  @override
  String get permissionTitle => 'Nessun accesso al microfono';

  @override
  String get permissionBody =>
      'Per accordare il tuo strumento, Forever Tuner deve sentire le corde. Concedi il permesso del microfono nelle impostazioni del dispositivo.';

  @override
  String get permissionRetry => 'Riprova';

  @override
  String get calibrationTitle => 'Calibrazione di riferimento';

  @override
  String get calibrationSubtitle => 'Frequenza del A4 (predefinita: 440 Hz)';

  @override
  String get calibrationRestore => 'Ripristina 440 Hz';

  @override
  String get calibrationListenTitle => 'Calibra con un tono di riferimento';

  @override
  String get calibrationListenHint =>
      'Suona un tono di riferimento costante nelle vicinanze (diapason, pianoforte, altro accordatore) e mantienilo.';

  @override
  String get calibrationListening => 'In ascolto…';

  @override
  String get calibrationApply => 'Applica';

  @override
  String get presetsTitle => 'Accordature';

  @override
  String get sectionMyPresets => 'I miei preset';

  @override
  String get sectionBuiltIn => 'Accordature standard';

  @override
  String get filterAll => 'Tutti';

  @override
  String get newPreset => 'Nuovo preset';

  @override
  String get emptyCustom =>
      'Crea il tuo primo preset con l\'accordatura che usi: duplica un\'accordatura standard o cattura l\'accordatura del tuo strumento in modalità cromatica.';

  @override
  String get emptyCustomFiltered =>
      'Ancora nessun preset per questo strumento: creane uno con il pulsante qui sotto o cattura un\'accordatura in modalità cromatica.';

  @override
  String get menuEdit => 'Modifica';

  @override
  String get menuDuplicate => 'Duplica';

  @override
  String get menuDuplicateEdit => 'Duplica e modifica';

  @override
  String get menuDelete => 'Elimina';

  @override
  String get deleteDialogTitle => 'Eliminare il preset?';

  @override
  String deleteDialogBody(String name) {
    return '\"$name\" sarà rimosso definitivamente.';
  }

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get editorTitleNew => 'Nuovo preset';

  @override
  String get editorTitleEdit => 'Modifica preset';

  @override
  String get save => 'Salva';

  @override
  String get presetNameLabel => 'Nome del preset';

  @override
  String get presetNameHint => 'es.: La mia accordatura Drop B';

  @override
  String get sectionInstrument => 'Strumento';

  @override
  String get sectionStrings => 'Corde — dalla più grave alla più acuta';

  @override
  String get addString => 'Aggiungi corda';

  @override
  String get semitoneDown => 'Mezzo tono sotto';

  @override
  String get semitoneUp => 'Mezzo tono sopra';

  @override
  String get removeString => 'Rimuovi corda';

  @override
  String get errorPresetName => 'Dai un nome al preset.';

  @override
  String get errorPresetStrings => 'Aggiungi almeno una corda.';

  @override
  String copyName(String name) {
    return '$name (copia)';
  }

  @override
  String get instrumentGuitar => 'Chitarra';

  @override
  String get instrumentBass => 'Basso';

  @override
  String get instrumentUkulele => 'Ukulele';

  @override
  String get instrumentCavaquinho => 'Cavaquinho';

  @override
  String get instrumentOther => 'Altro';

  @override
  String get presetStandardGuitar => 'Standard (E A D G B E)';

  @override
  String get presetDropC => 'Drop C';

  @override
  String get presetDropD => 'Drop D';

  @override
  String get presetHalfStepDown => 'Mezzo tono sotto (Eb)';

  @override
  String get presetDropCSharp => 'Drop C#';

  @override
  String get presetDropB => 'Drop B';

  @override
  String get presetDropA => 'Drop A';

  @override
  String get presetOpenD => 'Open D';

  @override
  String get presetDStandard => 'Un tono sotto (D)';

  @override
  String get presetCStandard => 'Standard in C';

  @override
  String get presetDadgad => 'DADGAD';

  @override
  String get presetOpenG => 'Open G';

  @override
  String get presetGuitar7 => '7 corde (B E A D G B E)';

  @override
  String get presetBassStandard => 'Basso – Standard (E A D G)';

  @override
  String get presetBass5 => 'Basso – 5 corde';

  @override
  String get presetUkulele => 'Ukulele – Standard (G C E A)';

  @override
  String get presetCavaquinho => 'Cavaquinho (D G B D)';

  @override
  String get presetMandolin => 'Mandolino (G D A E)';
}
