// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'NoAd Tuner';

  @override
  String get tunerTitle => 'NOAD TUNER';

  @override
  String get tagline => 'Tune freely. No ads. Ever.';

  @override
  String calibrationTooltip(int hz) {
    return '校准（A4 = $hz Hz）';
  }

  @override
  String get presetsTooltip => '调音预设';

  @override
  String get statusMicPaused => '麦克风已暂停';

  @override
  String get statusListening => '请弹奏一根琴弦…';

  @override
  String get statusTooLow => '太低了——请调紧琴弦';

  @override
  String get statusSlightlyLow => '接近了——稍微调紧';

  @override
  String get statusInTune => '已调准！';

  @override
  String get statusSlightlyHigh => '接近了——稍微调松';

  @override
  String get statusTooHigh => '太高了——请调松琴弦';

  @override
  String get instrumentTuned => '乐器已调准！🤘';

  @override
  String get modeStrings => '琴弦';

  @override
  String get modeChromatic => '自由';

  @override
  String get captureTitle => '调音捕捉';

  @override
  String get captureClear => '清空';

  @override
  String get captureHint => '自由地为每根弦调音——当音符稳定后会出现在这里。从最低音弦弹到最高音弦，然后保存为预设。';

  @override
  String get captureSave => '保存为预设';

  @override
  String get hzUnit => 'Hz';

  @override
  String get centsUnit => '音分';

  @override
  String get permissionTitle => '无法访问麦克风';

  @override
  String get permissionBody => '要为乐器调音，NoAd Tuner 需要听到琴弦的声音。请在设备设置中授予麦克风权限。';

  @override
  String get permissionRetry => '重试';

  @override
  String get calibrationTitle => '基准音校准';

  @override
  String get calibrationSubtitle => 'A4 频率（默认：440 Hz）';

  @override
  String get calibrationRestore => '恢复 440 Hz';

  @override
  String get calibrationListenTitle => '使用参考音校准';

  @override
  String get calibrationListenHint => '在附近播放稳定的参考音（音叉、钢琴或其他调音器）并保持。';

  @override
  String get calibrationListening => '正在聆听…';

  @override
  String get calibrationApply => '应用';

  @override
  String get hapticGuideTitle => '引导震动';

  @override
  String get hapticGuideHint => '越接近目标音，震动越快；调准时会有确认震动。';

  @override
  String get presetsTitle => '调音方案';

  @override
  String get sectionMyPresets => '我的预设';

  @override
  String get sectionBuiltIn => '标准调音';

  @override
  String get filterAll => '全部';

  @override
  String get newPreset => '新建预设';

  @override
  String get emptyCustom => '用你常用的调音创建第一个预设——复制一个标准调音，或在调音器的半音模式下捕捉乐器的调音。';

  @override
  String get emptyCustomFiltered => '此乐器还没有你的预设——用下方按钮创建一个，或在半音模式下捕捉调音。';

  @override
  String get menuEdit => '编辑';

  @override
  String get menuDuplicate => '复制';

  @override
  String get menuDuplicateEdit => '复制并编辑';

  @override
  String get menuDelete => '删除';

  @override
  String get deleteDialogTitle => '删除预设？';

  @override
  String deleteDialogBody(String name) {
    return '“$name”将被永久删除。';
  }

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get editorTitleNew => '新建预设';

  @override
  String get editorTitleEdit => '编辑预设';

  @override
  String get save => '保存';

  @override
  String get presetNameLabel => '预设名称';

  @override
  String get presetNameHint => '例如：我的 Drop B 调音';

  @override
  String get sectionInstrument => '乐器';

  @override
  String get sectionStrings => '琴弦——从最低音到最高音';

  @override
  String get addString => '添加琴弦';

  @override
  String get semitoneDown => '降半音';

  @override
  String get semitoneUp => '升半音';

  @override
  String get removeString => '移除琴弦';

  @override
  String get errorPresetName => '请为预设命名。';

  @override
  String get errorPresetStrings => '请至少添加一根琴弦。';

  @override
  String copyName(String name) {
    return '$name（副本）';
  }

  @override
  String get instrumentGuitar => '吉他';

  @override
  String get instrumentBass => '贝斯';

  @override
  String get instrumentUkulele => '尤克里里';

  @override
  String get instrumentCavaquinho => '卡瓦基纽';

  @override
  String get instrumentOther => '其他';

  @override
  String get presetStandardGuitar => '标准 (E A D G B E)';

  @override
  String get presetDropC => 'Drop C';

  @override
  String get presetDropD => 'Drop D';

  @override
  String get presetHalfStepDown => '降半音 (Eb)';

  @override
  String get presetDropCSharp => 'Drop C#';

  @override
  String get presetDropB => 'Drop B';

  @override
  String get presetDropA => 'Drop A';

  @override
  String get presetOpenD => 'Open D';

  @override
  String get presetDStandard => '降全音 (D)';

  @override
  String get presetCStandard => 'C 标准';

  @override
  String get presetDadgad => 'DADGAD';

  @override
  String get presetOpenG => 'Open G';

  @override
  String get presetGuitar7 => '7弦 (B E A D G B E)';

  @override
  String get presetBassStandard => '贝斯 – 标准 (E A D G)';

  @override
  String get presetBass5 => '贝斯 – 5 弦';

  @override
  String get presetUkulele => '尤克里里 – 标准 (G C E A)';

  @override
  String get presetCavaquinho => '卡瓦基纽 (D G B D)';

  @override
  String get presetMandolin => '曼陀林 (G D A E)';
}
