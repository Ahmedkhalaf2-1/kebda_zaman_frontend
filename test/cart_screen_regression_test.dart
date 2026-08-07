import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kebda_zaman/features/customer/presentation/notifiers/cart_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/screens/cart_screen.dart';
import 'package:kebda_zaman/features/shared/domain/models/cart.dart';
import 'package:kebda_zaman/generated/codegen_loader.g.dart';

CartItem _item(String id, {String? specialInstructions, String? longName}) =>
    CartItem(
      id: id,
      menuItemId: 'mi_$id',
      productName:
          longName ??
          'Alexandrian Kebda Sandwich $id — Extra Long Product Name',
      productImage: '',
      basePrice: 45.5,
      quantity: 2,
      selectedOptions: const {},
      extraQuantities: const {},
      specialInstructions: specialInstructions ?? '',
      unitPrice: 45.5,
      lineTotal: 91.0,
    );

Cart _cart({
  List<CartItem>? items,
  String? promoCodeId,
  double discountTotal = 0,
  double taxTotal = 0,
}) => Cart(
  id: 'cart1',
  items:
      items ??
      [
        _item('i1'),
        _item('i2', specialInstructions: 'No onions, extra spicy please'),
      ],
  promoCodeId: promoCodeId,
  deliveryFee: 20,
  subtotal: 182,
  discountTotal: discountTotal,
  taxTotal: taxTotal,
  grandTotal: 182 + 20 - discountTotal + taxTotal,
);

// Not pumpAndSettle: the empty-cart state renders a repeating Lottie
// animation (KZEmptyState's `shopping_loader` asset), which by design never
// stops — pumpAndSettle waits for all animations to finish and times out.
// A bounded pump loop instead gives async provider/localization work enough
// frames to settle without waiting on an animation that runs forever.
Future<void> _settle(
  WidgetTester tester, {
  int maxSteps = 20,
  Duration step = const Duration(milliseconds: 100),
}) async {
  for (var i = 0; i < maxSteps; i++) {
    await tester.pump(step);
  }
}

Future<void> _pump(WidgetTester tester, List<Override> overrides) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        useOnlyLangCode: true,
        assetLoader: const CodegenLoader(),
        child: const MaterialApp(home: CartScreen()),
      ),
    ),
  );
}

class _FixedCartNotifier extends CartNotifier {
  final Cart? data;
  _FixedCartNotifier(this.data);

  @override
  Future<Cart?> build() async => data;
}

class _FailingCartNotifier extends CartNotifier {
  @override
  Future<Cart?> build() async => throw Exception('simulated cart API failure');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Future<void> setViewport(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  for (final entry in {
    'mobile 320 (320x690)': const Size(320, 690),
    'mobile 360 (360x800)': const Size(360, 800),
    'mobile 375 (375x812)': const Size(375, 812),
    'mobile 390 (390x844)': const Size(390, 844),
    'mobile 430 (430x932)': const Size(430, 932),
    'tablet (800x1024)': const Size(800, 1024),
    'desktop (1440x900)': const Size(1440, 900),
  }.entries) {
    testWidgets(
      'renders without exceptions on ${entry.key} — populated cart with '
      'discount, tax, promo and long item names',
      (tester) async {
        await setViewport(tester, entry.value);

        final overrides = [
          cartProvider.overrideWith(
            () => _FixedCartNotifier(
              _cart(promoCodeId: 'KEBDA20', discountTotal: 15, taxTotal: 8),
            ),
          ),
        ];

        await _pump(tester, overrides);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(CartScreen), findsOneWidget);
      },
    );
  }

  testWidgets('renders without exceptions: empty cart', (tester) async {
    await setViewport(tester, const Size(375, 812));

    final overrides = [
      cartProvider.overrideWith(() => _FixedCartNotifier(_cart(items: []))),
    ];

    await _pump(tester, overrides);
    await _settle(tester);

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without exceptions: null cart', (tester) async {
    await setViewport(tester, const Size(375, 812));

    final overrides = [
      cartProvider.overrideWith(() => _FixedCartNotifier(null)),
    ];

    await _pump(tester, overrides);
    await _settle(tester);

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without exceptions: cartProvider errors', (
    tester,
  ) async {
    await setViewport(tester, const Size(375, 812));

    final overrides = [cartProvider.overrideWith(() => _FailingCartNotifier())];

    await _pump(tester, overrides);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  // The promo code field no longer has a collapsed/expand-on-tap state (see
  // cart_screen.dart's _buildPromoSection — it's an unconditional TextField
  // whenever no promo is applied; the old `Icons.sell_rounded` expand
  // trigger this test used to tap was removed in an earlier UI change).
  // This just confirms the field renders without exceptions.
  testWidgets('promo code field renders without exceptions', (tester) async {
    await setViewport(tester, const Size(375, 812));

    final overrides = [
      cartProvider.overrideWith(() => _FixedCartNotifier(_cart())),
    ];

    await _pump(tester, overrides);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(TextField), findsOneWidget);
  });
}
