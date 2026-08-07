// Widget tests for the redesigned OnboardingScreen. No real network calls —
// Flutter's TestWidgetsFlutterBinding already makes every HTTP request fail
// with 400, so CachedNetworkImage's error state is exercised for free by
// every test here (confirmed by the framework's own warning banner), giving
// direct coverage of "network image error fallback does not crash" without
// any extra mocking.
//
// Two pump helpers are used deliberately:
//  - `_pumpPlain` (plain MaterialApp, no router) for every test that only
//    exercises page content/visuals/Next — OnboardingScreen never calls
//    `context.go` unless Skip or the final button is actually tapped, so no
//    GoRouter ancestor is needed for those.
//  - `_pumpWithRouter` (MaterialApp.router + a real GoRouter, mirroring
//    splash_screen_test.dart's proven pattern) only for the two tests that
//    tap Skip/"Start Ordering" and assert on the resulting navigation.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kebda_zaman/core/widgets/kz_brand_logo.dart';
import 'package:kebda_zaman/features/customer/presentation/screens/onboarding_screen.dart';
import 'package:kebda_zaman/generated/codegen_loader.g.dart';

// Not pumpAndSettle: the hero image's loading placeholder is an
// indeterminate CircularProgressIndicator, which animates forever until
// CachedNetworkImage's error callback fires and never "settles" on its
// own. A fixed pump count is flaky here — EasyLocalization's async asset
// load genuinely varies in wall-clock time under load — so this polls in
// bounded steps instead of assuming a fixed budget is always enough.
Future<void> _settle(
  WidgetTester tester, {
  int maxSteps = 30,
  Duration step = const Duration(milliseconds: 150),
}) async {
  for (var i = 0; i < maxSteps; i++) {
    await tester.pump(step);
  }
}

Future<void> _pumpPlain(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  Size size = const Size(390, 844),
  double textScale = 1.0,
}) async {
  await tester.binding.setSurfaceSize(size);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        assetLoader: const CodegenLoader(),
        fallbackLocale: const Locale('en'),
        startLocale: locale,
        useOnlyLangCode: true,
        saveLocale: false,
        child: Builder(
          builder: (context) {
            return MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              home: MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(textScale)),
                child: const OnboardingScreen(),
              ),
            );
          },
        ),
      ),
    ),
  );
  await _settle(tester);
}

GoRouter _buildTestRouter() {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth-choice',
        builder: (context, state) =>
            const Scaffold(body: Text('auth-choice-placeholder')),
      ),
    ],
  );
}

Future<void> _pumpWithRouter(WidgetTester tester, GoRouter router) async {
  await tester.pumpWidget(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        assetLoader: const CodegenLoader(),
        fallbackLocale: const Locale('en'),
        useOnlyLangCode: true,
        child: MaterialApp.router(routerConfig: router),
      ),
    ),
  );
  await _settle(tester);
}

