# Lattos Tuner 🎸

Afinador cromático em Flutter com **presets de afinação salvos** — incluindo a
afinação **SOAD (Drop C)** — para afinar guitarra, violão, baixo, ukulele,
cavaquinho e o que mais você inventar.

## Funcionalidades

- **Detecção de pitch em tempo real** pelo microfone, usando o algoritmo
  **YIN** implementado em Dart puro (sem dependência de DSP externa), com
  suavização por mediana e gate de silêncio.
- **Detecção inteligente de corda**: perto do alvo vale a proximidade; na
  zona ambígua entre duas cordas, a direção do movimento (apertando ou
  soltando a tarraxa) e o alvo anterior decidem — ao descer do padrão para
  o SOAD (Drop C), o E2 solto mira **C2** e pede para *soltar*, não G2.
- **Presets de afinação**:
  - Embutidos: Padrão (E A D G B E), **SOAD – Drop C (C G C F A D)**, Drop D,
    Meio tom abaixo (Eb), Drop C#, DADGAD, Open G, Baixo 4 e 5 cordas,
    Ukulele e Cavaquinho.
  - **Customizados**: crie, edite, duplique e exclua presets seus — salvos no
    aparelho e mantidos entre sessões — com escolha de instrumento.
  - **Captura pelo afinador**: no modo cromático, cada nota estável entra na
    lista de captura; salve como preset direto da tela do afinador, e ele já
    vira o preset ativo.
  - **Filtro por instrumento** na lista de afinações (guitarra/violão,
    baixo, ukulele, cavaquinho…).
- **Modos de alvo**:
  - *Auto*: detecta a corda do preset mais próxima do som tocado.
  - *Manual*: toque em uma corda para travá-la como alvo.
  - *Cromático*: afina para a nota mais próxima, sem preset.
- **Acompanhamento por corda**: cada corda ganha um ✓ quando afinada; o app
  celebra com confetes quando o instrumento inteiro está pronto.
- **Tela sempre acesa** enquanto o afinador está em primeiro plano
  (wakelock).
- **Calibração do A4** (415–466 Hz, padrão 440 Hz).
- **i18n com detecção automática de idioma** (padrão `flutter_localizations`
  + ARB): inglês, português, espanhol, francês, alemão, italiano, japonês,
  chinês, coreano, russo, hindi e árabe (com RTL). O idioma do aparelho é
  detectado automaticamente; inglês é o fallback. Números (Hz/cents) usam o
  separador decimal — e os dígitos — do idioma ativo.
- **UI moderna**: tema escuro com fundo "aurora" animado que reage ao estado
  da afinação, medidor com ponteiro e escala que "acende", transições
  Material Motion (fade-through e shared-axis), efeitos Hero, entrada
  escalonada, haptics e Material 3.

## Como rodar

```bash
flutter pub get
flutter run
```

Requisitos: Flutter 3.32+. Android minSdk 23; iOS com permissão de microfone
(já declarada no `Info.plist`).

## Testes

```bash
flutter test
```

A suíte cobre a matemática de notas (MIDI ↔ Hz ↔ cents), o detector YIN com
senoides sintetizadas (precisão < 2 cents), o parsing de PCM16 em chunks
irregulares, a persistência de presets e a lógica do afinador (seleção de
corda, status, calibração).

## Arquitetura (MVC)

```
lib/
├── l10n/                          # traduções ARB (12 idiomas) + código gerado
├── models/                        # M — dados e regras de domínio
│   ├── note.dart                  #   conversões MIDI/Hz/cents e nomes de notas
│   ├── pitch_estimate.dart        #   estimativa de pitch (Hz + confiança)
│   ├── tuner_reading.dart         #   leitura do afinador, status e modo de alvo
│   └── tuning_preset.dart         #   preset de afinação (+ JSON)
├── views/                         # V — apresentação (observa o controller)
│   ├── theme.dart                 #   paleta, tema Material 3 e transições
│   ├── screens/                   #   afinador, lista de presets, editor
│   └── widgets/                   #   gauge, display de nota, chips de cordas
├── controllers/                   # C — orquestração e estado observável
│   └── tuner_controller.dart      #   ChangeNotifier: pitch → leitura → UI
└── services/                      # infraestrutura usada pelo controller
    ├── audio/
    │   ├── yin_pitch_detector.dart    # YIN puro em Dart
    │   └── tuner_audio_service.dart   # microfone → PCM16 → decimação → pitch
    └── preset_repository.dart         # presets embutidos + persistência local
```

Fluxo: `View → Controller → Service/Model`, com a View reagindo ao
`ChangeNotifier` do Controller e os tipos de estado vivendo em `models/`.

## VS Code

O projeto inclui `.vscode/launch.json` com quatro configurações: **debug**,
**profile**, **release** e **testes** (F5 para rodar, ou o painel
*Run and Debug*).
