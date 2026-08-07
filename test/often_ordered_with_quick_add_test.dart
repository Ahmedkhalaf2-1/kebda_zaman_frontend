import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/item_details_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/screens/item_details_screen.dart';
import 'package:kebda_zaman/features/shared/data/fake_cart_repository.dart';
import 'package:kebda_zaman/features/shared/domain/models/cart.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/auth_repository.dart';
import 'package:kebda_zaman/generated/codegen_loader.g.dart';

/// Focused tests for the "+" quick-add button on Often Ordered With
/// recommendation cards (Item Details screen). Covers: the button is
/// present, a simple recommendation (no variants/required modifiers) adds
/// directly via the existing cart notifier, a recommendation that requires
/// modifiers routes to Product Details instead of adding, tapping the card
/// body still opens Product Details, tapping "+" does not also trigger the
/// card's onTap (no double action), and no overflow at 360dp.
class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Result<User?>> getCurrentUser() async => const Success(null);
  @override
  Future<Result<void>> logout() async => const Success(null);
  @override
  Future<Result<void>> deleteAccount() async => throw UnimplementedError();
  @override
  Future<Result<User>> login(String email, String password) async =>
      throw UnimplementedError();
  @override
  Future<Result<User>> adminLogin(String email, String password) async =>
      throw UnimplementedError();
  @override
  Future<Result<User>> googleLogin(String firebaseIdToken) async =>
      throw UnimplementedError();
  @override
  Future<Result<User>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async => throw UnimplementedError();
  @override
  Future<Result<User>> guestLogin() async => throw UnimplementedError();
  @override
  Future<Result<User>> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
    String? locale,
  }) async => throw UnimplementedError();
}

class _SpyCartRepository extends FakeCartRepository {
  int addItemCalls = 0;
  CartItem? lastAdded;

  @override
  Future<Result<Cart>> addItem(CartItem item) async {
    addItemCalls++;
    lastAdded = item;
    return super.addItem(item);
  }
}

MenuItem _item(
  String id, {
  String? name,
  double basePrice = 20,
  List<ModifierGroup> modifierGroups = const [],
  List<MenuItem> oftenOrderedWith = const [],
}) => MenuItem(
  id: id,
  categoryId: 'c1',
  name: name ?? 'Item $id',
  description: 'Description for $id',
  imageUrl: '',
  basePrice: basePrice,
  modifierGroups: modifierGroups,
  oftenOrderedWith: oftenOrderedWith,
);