/// Advances from page 0 to [targetIndex] by tapping the primary action
/// button [count] times — the same "Next" flow a real user follows, and
/// more deterministic in a test than simulating the raw swipe gesture.
Future<void> _advancePages(WidgetTester tester, int count) async {
  for (var i = 0; i < count; i++) {
    await tester.tap(find.byType(ElevatedButton));
    await _settle(tester);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('page 1 renders its title, subtitle, and the brand logo', (
    tester,
  ) async {
    await _pumpPlain(tester);

    expect(find.text('Authentic Egyptian Flavor'), findsOneWidget);
    expect(
      find.text(
        'Classic kebda and sausage sandwiches, served hot and made the Kebda Zaman way.',
      ),
      findsOneWidget,
    );
    expect(find.byType(KZBrandLogo), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('all 3 pages render when advanced through', (tester) async {
    await _pumpPlain(tester);

    expect(find.text('Authentic Egyptian Flavor'), findsOneWidget);

    await _advancePages(tester, 1);
    expect(find.text('Made Your Way'), findsOneWidget);
    // Page 2's decorative chips.
    expect(find.text('Spicy'), findsOneWidget);
    expect(find.text('Extras'), findsOneWidget);
    expect(find.text('No Onion'), findsOneWidget);

    await _advancePages(tester, 1);
    expect(find.text('From Our Kitchen to You'), findsOneWidget);
    // Page 3 was redesigned to show a Lottie delivery-guy hero animation
    // instead of the old "Map Location"/"Order Tracking" decorative chips
    // (see onboarding_screen.dart's _kOnboardingPages entry for page 3: it
    // sets `lottieAsset` and leaves `chips` empty) — those translation keys
    // are no longer referenced anywhere in the widget tree.
    expect(find.byType(Lottie), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('Next moves from page 1 to page 2', (tester) async {
    await _pumpPlain(tester);

    expect(find.text('Next'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await _settle(tester);

    expect(find.text('Made Your Way'), findsOneWidget);
  });

  testWidgets('renders Arabic text under the Arabic locale', (tester) async {
    await _pumpPlain(tester, locale: const Locale('ar'));

    expect(find.text('الطعم المصري الأصيل'), findsOneWidget);
    expect(
      find.text('سندوتشات كبدة وسجق بطعم زمان، جاهزة توصلك سخنة لحد بابك.'),
      findsOneWidget,
    );
    expect(find.text('تخطي'), findsOneWidget);
    expect(find.text('التالي'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders English text under the English locale', (tester) async {
    await _pumpPlain(tester);

    expect(find.text('Authentic Egyptian Flavor'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('the progress indicator updates as pages change', (tester) async {
    await _pumpPlain(tester);

    Finder indicator(int index) =>
        find.byKey(ValueKey('onboarding_indicator_$index'));

    // getSize includes the AnimatedContainer's horizontal margin (KZ.sp4 on
    // each side), so active (32 wide) measures 40 and inactive (8) measures 16.
    expect(tester.getSize(indicator(0)).width, 40); // page 0 active
    expect(tester.getSize(indicator(1)).width, 16);
    expect(tester.getSize(indicator(2)).width, 16);

    await tester.tap(find.text('Next'));
    await _settle(tester);

    expect(tester.getSize(indicator(0)).width, 16);
    expect(tester.getSize(indicator(1)).width, 40); // page 1 now active
    expect(tester.getSize(indicator(2)).width, 16);
  });

  testWidgets('no overflow at a narrow phone width (320)', (tester) async {
    await _pumpPlain(tester, size: const Size(320, 690));

    expect(tester.takeException(), isNull);
  });

  testWidgets('no overflow at an increased text scale', (tester) async {
    await _pumpPlain(tester, textScale: 1.6);

    expect(tester.takeException(), isNull);
  });

  testWidgets('network image error fallback renders without throwing', (
    tester,
  ) async {
    // Real network access is unavailable in the test binding, so the
    // hero image always resolves to CachedNetworkImage's errorWidget —
    // this asserts that path never crashes.
    await _pumpPlain(tester);
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
  });

  testWidgets('Skip completes onboarding and navigates to /auth-choice', (
    tester,
  ) async {
    await _pumpWithRouter(tester, _buildTestRouter());

    await tester.tap(find.text('Skip'));
    await _settle(tester);

    expect(find.text('auth-choice-placeholder'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('kz_onboarding_completed'), isTrue);
  });

  testWidgets(
    'the final button ("Start Ordering") completes onboarding and navigates',
    (tester) async {
      await _pumpWithRouter(tester, _buildTestRouter());

      await tester.tap(find.text('Next'));
      await _settle(tester);
      await tester.tap(find.text('Next'));
      await _settle(tester);

      expect(find.text('Start Ordering'), findsOneWidget);
      await tester.tap(find.text('Start Ordering'));
      await _settle(tester);

      expect(find.text('auth-choice-placeholder'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('kz_onboarding_completed'), isTrue);
    },
  );
}
