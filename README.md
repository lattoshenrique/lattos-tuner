# Lattos Tuner 🎸

Afinador cromático em Flutter com **presets de afinação salvos** — incluindo a
afinação **SOAD (Drop C)** — para afinar guitarra, violão, baixo, ukulele,
cavaquinho e o que mais você inventar.

## Funcionalidades

- **Detecção de pitch em tempo real** pelo microfone, usando o algoritmo
  **YIN** implementado em Dart puro (sem dependência de DSP externa), com
  suavização por mediana e gate de silêncio.
- **Presets de afinação**:
  - Embutidos: Padrão (E A D G B E), **SOAD – Drop C (C G C F A D)**, Drop D,
    Meio tom abaixo (Eb), Drop C#, DADGAD, Open G, Baixo 4 e 5 cordas,
    Ukulele e Cavaquinho.
  - **Customizados**: crie, edite, duplique e exclua presets seus — salvos no
    aparelho e mantidos entre sessões.
- **Modos de alvo**:
  - *Auto*: detecta a corda do preset mais próxima do som tocado.
  - *Manual*: toque em uma corda para travá-la como alvo.
  - *Cromático*: afina para a nota mais próxima, sem preset.
- **Acompanhamento por corda**: cada corda ganha um ✓ quando afinada; o app
  celebra quando o instrumento inteiro está pronto.
- **Calibração do A4** (415–466 Hz, padrão 440 Hz).
- **UI moderna**: tema escuro com gradiente que reage ao estado da afinação,
  medidor com ponteiro e escala que "acende", animações de transição
  (fade-through, stagger), haptics e Material 3.

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
