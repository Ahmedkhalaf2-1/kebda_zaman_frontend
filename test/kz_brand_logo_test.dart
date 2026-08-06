import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:kebda_zaman/core/widgets/kz_brand_logo.dart';
import 'package:kebda_zaman/generated/codegen_loader.g.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
  double width = 375,
}) async {
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: locale,
      useOnlyLangCode: true,
      saveLocale: false,
      assetLoader: const CodegenLoader(),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: Scaffold(
              body: Center(
                child: SizedBox(width: width, child: child),
              ),
            ),
          );
        },
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

void main() {
  testWidgets('renders the logo asset without throwing', (tester) async {
    await _pump(tester, const KZBrandLogo(width: 72, height: 72));

    expect(tester.takeException(), isNull);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('uses BoxFit.contain and the given width/height', (tester) async {
    await _pump(tester, const KZBrandLogo(width: 60, height: 40));

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.fit, BoxFit.contain);
    expect(image.width, 60);
    expect(image.height, 40);
  });

  testWidgets('defaults the semantic label to the localized app name (EN)', (
    tester,
  ) async {
    await _pump(tester, const KZBrandLogo(width: 40, height: 40));

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.semanticLabel, 'Kebda Zaman');
  });

  testWidgets('defaults the semantic label to the localized app name (AR)', (
    tester,
  ) async {
    await _pump(
      tester,
      const KZBrandLogo(width: 40, height: 40),
      locale: const Locale('ar'),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.semanticLabel, 'كبدة زمان');
  });

  testWidgets('an explicit semanticLabel overrides the default', (
    tester,
  ) async {
    await _pump(
      tester,
      const KZBrandLogo(width: 40, height: 40, semanticLabel: 'Custom label'),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.semanticLabel, 'Custom label');
  });

  testWidgets('renders without a container by default (no background)', (
    tester,
  ) async {
    await _pump(tester, const KZBrandLogo(width: 40, height: 40));

    expect(find.byType(Container), findsNothing);
  });

  testWidgets('circular:true with a backgroundColor wraps in a circle', (
    tester,
  ) async {
    await _pump(
      tester,
      const KZBrandLogo(
        width: 40,
        height: 40,
        backgroundColor: Colors.white,
        circular: true,
      ),
    );

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.shape, BoxShape.circle);
    expect(decoration.color, Colors.white);
  });

  testWidgets('fits inside a narrow phone width without overflow', (
    tester,
  ) async {
    await _pump(tester, const KZBrandLogo(width: 72, height: 72), width: 320);

    expect(tester.takeException(), isNull);
  });
}
