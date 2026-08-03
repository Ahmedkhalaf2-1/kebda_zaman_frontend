import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kebda_zaman/features/customer/presentation/notifiers/cart_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/screens/cart_screen.dart';
import 'package:kebda_zaman/features/shared/domain/models/cart.dart';
import 'package:kebda_zaman/generated/codegen_loader.g.dart';

/// Focused tests proving the Cart screen no longer shows the previous
/// hardcoded "Mint Lemonade" / "Lava Cake" / "Crispy Fries" recommendations,
/// and that the recommendations section is hidden entirely rather than
/// backed by a random/featured/popular fallback (no real recommendation
/// source exists for Cart).
CartItem _item(String id) => CartItem(
  id: id,
  menuItemId: 'mi_$id',
  productName: 'Kebda Sandwich $id',
  productImage: '',
  basePrice: 45.5,
  quantity: 1,
  selectedOptions: const {},
  extraQuantities: const {},
  unitPrice: 45.5,
  lineTotal: 45.5,
);

Cart _cart({List<CartItem>? items}) => Cart(
  id: 'cart1',
  items: items ?? [_item('i1')],
  deliveryFee: 20,
  subtotal: 45.5,
  grandTotal: 65.5,
);

class _FixedCartNotifier extends CartNotifier {
  final Cart? data;
  _FixedCartNotifier(this.data);

  @override
  Future<Cart?> build() async => data;
}

Future<void> _pump(WidgetTester tester, Cart? cart) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [cartProvider.overrideWith(() => _FixedCartNotifier(cart))],
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
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('fake recommendation products are not shown', (tester) async {
    await _pump(tester, _cart());

    expect(tester.takeException(), isNull);
    expect(find.text('Mint Lemonade'), findsNothing);
    expect(find.text('Lava Cake'), findsNothing);
    expect(find.text('Crispy Fries'), findsNothing);
  });

  testWidgets(
    'recommendations section is hidden entirely (no real source exists)',
    (tester) async {
      await _pump(tester, _cart());

      expect(tester.takeException(), isNull);
      expect(find.text('cart.often_ordered_with'.tr()), findsNothing);
      expect(find.text('home.view_all'.tr()), findsNothing);
    },
  );

  testWidgets('recommendations section stays hidden for an empty cart too', (
    tester,
  ) async {
    await _pump(tester, _cart(items: []));

    expect(tester.takeException(), isNull);
    expect(find.text('Mint Lemonade'), findsNothing);
  });

  testWidgets('cart items themselves still render normally', (tester) async {
    await _pump(tester, _cart());

    expect(tester.takeException(), isNull);
    expect(find.text('Kebda Sandwich i1'), findsOneWidget);
  });
}
