import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'NoAd Tuner'**
  String get appTitle;

  /// No description provided for @tunerTitle.
  ///
  /// In en, this message translates to:
  /// **'NOAD TUNER'**
  String get tunerTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Tune freely. No ads. Ever.'**
  String get tagline;

  /// Tooltip of the calibration button in the app bar
  ///
  /// In en, this message translates to:
  /// **'Calibration (A4 = {hz} Hz)'**
  String calibrationTooltip(int hz);

  /// No description provided for @presetsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Tuning presets'**
  String get presetsTooltip;

  /// No description provided for @statusMicPaused.
  ///
  /// In en, this message translates to:
  /// **'Microphone paused'**
  String get statusMicPaused;

  /// No description provided for @statusListening.
  ///
  /// In en, this message translates to:
  /// **'Play a string…'**
  String get statusListening;

  /// No description provided for @statusTooLow.
  ///
  /// In en, this message translates to:
  /// **'Too low — tighten the string'**
  String get statusTooLow;

  /// No description provided for @statusSlightlyLow.
  ///
  /// In en, this message translates to:
  /// **'Almost there — tighten slightly'**
  String get statusSlightlyLow;

  /// No description provided for @statusInTune.
  ///
  /// In en, this message translates to:
  /// **'In tune!'**
  String get statusInTune;

  /// No description provided for @statusSlightlyHigh.
  ///
  /// In en, this message translates to:
  /// **'Almost there — loosen slightly'**
  String get statusSlightlyHigh;

  /// No description provided for @statusTooHigh.
  ///
  /// In en, this message translates to:
  /// **'Too high — loosen the string'**
  String get statusTooHigh;

  /// No description provided for @instrumentTuned.
  ///
  /// In en, this message translates to:
  /// **'Instrument in tune! 🤘'**
  String get instrumentTuned;

  /// No description provided for @modeStrings.
  ///
  /// In en, this message translates to:
  /// **'Strings'**
  String get modeStrings;

  /// No description provided for @modeChromatic.
  ///
  /// In en, this message translates to:
  /// **'Chromatic'**
  String get modeChromatic;

  /// No description provided for @captureTitle.
  ///
  /// In en, this message translates to:
  /// **'Tuning capture'**
  String get captureTitle;

  /// No description provided for @captureClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get captureClear;

  /// No description provided for @captureHint.
  ///
  /// In en, this message translates to:
  /// **'Tune each string freely — when a note settles, it lands here. Play from the lowest string to the highest, then save it as a preset.'**
  String get captureHint;

  /// No description provided for @captureSave.
  ///
  /// In en, this message translates to:
  /// **'Save as preset'**
  String get captureSave;

  /// No description provided for @hzUnit.
  ///
  /// In en, this message translates to:
  /// **'Hz'**
  String get hzUnit;

  /// No description provided for @centsUnit.
  ///
  /// In en, this message translates to:
  /// **'cents'**
  String get centsUnit;

  /// No description provided for @permissionTitle.
  ///
  /// In en, this message translates to:
  /// **'No microphone access'**
  String get permissionTitle;

  /// No description provided for @permissionBody.
  ///
  /// In en, this message translates to:
  /// **'To tune your instrument, NoAd Tuner needs to hear the strings. Grant microphone permission in your device settings.'**
  String get permissionBody;

  /// No description provided for @permissionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get permissionRetry;

  /// No description provided for @calibrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Reference calibration'**
  String get calibrationTitle;

  /// No description provided for @calibrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A4 frequency (default: 440 Hz)'**
  String get calibrationSubtitle;

  /// No description provided for @calibrationRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore 440 Hz'**
  String get calibrationRestore;

  /// No description provided for @calibrationListenTitle.
  ///
  /// In en, this message translates to:
  /// **'Calibrate with a reference tone'**
  String get calibrationListenTitle;

  /// No description provided for @calibrationListenHint.
  ///
  /// In en, this message translates to:
  /// **'Play a steady reference tone nearby (tuning fork, piano, another tuner) and hold it.'**
  String get calibrationListenHint;

  /// No description provided for @calibrationListening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get calibrationListening;

  /// No description provided for @calibrationApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get calibrationApply;

  /// No description provided for @presetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tunings'**
  String get presetsTitle;

  /// No description provided for @sectionMyPresets.
  ///
  /// In en, this message translates to:
  /// **'My presets'**
  String get sectionMyPresets;

  /// No description provided for @sectionBuiltIn.
  ///
  /// In en, this message translates to:
  /// **'Standard tunings'**
  String get sectionBuiltIn;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @newPreset.
  ///
  /// In en, this message translates to:
  /// **'New preset'**
  String get newPreset;

  /// No description provided for @emptyCustom.
  ///
  /// In en, this message translates to:
  /// **'Create your first preset with the tuning you use — duplicate a standard tuning or capture your instrument\'s tuning in the tuner\'s chromatic mode.'**
  String get emptyCustom;

  /// No description provided for @emptyCustomFiltered.
  ///
  /// In en, this message translates to:
  /// **'No presets of yours for this instrument yet — create one with the button below or capture a tuning in the tuner\'s chromatic mode.'**
  String get emptyCustomFiltered;

  /// No description provided for @menuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get menuEdit;

  /// No description provided for @menuDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get menuDuplicate;

  /// No description provided for @menuDuplicateEdit.
  ///
  /// In en, this message translates to:
  /// **'Duplicate & edit'**
  String get menuDuplicateEdit;

  /// No description provided for @menuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get menuDelete;

  /// No description provided for @deleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete preset?'**
  String get deleteDialogTitle;

  /// No description provided for @deleteDialogBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be permanently removed.'**
  String deleteDialogBody(String name);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @editorTitleNew.
  ///
  /// In en, this message translates to:
  /// **'New preset'**
  String get editorTitleNew;

  /// No description provided for @editorTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit preset'**
  String get editorTitleEdit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @presetNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Preset name'**
  String get presetNameLabel;

  /// No description provided for @presetNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. My Drop B tuning'**
  String get presetNameHint;

  /// No description provided for @sectionInstrument.
  ///
  /// In en, this message translates to:
  /// **'Instrument'**
  String get sectionInstrument;

  /// No description provided for @sectionStrings.
  ///
  /// In en, this message translates to:
  /// **'Strings — lowest to highest'**
  String get sectionStrings;

  /// No description provided for @addString.
  ///
  /// In en, this message translates to:
  /// **'Add string'**
  String get addString;

  /// No description provided for @semitoneDown.
  ///
  /// In en, this message translates to:
  /// **'Half step down'**
  String get semitoneDown;

  /// No description provided for @semitoneUp.
  ///
  /// In en, this message translates to:
  /// **'Half step up'**
  String get semitoneUp;

  /// No description provided for @removeString.
  ///
  /// In en, this message translates to:
  /// **'Remove string'**
  String get removeString;

  /// No description provided for @errorPresetName.
  ///
  /// In en, this message translates to:
  /// **'Give the preset a name.'**
  String get errorPresetName;

  /// No description provided for @errorPresetStrings.
  ///
  /// In en, this message translates to:
  /// **'Add at least one string.'**
  String get errorPresetStrings;

  /// No description provided for @copyName.
  ///
  /// In en, this message translates to:
  /// **'{name} (copy)'**
  String copyName(String name);

  /// No description provided for @instrumentGuitar.
  ///
  /// In en, this message translates to:
  /// **'Guitar'**
  String get instrumentGuitar;

  /// No description provided for @instrumentBass.
  ///
  /// In en, this message translates to:
  /// **'Bass'**
  String get instrumentBass;

  /// No description provided for @instrumentUkulele.
  ///
  /// In en, this message translates to:
  /// **'Ukulele'**
  String get instrumentUkulele;

  /// No description provided for @instrumentCavaquinho.
  ///
  /// In en, this message translates to:
  /// **'Cavaquinho'**
  String get instrumentCavaquinho;

  /// No description provided for @instrumentOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get instrumentOther;

  /// No description provided for @presetStandardGuitar.
  ///
  /// In en, this message translates to:
  /// **'Standard (E A D G B E)'**
  String get presetStandardGuitar;

  /// No description provided for @presetDropC.
  ///
  /// In en, this message translates to:
  /// **'Drop C'**
  String get presetDropC;

  /// No description provided for @presetDropD.
  ///
  /// In en, this message translates to:
  /// **'Drop D'**
  String get presetDropD;

  /// No description provided for @presetHalfStepDown.
  ///
  /// In en, this message translates to:
  /// **'Half step down (Eb)'**
  String get presetHalfStepDown;

  /// No description provided for @presetDropCSharp.
  ///
  /// In en, this message translates to:
  /// **'Drop C#'**
  String get presetDropCSharp;

  /// No description provided for @presetDropB.
  ///
  /// In en, this message translates to:
  /// **'Drop B'**
  String get presetDropB;

  /// No description provided for @presetDropA.
  ///
  /// In en, this message translates to:
  /// **'Drop A'**
  String get presetDropA;

  /// No description provided for @presetOpenD.
  ///
  /// In en, this message translates to:
  /// **'Open D'**
  String get presetOpenD;

  /// No description provided for @presetDStandard.
  ///
  /// In en, this message translates to:
  /// **'Whole step down (D)'**
  String get presetDStandard;

  /// No description provided for @presetCStandard.
  ///
  /// In en, this message translates to:
  /// **'C standard'**
  String get presetCStandard;

  /// No description provided for @presetDadgad.
  ///
  /// In en, this message translates to:
  /// **'DADGAD'**
  String get presetDadgad;

  /// No description provided for @presetOpenG.
  ///
  /// In en, this message translates to:
  /// **'Open G'**
  String get presetOpenG;

  /// No description provided for @presetGuitar7.
  ///
  /// In en, this message translates to:
  /// **'7-string (B E A D G B E)'**
  String get presetGuitar7;

  /// No description provided for @presetBassStandard.
  ///
  /// In en, this message translates to:
  /// **'Bass – Standard (E A D G)'**
  String get presetBassStandard;

  /// No description provided for @presetBass5.
  ///
  /// In en, this message translates to:
  /// **'Bass – 5 strings'**
  String get presetBass5;

  /// No description provided for @presetUkulele.
  ///
  /// In en, this message translates to:
  /// **'Ukulele – Standard (G C E A)'**
  String get presetUkulele;

  /// No description provided for @presetCavaquinho.
  ///
  /// In en, this message translates to:
  /// **'Cavaquinho (D G B D)'**
  String get presetCavaquinho;

  /// No description provided for @presetMandolin.
  ///
  /// In en, this message translates to:
  /// **'Mandolin (G D A E)'**
  String get presetMandolin;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'it',
    'ja',
    'ko',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
