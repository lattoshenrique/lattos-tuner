import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:lattos_tuner/models/tuning_preset.dart';
import 'package:lattos_tuner/services/preset_repository.dart';
import 'package:lattos_tuner/views/l10n.dart';

void main() {
  const expectedLocales = [
    'en',
    'pt',
    'es',
    'fr',
    'de',
    'it',
    'ja',
    'zh',
    'ko',
    'ru',
    'hi',
    'ar',
  ];

  test('suporta os principais idiomas do mundo', () {
    final supported = AppLocalizations.supportedLocales
        .map((locale) => locale.languageCode)
        .toSet();
    for (final code in expectedLocales) {
      expect(supported, contains(code), reason: 'faltou o idioma $code');
    }
  });

  test('todas as traduções resolvem as strings principais', () {
    for (final code in expectedLocales) {
      final l10n = lookupAppLocalizations(Locale(code));
      for (final value in [
        l10n.statusInTune,
        l10n.statusTooLow,
        l10n.statusTooHigh,
        l10n.captureSave,
        l10n.presetsTitle,
        l10n.newPreset,
        l10n.permissionBody,
        l10n.calibrationTitle,
      ]) {
        expect(value.trim(), isNotEmpty, reason: 'string vazia em $code');
      }
      expect(
        l10n.calibrationTooltip(440),
        contains('440'),
        reason: 'placeholder não interpolado em $code',
      );
      expect(
        l10n.deleteDialogBody('Drop Z'),
        contains('Drop Z'),
        reason: 'placeholder não interpolado em $code',
      );
    }
  });

  test('amostras de tradução por idioma', () {
    expect(lookupAppLocalizations(const Locale('pt')).statusInTune, 'Afinado!');
    expect(lookupAppLocalizations(const Locale('en')).statusInTune, 'In tune!');
    expect(
      lookupAppLocalizations(const Locale('de')).statusInTune,
      'Gestimmt!',
    );
    expect(lookupAppLocalizations(const Locale('ja')).modeChromatic, 'クロマチック');
  });

  test('presets embutidos têm nome localizado em todos os idiomas', () {
    for (final code in expectedLocales) {
      final l10n = lookupAppLocalizations(Locale(code));
      for (final preset in PresetRepository.builtInPresets) {
        final display = preset.displayName(l10n);
        expect(
          display.trim(),
          isNotEmpty,
          reason: '${preset.id} sem nome em $code',
        );
        // Nenhum embutido deve cair no fallback do switch (nome cru).
        expect(
          display,
          isNot(equals('')),
          reason: '${preset.id} sem tradução em $code',
        );
      }
    }
  });

  test('preset customizado usa o nome dado pelo usuário', () {
    const custom = TuningPreset(
      id: 'custom_1',
      name: 'Minha afinação',
      instrument: Instrument.guitar,
      notes: ['E2'],
    );
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(custom.displayName(l10n), 'Minha afinação');
  });

  test('formatDecimal usa o separador do idioma', () {
    expect(formatDecimal(82.41, const Locale('en')), '82.4');
    expect(formatDecimal(82.41, const Locale('pt')), '82,4');
    expect(formatDecimal(82.41, const Locale('de')), '82,4');
  });

  test('rótulos de instrumento são localizados', () {
    final pt = lookupAppLocalizations(const Locale('pt'));
    final en = lookupAppLocalizations(const Locale('en'));
    expect(Instrument.guitar.label(pt), 'Guitarra/Violão');
    expect(Instrument.guitar.label(en), 'Guitar');
    for (final instrument in Instrument.values) {
      expect(instrument.label(en).trim(), isNotEmpty);
    }
  });
}
