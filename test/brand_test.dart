import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lattos_tuner/views/l10n.dart';
import 'package:lattos_tuner/views/theme.dart';
import 'package:lattos_tuner/views/widgets/brand_intro.dart';
import 'package:lattos_tuner/views/widgets/brand_lockup.dart';

Widget wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

/// Imagens da marca só podem trazer o símbolo — o nome é montado em tela.
Finder markImage() => find.byWidgetPredicate(
  (widget) =>
      widget is Image &&
      widget.image is AssetImage &&
      (widget.image as AssetImage).assetName ==
          'assets/branding/logo_mark.png',
);

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  testWidgets('a marca combina símbolo em imagem e nome em texto', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const Center(child: BrandLockup())));

    expect(markImage(), findsOneWidget);
    expect(find.text(l10n.tunerTitle), findsOneWidget);
    expect(find.text(l10n.tagline), findsNothing);
  });

  testWidgets('a abertura mostra nome e assinatura e some sozinha', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const BrandIntro()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(markImage(), findsOneWidget);
    expect(find.text(l10n.tunerTitle), findsOneWidget);
    expect(find.text(l10n.tagline), findsOneWidget);
    // Fora do Scaffold, sem um Material acima o texto sai com o sublinhado
    // amarelo de depuração.
    expect(
      find.ancestor(
        of: find.text(l10n.tunerTitle),
        matching: find.byType(Material),
      ),
      findsWidgets,
    );

    // Some sozinha e não deixa nada cobrindo o afinador.
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text(l10n.tunerTitle), findsNothing);
    expect(markImage(), findsNothing);
  });
}
