// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Forever Tuner';

  @override
  String get tunerTitle => 'FOREVER TUNER';

  @override
  String get tagline => 'Tune freely. No ads. Ever.';

  @override
  String calibrationTooltip(int hz) {
    return 'キャリブレーション（A4 = $hz Hz）';
  }

  @override
  String get presetsTooltip => 'チューニングプリセット';

  @override
  String get statusMicPaused => 'マイク停止中';

  @override
  String get statusListening => '弦を弾いてください…';

  @override
  String get statusTooLow => '低すぎます — 弦を締めてください';

  @override
  String get statusSlightlyLow => 'もう少し — 少し締めて';

  @override
  String get statusInTune => 'チューニング完了!';

  @override
  String get statusSlightlyHigh => 'もう少し — 少し緩めて';

  @override
  String get statusTooHigh => '高すぎます — 弦を緩めてください';

  @override
  String get instrumentTuned => '楽器のチューニング完了! 🤘';

  @override
  String get modeStrings => '弦';

  @override
  String get modeChromatic => 'クロマチック';

  @override
  String get captureTitle => 'チューニングキャプチャ';

  @override
  String get captureClear => 'クリア';

  @override
  String get captureHint =>
      '自由に各弦をチューニングしてください。音が安定するとここに追加されます。低い弦から高い弦の順に弾いて、プリセットとして保存しましょう。';

  @override
  String get captureSave => 'プリセットとして保存';

  @override
  String get hzUnit => 'Hz';

  @override
  String get centsUnit => 'セント';

  @override
  String get permissionTitle => 'マイクにアクセスできません';

  @override
  String get permissionBody =>
      '楽器をチューニングするには、Forever Tuner が弦の音を聞く必要があります。端末の設定でマイクの権限を許可してください。';

  @override
  String get permissionRetry => '再試行';

  @override
  String get calibrationTitle => '基準ピッチの調整';

  @override
  String get calibrationSubtitle => 'A4 の周波数（デフォルト: 440 Hz）';

  @override
  String get calibrationRestore => '440 Hz に戻す';

  @override
  String get calibrationListenTitle => '基準音でキャリブレーション';

  @override
  String get calibrationListenHint => '近くで基準音（音叉、ピアノ、他のチューナー）を安定して鳴らし続けてください。';

  @override
  String get calibrationListening => 'リスニング中…';

  @override
  String get calibrationApply => '適用';

  @override
  String get presetsTitle => 'チューニング';

  @override
  String get sectionMyPresets => 'マイプリセット';

  @override
  String get sectionBuiltIn => '標準チューニング';

  @override
  String get filterAll => 'すべて';

  @override
  String get newPreset => '新規プリセット';

  @override
  String get emptyCustom =>
      '使っているチューニングで最初のプリセットを作りましょう。標準チューニングを複製するか、クロマチックモードで楽器のチューニングをキャプチャできます。';

  @override
  String get emptyCustomFiltered =>
      'この楽器のプリセットはまだありません。下のボタンで作成するか、クロマチックモードでチューニングをキャプチャしてください。';

  @override
  String get menuEdit => '編集';

  @override
  String get menuDuplicate => '複製';

  @override
  String get menuDuplicateEdit => '複製して編集';

  @override
  String get menuDelete => '削除';

  @override
  String get deleteDialogTitle => 'プリセットを削除しますか?';

  @override
  String deleteDialogBody(String name) {
    return '「$name」は完全に削除されます。';
  }

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get editorTitleNew => '新規プリセット';

  @override
  String get editorTitleEdit => 'プリセットを編集';

  @override
  String get save => '保存';

  @override
  String get presetNameLabel => 'プリセット名';

  @override
  String get presetNameHint => '例: マイ Drop B チューニング';

  @override
  String get sectionInstrument => '楽器';

  @override
  String get sectionStrings => '弦 — 低い方から高い方へ';

  @override
  String get addString => '弦を追加';

  @override
  String get semitoneDown => '半音下げる';

  @override
  String get semitoneUp => '半音上げる';

  @override
  String get removeString => '弦を削除';

  @override
  String get errorPresetName => 'プリセットに名前を付けてください。';

  @override
  String get errorPresetStrings => '少なくとも 1 本の弦を追加してください。';

  @override
  String copyName(String name) {
    return '$name（コピー）';
  }

  @override
  String get instrumentGuitar => 'ギター';

  @override
  String get instrumentBass => 'ベース';

  @override
  String get instrumentUkulele => 'ウクレレ';

  @override
  String get instrumentCavaquinho => 'カバキーニョ';

  @override
  String get instrumentOther => 'その他';

  @override
  String get presetStandardGuitar => 'スタンダード (E A D G B E)';

  @override
  String get presetSoad => 'SOAD – Drop C';

  @override
  String get presetDropD => 'Drop D';

  @override
  String get presetHalfStepDown => '半音下げ (Eb)';

  @override
  String get presetDropCSharp => 'Drop C#';

  @override
  String get presetDadgad => 'DADGAD';

  @override
  String get presetOpenG => 'Open G';

  @override
  String get presetBassStandard => 'ベース – スタンダード (E A D G)';

  @override
  String get presetBass5 => 'ベース – 5 弦';

  @override
  String get presetUkulele => 'ウクレレ – スタンダード (G C E A)';

  @override
  String get presetCavaquinho => 'カバキーニョ (D G B D)';
}
