// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'NoAd Tuner';

  @override
  String get tunerTitle => 'NOAD TUNER';

  @override
  String get tagline => 'Tune freely. No ads. Ever.';

  @override
  String calibrationTooltip(int hz) {
    return 'Калибровка (A4 = $hz Гц)';
  }

  @override
  String get presetsTooltip => 'Пресеты строя';

  @override
  String get statusMicPaused => 'Микрофон на паузе';

  @override
  String get statusListening => 'Сыграйте струну…';

  @override
  String get statusTooLow => 'Слишком низко — подтяните струну';

  @override
  String get statusSlightlyLow => 'Почти — чуть подтяните';

  @override
  String get statusInTune => 'Настроено!';

  @override
  String get statusSlightlyHigh => 'Почти — чуть ослабьте';

  @override
  String get statusTooHigh => 'Слишком высоко — ослабьте струну';

  @override
  String get instrumentTuned => 'Инструмент настроен! 🤘';

  @override
  String get modeStrings => 'Струны';

  @override
  String get modeChromatic => 'Хроматический';

  @override
  String get captureTitle => 'Захват строя';

  @override
  String get captureClear => 'Очистить';

  @override
  String get captureHint =>
      'Настраивайте каждую струну свободно — когда нота стабилизируется, она появится здесь. Играйте от самой низкой струны к самой высокой, затем сохраните как пресет.';

  @override
  String get captureSave => 'Сохранить как пресет';

  @override
  String get hzUnit => 'Гц';

  @override
  String get centsUnit => 'центов';

  @override
  String get permissionTitle => 'Нет доступа к микрофону';

  @override
  String get permissionBody =>
      'Чтобы настроить инструмент, NoAd Tuner должен слышать струны. Разрешите доступ к микрофону в настройках устройства.';

  @override
  String get permissionRetry => 'Повторить';

  @override
  String get calibrationTitle => 'Калибровка эталона';

  @override
  String get calibrationSubtitle => 'Частота A4 (по умолчанию: 440 Гц)';

  @override
  String get calibrationRestore => 'Вернуть 440 Гц';

  @override
  String get calibrationListenTitle => 'Калибровка по эталонному тону';

  @override
  String get calibrationListenHint =>
      'Сыграйте рядом ровный эталонный тон (камертон, пианино, другой тюнер) и удерживайте его.';

  @override
  String get calibrationListening => 'Слушаю…';

  @override
  String get calibrationApply => 'Применить';

  @override
  String get presetsTitle => 'Строи';

  @override
  String get sectionMyPresets => 'Мои пресеты';

  @override
  String get sectionBuiltIn => 'Стандартные строи';

  @override
  String get filterAll => 'Все';

  @override
  String get newPreset => 'Новый пресет';

  @override
  String get emptyCustom =>
      'Создайте свой первый пресет со строем, который используете: продублируйте стандартный строй или захватите строй инструмента в хроматическом режиме тюнера.';

  @override
  String get emptyCustomFiltered =>
      'Для этого инструмента у вас пока нет пресетов — создайте его кнопкой ниже или захватите строй в хроматическом режиме.';

  @override
  String get menuEdit => 'Изменить';

  @override
  String get menuDuplicate => 'Дублировать';

  @override
  String get menuDuplicateEdit => 'Дублировать и изменить';

  @override
  String get menuDelete => 'Удалить';

  @override
  String get deleteDialogTitle => 'Удалить пресет?';

  @override
  String deleteDialogBody(String name) {
    return '«$name» будет удалён навсегда.';
  }

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get editorTitleNew => 'Новый пресет';

  @override
  String get editorTitleEdit => 'Изменить пресет';

  @override
  String get save => 'Сохранить';

  @override
  String get presetNameLabel => 'Название пресета';

  @override
  String get presetNameHint => 'напр.: Мой строй Drop B';

  @override
  String get sectionInstrument => 'Инструмент';

  @override
  String get sectionStrings => 'Струны — от самой низкой к самой высокой';

  @override
  String get addString => 'Добавить струну';

  @override
  String get semitoneDown => 'На полтона ниже';

  @override
  String get semitoneUp => 'На полтона выше';

  @override
  String get removeString => 'Убрать струну';

  @override
  String get errorPresetName => 'Дайте пресету название.';

  @override
  String get errorPresetStrings => 'Добавьте хотя бы одну струну.';

  @override
  String copyName(String name) {
    return '$name (копия)';
  }

  @override
  String get instrumentGuitar => 'Гитара';

  @override
  String get instrumentBass => 'Бас';

  @override
  String get instrumentUkulele => 'Укулеле';

  @override
  String get instrumentCavaquinho => 'Кавакинью';

  @override
  String get instrumentOther => 'Другой';

  @override
  String get presetStandardGuitar => 'Стандартный (E A D G B E)';

  @override
  String get presetDropC => 'Drop C';

  @override
  String get presetDropD => 'Drop D';

  @override
  String get presetHalfStepDown => 'На полтона ниже (Eb)';

  @override
  String get presetDropCSharp => 'Drop C#';

  @override
  String get presetDropB => 'Drop B';

  @override
  String get presetDropA => 'Drop A';

  @override
  String get presetOpenD => 'Open D';

  @override
  String get presetDStandard => 'На тон ниже (D)';

  @override
  String get presetCStandard => 'Строй C';

  @override
  String get presetDadgad => 'DADGAD';

  @override
  String get presetOpenG => 'Open G';

  @override
  String get presetGuitar7 => '7 струн (B E A D G B E)';

  @override
  String get presetBassStandard => 'Бас – Стандартный (E A D G)';

  @override
  String get presetBass5 => 'Бас – 5 струн';

  @override
  String get presetUkulele => 'Укулеле – Стандартный (G C E A)';

  @override
  String get presetCavaquinho => 'Кавакинью (D G B D)';

  @override
  String get presetMandolin => 'Мандолина (G D A E)';
}
