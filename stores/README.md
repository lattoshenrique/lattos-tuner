# Mídia das lojas — NoAd Tuner

Tudo aqui é gerado a partir do app de verdade, nos pixels exatos que cada loja
pede. Nada foi esticado: onde a resolução do aparelho difere da exigida, a
imagem é reamostrada mantendo a proporção.

## Especificações seguidas

- **App Store Connect** — [Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/)
- **Google Play** — [Gráficos, capturas de tela e vídeos](https://support.google.com/googleplay/android-developer/answer/9866151)

## Apple

| Pasta | Pixels | Situação |
|---|---|---|
| `apple/iphone-6.9/` | 1260 × 2736 | **Obrigatório** (app roda em iPhone) |
| `apple/iphone-6.5/` | 1284 × 2778 | Aceito no lugar do 6.9" |
| `apple/ipad-13/` | 2064 × 2752 | **Obrigatório** (o alvo é iPhone + iPad, `TARGETED_DEVICE_FAMILY = "1,2"`) |
| `apple/icon/AppIcon-1024.png` | 1024 × 1024 | Ícone da listagem, PNG **sem canal alfa** |

São 5 capturas por tamanho (o limite é 10). As do iPhone saíram do simulador
iPhone 17 Pro Max (1320 × 2868) e foram reamostradas para os pixels da ficha
técnica; as do iPad saíram do iPad Pro 13" (M5), que já grava exatamente
2064 × 2752.

## Google Play

| Arquivo/pasta | Pixels | Situação |
|---|---|---|
| `google/icon/icon-512.png` | 512 × 512 | **Obrigatório**, PNG 32 bits com alfa |
| `google/feature-graphic-1024x500.png` | 1024 × 500 | **Obrigatório** |
| `google/phone/` | 1080 × 1920 (9:16) | **Obrigatório**: mínimo 2, aqui 5 |
| `google/tablet-7/` | 1080 × 1920 (9:16) | Recomendado: 4 no mínimo |
| `google/tablet-10/` | 1440 × 2560 (9:16) | Recomendado: 4 no mínimo |

O Play exige 16:9 ou 9:16 e limita a maior dimensão ao dobro da menor — a
proporção do celular moderno (9:19,5) não passa nessa regra. Por isso as
imagens do Play são renderizadas pelo app na proporção 9:16, e não recortadas
de uma captura de celular.

## As telas

| Arquivo | O que mostra |
|---|---|
| `01-tuning` | Corda fora de tom: ponteiro na zona vermelha, fundo reagindo à nota |
| `02-in-tune` | Corda afinada: faixa central acesa, corda marcada, fundo em menta |
| `03-free-mode` | Modo livre, sem preset, com as notas capturadas virando afinação |
| `04-presets` | Biblioteca de afinações |
| `05-calibration` | Calibração do A4 e o interruptor da vibração guia |

## Como refazer

**Tamanhos do Google** (renderiza as telas reais nos pixels pedidos):

```sh
flutter test test/store_shots.dart
```

**Tamanhos da Apple** (captura no simulador, com o app percorrendo as telas):

```sh
# o roteiro só liga com a chave, e força o idioma inglês
flutter run --dart-define=SHOTS=true -d "iPhone 17 Pro Max"
# capture com: xcrun simctl io booted screenshot arquivo.png
# e reamostre: sips -z 2736 1260 arquivo.png --out destino.png
```

O roteiro (`SHOTS`) vive em `lib/main.dart`: ele troca para o modo livre, abre
a biblioteca e a folha de calibração em intervalos fixos, para a captura não
depender de toque manual.

## Ainda falta (texto, não mídia)

Nome, descrição curta (80 caracteres no Play), descrição completa, palavras-
chave (100 caracteres na Apple), classificação etária, política de privacidade
e a URL de suporte. O app não coleta dados: o áudio é analisado no aparelho e
nada sai dele — vale dizer isso na ficha de privacidade das duas lojas.
