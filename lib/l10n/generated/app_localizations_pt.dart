// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'NoAd Tuner';

  @override
  String get tunerTitle => 'NOAD TUNER';

  @override
  String get tagline => 'Tune freely. No ads. Ever.';

  @override
  String calibrationTooltip(int hz) {
    return 'Calibração (A4 = $hz Hz)';
  }

  @override
  String get presetsTooltip => 'Presets de afinação';

  @override
  String get statusMicPaused => 'Microfone pausado';

  @override
  String get statusListening => 'Toque uma corda…';

  @override
  String get statusTooLow => 'Muito baixo — aperte a corda';

  @override
  String get statusSlightlyLow => 'Quase lá — aperte de leve';

  @override
  String get statusInTune => 'Afinado!';

  @override
  String get statusSlightlyHigh => 'Quase lá — solte de leve';

  @override
  String get statusTooHigh => 'Muito alto — solte a corda';

  @override
  String get instrumentTuned => 'Instrumento afinado! 🤘';

  @override
  String get modeStrings => 'Cordas';

  @override
  String get modeChromatic => 'Livre';

  @override
  String get captureTitle => 'Captura de afinação';

  @override
  String get captureClear => 'Limpar';

  @override
  String get captureHint =>
      'Afine cada corda livremente — quando uma nota estabiliza, ela entra aqui. Toque da corda mais grave para a mais aguda e depois salve como preset.';

  @override
  String get captureSave => 'Salvar como preset';

  @override
  String get hzUnit => 'Hz';

  @override
  String get centsUnit => 'cents';

  @override
  String get permissionTitle => 'Sem acesso ao microfone';

  @override
  String get permissionBody =>
      'Para afinar seu instrumento, o NoAd Tuner precisa ouvir o som das cordas. Conceda a permissão de microfone nas configurações do aparelho.';

  @override
  String get permissionRetry => 'Tentar novamente';

  @override
  String get calibrationTitle => 'Calibração da referência';

  @override
  String get calibrationSubtitle => 'Frequência do A4 (padrão: 440 Hz)';

  @override
  String get calibrationRestore => 'Restaurar 440 Hz';

  @override
  String get calibrationListenTitle => 'Calibrar por tom de referência';

  @override
  String get calibrationListenHint =>
      'Toque um tom de referência contínuo perto do aparelho (diapasão, piano, outro afinador) e sustente.';

  @override
  String get calibrationListening => 'Ouvindo…';

  @override
  String get calibrationApply => 'Aplicar';

  @override
  String get hapticGuideTitle => 'Vibração guia';

  @override
  String get hapticGuideHint =>
      'Vibra mais rápido conforme a corda chega perto e confirma quando afina.';

  @override
  String get presetsTitle => 'Afinações';

  @override
  String get sectionMyPresets => 'Meus presets';

  @override
  String get sectionBuiltIn => 'Afinações padrão';

  @override
  String get filterAll => 'Todos';

  @override
  String get newPreset => 'Novo preset';

  @override
  String get emptyCustom =>
      'Crie seu primeiro preset com a afinação que você usa — duplique uma afinação padrão ou capture a afinação do seu instrumento no modo cromático do afinador.';

  @override
  String get emptyCustomFiltered =>
      'Nenhum preset seu para esse instrumento ainda — crie um no botão abaixo ou capture uma afinação no modo cromático do afinador.';

  @override
  String get menuEdit => 'Editar';

  @override
  String get menuDuplicate => 'Duplicar';

  @override
  String get menuDuplicateEdit => 'Duplicar e editar';

  @override
  String get menuDelete => 'Excluir';

  @override
  String get deleteDialogTitle => 'Excluir preset?';

  @override
  String deleteDialogBody(String name) {
    return '\"$name\" será removido permanentemente.';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get editorTitleNew => 'Novo preset';

  @override
  String get editorTitleEdit => 'Editar preset';

  @override
  String get save => 'Salvar';

  @override
  String get presetNameLabel => 'Nome do preset';

  @override
  String get presetNameHint => 'ex.: Minha afinação Drop B';

  @override
  String get sectionInstrument => 'Instrumento';

  @override
  String get sectionStrings => 'Cordas — da mais grave para a mais aguda';

  @override
  String get addString => 'Adicionar corda';

  @override
  String get semitoneDown => 'Meio tom abaixo';

  @override
  String get semitoneUp => 'Meio tom acima';

  @override
  String get removeString => 'Remover corda';

  @override
  String get errorPresetName => 'Dê um nome ao preset.';

  @override
  String get errorPresetStrings => 'Adicione pelo menos uma corda.';

  @override
  String copyName(String name) {
    return '$name (cópia)';
  }

  @override
  String get instrumentGuitar => 'Guitarra/Violão';

  @override
  String get instrumentBass => 'Baixo';

  @override
  String get instrumentUkulele => 'Ukulele';

  @override
  String get instrumentCavaquinho => 'Cavaquinho';

  @override
  String get instrumentOther => 'Outro';

  @override
  String get presetStandardGuitar => 'Padrão (E A D G B E)';

  @override
  String get presetDropC => 'Drop C';

  @override
  String get presetDropD => 'Drop D';

  @override
  String get presetHalfStepDown => 'Meio tom abaixo (Eb)';

  @override
  String get presetDropCSharp => 'Drop C#';

  @override
  String get presetDropB => 'Drop B';

  @override
  String get presetDropA => 'Drop A';

  @override
  String get presetOpenD => 'Open D';

  @override
  String get presetDStandard => 'Um tom abaixo (D)';

  @override
  String get presetCStandard => 'Padrão em C';

  @override
  String get presetDadgad => 'DADGAD';

  @override
  String get presetOpenG => 'Open G';

  @override
  String get presetGuitar7 => '7 cordas (B E A D G B E)';

  @override
  String get presetBassStandard => 'Baixo – Padrão (E A D G)';

  @override
  String get presetBass5 => 'Baixo – 5 cordas';

  @override
  String get presetUkulele => 'Ukulele – Padrão (G C E A)';

  @override
  String get presetCavaquinho => 'Cavaquinho (D G B D)';

  @override
  String get presetMandolin => 'Bandolim (G D A E)';
}
