// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Lattos Tuner';

  @override
  String get tunerTitle => 'LATTOS TUNER';

  @override
  String calibrationTooltip(int hz) {
    return 'المعايرة (A4 = $hz هرتز)';
  }

  @override
  String get presetsTooltip => 'إعدادات الدوزان المسبقة';

  @override
  String get statusMicPaused => 'الميكروفون متوقف';

  @override
  String get statusListening => 'اعزف وترًا…';

  @override
  String get statusTooLow => 'منخفض جدًا — شُدّ الوتر';

  @override
  String get statusSlightlyLow => 'اقتربت — شُدّ قليلًا';

  @override
  String get statusInTune => 'مضبوط!';

  @override
  String get statusSlightlyHigh => 'اقتربت — أرخِ قليلًا';

  @override
  String get statusTooHigh => 'مرتفع جدًا — أرخِ الوتر';

  @override
  String get instrumentTuned => 'الآلة مضبوطة! 🤘';

  @override
  String get modeStrings => 'الأوتار';

  @override
  String get modeChromatic => 'كروماتيكي';

  @override
  String get captureTitle => 'التقاط الدوزان';

  @override
  String get captureClear => 'مسح';

  @override
  String get captureHint =>
      'اضبط كل وتر بحرّية — عندما تستقر النغمة تظهر هنا. اعزف من الوتر الأدنى إلى الأعلى ثم احفظه كإعداد مسبق.';

  @override
  String get captureSave => 'حفظ كإعداد مسبق';

  @override
  String get hzUnit => 'هرتز';

  @override
  String get centsUnit => 'سنت';

  @override
  String get permissionTitle => 'لا يمكن الوصول إلى الميكروفون';

  @override
  String get permissionBody =>
      'لضبط آلتك، يحتاج Lattos Tuner إلى سماع الأوتار. امنح إذن الميكروفون من إعدادات الجهاز.';

  @override
  String get permissionRetry => 'إعادة المحاولة';

  @override
  String get calibrationTitle => 'معايرة المرجع';

  @override
  String get calibrationSubtitle => 'تردد A4 (الافتراضي: 440 هرتز)';

  @override
  String get calibrationRestore => 'استعادة 440 هرتز';

  @override
  String get presetsTitle => 'الدوزانات';

  @override
  String get sectionMyPresets => 'إعداداتي المسبقة';

  @override
  String get sectionBuiltIn => 'دوزانات قياسية';

  @override
  String get filterAll => 'الكل';

  @override
  String get newPreset => 'إعداد مسبق جديد';

  @override
  String get emptyCustom =>
      'أنشئ أول إعداد مسبق بالدوزان الذي تستخدمه — انسخ دوزانًا قياسيًا أو التقط دوزان آلتك في الوضع الكروماتيكي.';

  @override
  String get emptyCustomFiltered =>
      'لا توجد إعدادات مسبقة لهذه الآلة بعد — أنشئ واحدًا بالزر أدناه أو التقط دوزانًا في الوضع الكروماتيكي.';

  @override
  String get menuEdit => 'تعديل';

  @override
  String get menuDuplicate => 'نسخ';

  @override
  String get menuDuplicateEdit => 'نسخ وتعديل';

  @override
  String get menuDelete => 'حذف';

  @override
  String get deleteDialogTitle => 'حذف الإعداد المسبق؟';

  @override
  String deleteDialogBody(String name) {
    return 'سيُحذف \"$name\" نهائيًا.';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get editorTitleNew => 'إعداد مسبق جديد';

  @override
  String get editorTitleEdit => 'تعديل الإعداد المسبق';

  @override
  String get save => 'حفظ';

  @override
  String get presetNameLabel => 'اسم الإعداد المسبق';

  @override
  String get presetNameHint => 'مثال: دوزاني Drop B';

  @override
  String get sectionInstrument => 'الآلة';

  @override
  String get sectionStrings => 'الأوتار — من الأدنى إلى الأعلى';

  @override
  String get addString => 'إضافة وتر';

  @override
  String get semitoneDown => 'نصف درجة أدنى';

  @override
  String get semitoneUp => 'نصف درجة أعلى';

  @override
  String get removeString => 'إزالة الوتر';

  @override
  String get errorPresetName => 'أعطِ الإعداد المسبق اسمًا.';

  @override
  String get errorPresetStrings => 'أضف وترًا واحدًا على الأقل.';

  @override
  String copyName(String name) {
    return '$name (نسخة)';
  }

  @override
  String get instrumentGuitar => 'جيتار';

  @override
  String get instrumentBass => 'بيس';

  @override
  String get instrumentUkulele => 'يوكوليلي';

  @override
  String get instrumentCavaquinho => 'كافاكينيو';

  @override
  String get instrumentOther => 'أخرى';

  @override
  String get presetStandardGuitar => 'قياسي (E A D G B E)';

  @override
  String get presetSoad => 'SOAD – Drop C';

  @override
  String get presetDropD => 'Drop D';

  @override
  String get presetHalfStepDown => 'نصف درجة أدنى (Eb)';

  @override
  String get presetDropCSharp => 'Drop C#';

  @override
  String get presetDadgad => 'DADGAD';

  @override
  String get presetOpenG => 'Open G';

  @override
  String get presetBassStandard => 'بيس – قياسي (E A D G)';

  @override
  String get presetBass5 => 'بيس – 5 أوتار';

  @override
  String get presetUkulele => 'يوكوليلي – قياسي (G C E A)';

  @override
  String get presetCavaquinho => 'كافاكينيو (D G B D)';
}
