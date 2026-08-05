import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:lattos_tuner/l10n/generated/app_localizations.dart';
import 'package:lattos_tuner/models/tuning_preset.dart';

export 'package:lattos_tuner/l10n/generated/app_localizations.dart';

/// Acesso curto às strings localizadas: `context.l10n.statusInTune`.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Rótulo localizado do instrumento.
extension InstrumentL10n on Instrument {
  String label(AppLocalizations l10n) => switch (this) {
    Instrument.guitar => l10n.instrumentGuitar,
    Instrument.bass => l10n.instrumentBass,
    Instrument.ukulele => l10n.instrumentUkulele,
    Instrument.cavaquinho => l10n.instrumentCavaquinho,
    Instrument.other => l10n.instrumentOther,
  };
}

/// Nome exibido de um preset: os embutidos são localizados pelo id; os
/// customizados usam o nome dado pelo usuário.
extension TuningPresetL10n on TuningPreset {
  String displayName(AppLocalizations l10n) => switch (id) {
    'builtin_guitar_standard' => l10n.presetStandardGuitar,
    'builtin_soad_drop_c' => l10n.presetDropC,
    'builtin_drop_d' => l10n.presetDropD,
    'builtin_half_step_down' => l10n.presetHalfStepDown,
    'builtin_drop_c_sharp' => l10n.presetDropCSharp,
    'builtin_drop_b' => l10n.presetDropB,
    'builtin_drop_a' => l10n.presetDropA,
    'builtin_d_standard' => l10n.presetDStandard,
    'builtin_c_standard' => l10n.presetCStandard,
    'builtin_dadgad' => l10n.presetDadgad,
    'builtin_open_g' => l10n.presetOpenG,
    'builtin_open_d' => l10n.presetOpenD,
    'builtin_guitar_7' => l10n.presetGuitar7,
    'builtin_bass_standard' => l10n.presetBassStandard,
    'builtin_bass_5_strings' => l10n.presetBass5,
    'builtin_ukulele' => l10n.presetUkulele,
    'builtin_cavaquinho' => l10n.presetCavaquinho,
    'builtin_mandolin' => l10n.presetMandolin,
    _ => name,
  };
}

/// Formata um número decimal com o separador (e os dígitos) do idioma atual.
String formatDecimal(double value, Locale locale, {int decimals = 1}) =>
    NumberFormat.decimalPatternDigits(
      locale: locale.toString(),
      decimalDigits: decimals,
    ).format(value);
