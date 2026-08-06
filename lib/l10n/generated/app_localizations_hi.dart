// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'NoAd Tuner';

  @override
  String get tunerTitle => 'NOAD TUNER';

  @override
  String get tagline => 'Tune freely. No ads. Ever.';

  @override
  String calibrationTooltip(int hz) {
    return 'कैलिब्रेशन (A4 = $hz Hz)';
  }

  @override
  String get presetsTooltip => 'ट्यूनिंग प्रीसेट';

  @override
  String get statusMicPaused => 'माइक्रोफ़ोन रुका हुआ है';

  @override
  String get statusListening => 'कोई तार बजाएँ…';

  @override
  String get statusTooLow => 'बहुत नीचा — तार कसें';

  @override
  String get statusSlightlyLow => 'लगभग हो गया — थोड़ा कसें';

  @override
  String get statusInTune => 'सुर में!';

  @override
  String get statusSlightlyHigh => 'लगभग हो गया — थोड़ा ढीला करें';

  @override
  String get statusTooHigh => 'बहुत ऊँचा — तार ढीला करें';

  @override
  String get instrumentTuned => 'वाद्य सुर में है! 🤘';

  @override
  String get modeStrings => 'तार';

  @override
  String get modeChromatic => 'फ्री';

  @override
  String get captureTitle => 'ट्यूनिंग कैप्चर';

  @override
  String get captureClear => 'साफ़ करें';

  @override
  String get captureHint =>
      'हर तार को आज़ादी से ट्यून करें — जब कोई स्वर स्थिर हो जाता है, तो वह यहाँ आ जाता है। सबसे नीचे के तार से सबसे ऊँचे तक बजाएँ, फिर प्रीसेट के रूप में सहेजें।';

  @override
  String get captureSave => 'प्रीसेट के रूप में सहेजें';

  @override
  String get hzUnit => 'Hz';

  @override
  String get centsUnit => 'सेंट';

  @override
  String get permissionTitle => 'माइक्रोफ़ोन उपलब्ध नहीं';

  @override
  String get permissionBody =>
      'वाद्य को ट्यून करने के लिए NoAd Tuner को तारों की आवाज़ सुननी होगी। डिवाइस सेटिंग में माइक्रोफ़ोन की अनुमति दें।';

  @override
  String get permissionRetry => 'फिर से कोशिश करें';

  @override
  String get calibrationTitle => 'संदर्भ कैलिब्रेशन';

  @override
  String get calibrationSubtitle => 'A4 आवृत्ति (डिफ़ॉल्ट: 440 Hz)';

  @override
  String get calibrationRestore => '440 Hz बहाल करें';

  @override
  String get calibrationListenTitle => 'संदर्भ स्वर से कैलिब्रेट करें';

  @override
  String get calibrationListenHint =>
      'पास में एक स्थिर संदर्भ स्वर बजाएँ (ट्यूनिंग फोर्क, पियानो, दूसरा ट्यूनर) और उसे बनाए रखें।';

  @override
  String get calibrationListening => 'सुन रहा है…';

  @override
  String get calibrationApply => 'लागू करें';

  @override
  String get hapticGuideTitle => 'गाइड कंपन';

  @override
  String get hapticGuideHint =>
      'तार जितना पास आता है कंपन उतना तेज़ होता है, और सही होने पर पुष्टि मिलती है।';

  @override
  String get presetsTitle => 'ट्यूनिंग';

  @override
  String get sectionMyPresets => 'मेरे प्रीसेट';

  @override
  String get sectionBuiltIn => 'मानक ट्यूनिंग';

  @override
  String get filterAll => 'सभी';

  @override
  String get newPreset => 'नया प्रीसेट';

  @override
  String get emptyCustom =>
      'अपनी ट्यूनिंग से पहला प्रीसेट बनाएँ — किसी मानक ट्यूनिंग की प्रति बनाएँ या ट्यूनर के क्रोमैटिक मोड में अपने वाद्य की ट्यूनिंग कैप्चर करें।';

  @override
  String get emptyCustomFiltered =>
      'इस वाद्य के लिए अभी आपका कोई प्रीसेट नहीं है — नीचे के बटन से बनाएँ या क्रोमैटिक मोड में ट्यूनिंग कैप्चर करें।';

  @override
  String get menuEdit => 'संपादित करें';

  @override
  String get menuDuplicate => 'प्रतिलिपि बनाएँ';

  @override
  String get menuDuplicateEdit => 'प्रतिलिपि बनाकर संपादित करें';

  @override
  String get menuDelete => 'हटाएँ';

  @override
  String get deleteDialogTitle => 'प्रीसेट हटाएँ?';

  @override
  String deleteDialogBody(String name) {
    return '\"$name\" स्थायी रूप से हटा दिया जाएगा।';
  }

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएँ';

  @override
  String get editorTitleNew => 'नया प्रीसेट';

  @override
  String get editorTitleEdit => 'प्रीसेट संपादित करें';

  @override
  String get save => 'सहेजें';

  @override
  String get presetNameLabel => 'प्रीसेट का नाम';

  @override
  String get presetNameHint => 'जैसे: मेरी Drop B ट्यूनिंग';

  @override
  String get sectionInstrument => 'वाद्य';

  @override
  String get sectionStrings => 'तार — सबसे नीचे से सबसे ऊँचे तक';

  @override
  String get addString => 'तार जोड़ें';

  @override
  String get semitoneDown => 'आधा स्वर नीचे';

  @override
  String get semitoneUp => 'आधा स्वर ऊपर';

  @override
  String get removeString => 'तार हटाएँ';

  @override
  String get errorPresetName => 'प्रीसेट को एक नाम दें।';

  @override
  String get errorPresetStrings => 'कम से कम एक तार जोड़ें।';

  @override
  String copyName(String name) {
    return '$name (प्रति)';
  }

  @override
  String get instrumentGuitar => 'गिटार';

  @override
  String get instrumentBass => 'बेस';

  @override
  String get instrumentUkulele => 'उकुलेले';

  @override
  String get instrumentCavaquinho => 'कवाकिन्यो';

  @override
  String get instrumentOther => 'अन्य';

  @override
  String get presetStandardGuitar => 'मानक (E A D G B E)';

  @override
  String get presetDropC => 'Drop C';

  @override
  String get presetDropD => 'Drop D';

  @override
  String get presetHalfStepDown => 'आधा स्वर नीचे (Eb)';

  @override
  String get presetDropCSharp => 'Drop C#';

  @override
  String get presetDropB => 'Drop B';

  @override
  String get presetDropA => 'Drop A';

  @override
  String get presetOpenD => 'Open D';

  @override
  String get presetDStandard => 'एक स्वर नीचे (D)';

  @override
  String get presetCStandard => 'C मानक';

  @override
  String get presetDadgad => 'DADGAD';

  @override
  String get presetOpenG => 'Open G';

  @override
  String get presetGuitar7 => '7 तार (B E A D G B E)';

  @override
  String get presetBassStandard => 'बेस – मानक (E A D G)';

  @override
  String get presetBass5 => 'बेस – 5 तार';

  @override
  String get presetUkulele => 'उकुलेले – मानक (G C E A)';

  @override
  String get presetCavaquinho => 'कवाकिन्यो (D G B D)';

  @override
  String get presetMandolin => 'मैंडोलिन (G D A E)';
}