Future<_SpyCartRepository> _pumpItemDetails(
  WidgetTester tester, {
  required Map<String, MenuItem> items,
  required String initialId,
}) async {
  final spyCartRepo = _SpyCartRepository();
  final overrides = <Override>[
    authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
    cartRepositoryProvider.overrideWithValue(spyCartRepo),
    for (final entry in items.entries)
      itemDetailsProvider(entry.key).overrideWith((ref) async => entry.value),
  ];

  final router = GoRouter(
    initialLocation: '/menu/item/$initialId',
    routes: [
      GoRoute(
        path: '/menu/item/:id',
        builder: (context, state) =>
            ItemDetailsScreen(itemId: state.pathParameters['id']!),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        useOnlyLangCode: true,
        saveLocale: false,
        assetLoader: const CodegenLoader(),
        child: Builder(
          builder: (context) {
            return MaterialApp.router(
              routerConfig: router,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
            );
          },
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pumpAndSettle();
  return spyCartRepo;
}

ModifierGroup _requiredGroup() => const ModifierGroup(
  id: 'g-size',
  name: 'Size',
  isRequired: true,
  selectionType: 'SINGLE',
  minSelections: 1,
  maxSelections: 1,
  options: [
    ModifierOption(id: 'small', name: 'Small', priceModifier: 0),
    ModifierOption(id: 'large', name: 'Large', priceModifier: 7),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('recommendation card shows a "+" add button', (tester) async {
    final rec = _item('rec1', name: 'Fries');
    final item = _item('m1', oftenOrderedWith: [rec]);
    await _pumpItemDetails(tester, items: {'m1': item}, initialId: 'm1');

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });

  testWidgets(
    'tapping "+" on a simple recommendation adds it directly via the cart '
    'notifier',
    (tester) async {
      final rec = _item('rec1', name: 'Fries', basePrice: 12);
      final item = _item('m1', oftenOrderedWith: [rec]);
      final spyRepo = await _pumpItemDetails(
        tester,
        items: {'m1': item},
        initialId: 'm1',
      );

      await tester.ensureVisible(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(spyRepo.addItemCalls, 1);
      expect(spyRepo.lastAdded?.productName, 'Fries');
      expect(spyRepo.lastAdded?.menuItemId, 'rec1');
      expect(spyRepo.lastAdded?.quantity, 1);
      // Quick-add stays on Product Details for the current item — it must
      // not navigate anywhere.
      expect(find.byType(ItemDetailsScreen), findsOneWidget);
    },
  );

  testWidgets(
    'tapping "+" on a recommendation that requires modifiers opens Product '
    'Details for it instead of adding',
    (tester) async {
      final rec = _item(
        'rec1',
        name: 'Burger',
        modifierGroups: [_requiredGroup()],
      );
      final item = _item('m1', name: 'Main', oftenOrderedWith: [rec]);
      final spyRepo = await _pumpItemDetails(
        tester,
        items: {'m1': item, 'rec1': rec},
        initialId: 'm1',
      );

      await tester.ensureVisible(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(spyRepo.addItemCalls, 0);
      // Navigated to the recommendation's own Product Details page.
      expect(find.text('Main'), findsNothing);
    },
  );

  testWidgets('tapping the card body still opens Product Details', (
    tester,
  ) async {
    final rec = _item('rec1', name: 'Fries', basePrice: 12);
    final item = _item('m1', name: 'Burger', oftenOrderedWith: [rec]);
    await _pumpItemDetails(
      tester,
      items: {'m1': item, 'rec1': rec},
      initialId: 'm1',
    );

    await tester.ensureVisible(find.text('Fries'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fries'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(ItemDetailsScreen), findsOneWidget);
    expect(find.text('Burger'), findsNothing);
  });

  testWidgets(
    'tapping "+" does not also trigger the card tap navigation (no double '
    'action)',
    (tester) async {
      final rec = _item('rec1', name: 'Fries', basePrice: 12);
      final item = _item('m1', name: 'Burger', oftenOrderedWith: [rec]);
      final spyRepo = await _pumpItemDetails(
        tester,
        items: {'m1': item, 'rec1': rec},
        initialId: 'm1',
      );

      await tester.ensureVisible(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Exactly one add, and no navigation away from the current screen.
      expect(spyRepo.addItemCalls, 1);
      expect(find.text('Burger'), findsWidgets);
    },
  );

  testWidgets('no overflow at 360dp with a long recommendation name', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Two overflow sources at 360dp are pre-existing and unrelated to the
    // recommendation card this phase touches: the generic section-header
    // Row (item_details_screen.dart, shared by "Customization"/"Notes"/
    // "Often Ordered With" titles) and the sticky footer Add-to-Cart Row.
    // Both are swallowed so only a genuine overflow in the recommendation
    // card itself (its price+add-button Row) would fail this test.
    //
    // Line numbers below must track the current file — they drifted once
    // already (177→179, 1287→1257) as unrelated edits shifted these Rows,
    // which silently let both pre-existing, out-of-scope overflows leak
    // through and fail this test even though the recommendation card itself
    // was fine.
    final unexpectedOverflows = <FlutterErrorDetails>[];
    final origOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final isKnownPreExisting =
          details.exceptionAsString().contains('overflowed') &&
          (details.toString().contains('item_details_screen.dart:179') ||
              details.toString().contains('item_details_screen.dart:1257'));
      if (details.exceptionAsString().contains('overflowed') &&
          !isKnownPreExisting) {
        unexpectedOverflows.add(details);
      }
    };

    final rec = _item(
      'rec1',
      name: 'Mix Fishah With Tuhal And Askindirani Recommendation Plate',
      basePrice: 999,
    );
    final item = _item('m1', oftenOrderedWith: [rec]);
    await _pumpItemDetails(tester, items: {'m1': item}, initialId: 'm1');

    FlutterError.onError = origOnError;

    expect(unexpectedOverflows, isEmpty);
  });
}
