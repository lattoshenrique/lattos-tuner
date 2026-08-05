# Forever Tuner 🎸

> **Tune freely. No ads. Ever.**

Afinador cromático em Flutter com **presets de afinação salvos** — incluindo a
afinação **SOAD (Drop C)** — para afinar guitarra, violão, baixo, ukulele,
cavaquinho e o que mais você inventar.

## Funcionalidades

- **Detecção de pitch em tempo real** pelo microfone, usando o algoritmo
  **YIN** implementado em Dart puro (sem dependência de DSP externa), com
  mediana ponderada por confiança e gate de silêncio adaptativo.
- **Robusto a microfones ruins de celular**:
  - Captura com `VOICE_RECOGNITION` no Android (sem AGC/supressão de ruído
    da fonte padrão) e flags de processamento desligados.
  - Passa-altas de ~20 Hz contra rumble e offset DC.
  - **Guarda de erro de oitava**: quando o mic corta o fundamental grave e o
    2º harmônico domina, o detector reconhece o período dobrado.
  - Gate de silêncio adaptativo ao piso de ruído do ambiente — mics pouco
    sensíveis não ficam "surdos", ambientes barulhentos não alucinam nota.
- **Fácil de cravar a afinação**: o ponteiro percorre uma fração da
  diferença por leitura (calmo perto do alvo, instantâneo em mudanças
  grandes), com **histerese** no estado afinado (entra a ±6 cents, só sai
  acima de ±10) e zonas de tolerância visíveis no medidor (menta = afinado,
  âmbar = quase lá).
- **Calibração em duas vias**:
  - Ajuste manual do A4 (415–466 Hz) com **passo fino de 0,1 Hz** e desvio
    equivalente em cents.
  - **Calibração por tom de referência**: toque um diapasão/piano/outro
    afinador perto do aparelho; o app mede o desvio e corrige a referência
    com um toque.
- **Detecção inteligente de corda**: perto do alvo vale a proximidade; na
  zona ambígua entre duas cordas, a direção do movimento (apertando ou
  soltando a tarraxa) e o alvo anterior decidem — ao descer do padrão para
  o SOAD (Drop C), o E2 solto mira **C2** e pede para *soltar*, não G2.
- **Presets de afinação**:
  - Embutidos: Padrão (E A D G B E), **Drop C (C G C F A D)**, Drop D,
    Drop C#, Drop B, Drop A, Meio tom abaixo (Eb), Um tom abaixo (D),
    Padrão em C, DADGAD, Open G, Open D, Guitarra 7 cordas, Baixo 4 e 5
    cordas, Ukulele, Cavaquinho e Bandolim.
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
- **Identidade visual completa**: logo oficial (palheta + medidor) com
  degradê menta→violeta e efeito neon — no app bar, no ícone de launcher
  (incluindo adaptive icon Android e monocromático) e na splash screen
  nativa (Android 12+ e iOS), gerados a partir de `assets/branding/` —
  recrie com `dart run flutter_launcher_icons` e
  `dart run flutter_native_splash:create --path=flutter_native_splash.yaml`.
- **Tipografia da marca**: [Poppins](https://fonts.google.com/specimen/Poppins)
  (Google Fonts, licença OFL) embarcada em `assets/fonts/` — funciona
  offline, sem download em tempo de execução.

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
