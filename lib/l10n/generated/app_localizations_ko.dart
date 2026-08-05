// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Forever Tuner';

  @override
  String get tunerTitle => 'FOREVER TUNER';

  @override
  String get tagline => 'Tune freely. No ads. Ever.';

  @override
  String calibrationTooltip(int hz) {
    return '보정 (A4 = $hz Hz)';
  }

  @override
  String get presetsTooltip => '튜닝 프리셋';

  @override
  String get statusMicPaused => '마이크 일시 중지됨';

  @override
  String get statusListening => '줄을 연주하세요…';

  @override
  String get statusTooLow => '너무 낮아요 — 줄을 조이세요';

  @override
  String get statusSlightlyLow => '거의 다 왔어요 — 살짝 조이세요';

  @override
  String get statusInTune => '조율 완료!';

  @override
  String get statusSlightlyHigh => '거의 다 왔어요 — 살짝 푸세요';

  @override
  String get statusTooHigh => '너무 높아요 — 줄을 푸세요';

  @override
  String get instrumentTuned => '악기 조율 완료! 🤘';

  @override
  String get modeStrings => '줄';

  @override
  String get modeChromatic => '크로매틱';

  @override
  String get captureTitle => '튜닝 캡처';

  @override
  String get captureClear => '지우기';

  @override
  String get captureHint =>
      '각 줄을 자유롭게 조율하세요. 음이 안정되면 여기에 추가됩니다. 가장 낮은 줄부터 높은 줄 순서로 연주한 뒤 프리셋으로 저장하세요.';

  @override
  String get captureSave => '프리셋으로 저장';

  @override
  String get hzUnit => 'Hz';

  @override
  String get centsUnit => '센트';

  @override
  String get permissionTitle => '마이크에 접근할 수 없음';

  @override
  String get permissionBody =>
      '악기를 조율하려면 Forever Tuner가 줄 소리를 들어야 합니다. 기기 설정에서 마이크 권한을 허용해 주세요.';

  @override
  String get permissionRetry => '다시 시도';

  @override
  String get calibrationTitle => '기준음 보정';

  @override
  String get calibrationSubtitle => 'A4 주파수 (기본값: 440 Hz)';

  @override
  String get calibrationRestore => '440 Hz로 복원';

  @override
  String get calibrationListenTitle => '기준음으로 보정';

  @override
  String get calibrationListenHint =>
      '근처에서 기준음(소리굽쇠, 피아노, 다른 튜너)을 안정적으로 지속해서 울려 주세요.';

  @override
  String get calibrationListening => '듣는 중…';

  @override
  String get calibrationApply => '적용';

  @override
  String get presetsTitle => '튜닝';

  @override
  String get sectionMyPresets => '내 프리셋';

  @override
  String get sectionBuiltIn => '표준 튜닝';

  @override
  String get filterAll => '전체';

  @override
  String get newPreset => '새 프리셋';

  @override
  String get emptyCustom =>
      '사용하는 튜닝으로 첫 프리셋을 만들어 보세요. 표준 튜닝을 복제하거나 크로매틱 모드에서 악기의 튜닝을 캡처할 수 있습니다.';

  @override
  String get emptyCustomFiltered =>
      '이 악기의 프리셋이 아직 없습니다. 아래 버튼으로 만들거나 크로매틱 모드에서 튜닝을 캡처하세요.';

  @override
  String get menuEdit => '편집';

  @override
  String get menuDuplicate => '복제';

  @override
  String get menuDuplicateEdit => '복제 후 편집';

  @override
  String get menuDelete => '삭제';

  @override
  String get deleteDialogTitle => '프리셋을 삭제할까요?';

  @override
  String deleteDialogBody(String name) {
    return '\"$name\"이(가) 영구적으로 삭제됩니다.';
  }

  @override
  String get cancel => '취소';

  @override
  String get delete => '삭제';

  @override
  String get editorTitleNew => '새 프리셋';

  @override
  String get editorTitleEdit => '프리셋 편집';

  @override
  String get save => '저장';

  @override
  String get presetNameLabel => '프리셋 이름';

  @override
  String get presetNameHint => '예: 나의 Drop B 튜닝';

  @override
  String get sectionInstrument => '악기';

  @override
  String get sectionStrings => '줄 — 가장 낮은 음부터 높은 음까지';

  @override
  String get addString => '줄 추가';

  @override
  String get semitoneDown => '반음 내리기';

  @override
  String get semitoneUp => '반음 올리기';

  @override
  String get removeString => '줄 제거';

  @override
  String get errorPresetName => '프리셋에 이름을 지어 주세요.';

  @override
  String get errorPresetStrings => '최소 한 줄을 추가하세요.';

  @override
  String copyName(String name) {
    return '$name (사본)';
  }

  @override
  String get instrumentGuitar => '기타';

  @override
  String get instrumentBass => '베이스';

  @override
  String get instrumentUkulele => '우쿨렐레';

  @override
  String get instrumentCavaquinho => '카바키뉴';

  @override
  String get instrumentOther => '기타 악기';

  @override
  String get presetStandardGuitar => '스탠더드 (E A D G B E)';

  @override
  String get presetDropC => 'Drop C';

  @override
  String get presetDropD => 'Drop D';

  @override
  String get presetHalfStepDown => '반음 내림 (Eb)';

  @override
  String get presetDropCSharp => 'Drop C#';

  @override
  String get presetDropB => 'Drop B';

  @override
  String get presetDropA => 'Drop A';

  @override
  String get presetOpenD => 'Open D';

  @override
  String get presetDStandard => '온음 내림 (D)';

  @override
  String get presetCStandard => 'C 스탠더드';

  @override
  String get presetDadgad => 'DADGAD';

  @override
  String get presetOpenG => 'Open G';

  @override
  String get presetGuitar7 => '7현 (B E A D G B E)';

  @override
  String get presetBassStandard => '베이스 – 스탠더드 (E A D G)';

  @override
  String get presetBass5 => '베이스 – 5현';

  @override
  String get presetUkulele => '우쿨렐레 – 스탠더드 (G C E A)';

  @override
  String get presetCavaquinho => '카바키뉴 (D G B D)';

  @override
  String get presetMandolin => '만돌린 (G D A E)';
}
