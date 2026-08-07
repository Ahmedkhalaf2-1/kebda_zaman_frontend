import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/home_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/screens/home_screen.dart';
import 'package:kebda_zaman/generated/codegen_loader.g.dart';
import 'package:kebda_zaman/features/shared/domain/models/address.dart';
import 'package:kebda_zaman/features/shared/domain/models/category.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/address_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/auth_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/favorites_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/order_repository.dart';

User _testUser({bool guest = false}) => User(
  id: 'u1',
  name: guest ? 'Guest' : 'Ahmed Ali',
  email: guest ? null : 'ahmed@example.com',
  createdAt: DateTime(2026, 1, 1),
);

MenuItem _testItem(String id, {double? discountPrice}) => MenuItem(
  id: id,
  categoryId: 'c1',
  name: 'Kebda Sandwich $id',
  description: 'Delicious',
  imageUrl: '',
  basePrice: 50,
  discountPrice: discountPrice,
);

Order _testOrder(String id) => Order(
  id: id,
  orderNumber: 'ORD-$id',
  userId: 'u1',
  items: [
    OrderItem(
      menuItemId: 'mi_$id',
      name: 'Past Order Item $id',
      imageUrl: '',
      basePrice: 40,
      unitPrice: 40,
      quantity: 1,
      lineTotal: 40,
    ),
  ],
  fulfillmentType: FulfillmentType.delivery,
  status: OrderStatus.delivered,
  subtotal: 40,
  grandTotal: 40,
  placedAt: DateTime(2026, 1, 2),
);

class _FakeAuthRepository implements AuthRepository {
  final User user;
  _FakeAuthRepository(this.user);
  @override
  Future<Result<User>> login(String email, String password) async =>
      Success(user);
  @override
  Future<Result<User>> adminLogin(String email, String password) async =>
      Success(user);
  @override
  Future<Result<User>> googleLogin(String firebaseIdToken) async =>
      Success(user);
  @override
  Future<Result<User>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async => Success(user);
  @override
  Future<Result<User>> guestLogin() async => Success(user);
  @override
  Future<Result<void>> logout() async => const Success(null);
  @override
  Future<Result<void>> deleteAccount() async => throw UnimplementedError();
  @override
  Future<Result<User?>> getCurrentUser() async => Success(user);
  @override
  Future<Result<User>> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
    String? locale,
  }) async => Success(user);
}

class _FakeAddressRepository implements AddressRepository {
  final List<Address> addresses;
  _FakeAddressRepository(this.addresses);
  @override
  Future<Result<List<Address>>> getAddresses() async => Success(addresses);
  @override
  Future<Result<Address>> createAddress(Address address) async =>
      Success(address);
  @override
  Future<Result<Address>> updateAddress(String id, Address address) async =>
      Success(address);
  @override
  Future<Result<void>> deleteAddress(String id) async => const Success(null);
  @override
  Future<Result<Address>> setDefaultAddress(String id) async =>
      Success(addresses.first);
}

class _FakeFavoritesRepository implements FavoritesRepository {
  @override
  Future<Result<List<MenuItem>>> getFavorites() async => const Success([]);
  @override
  Future<Result<List<MenuItem>>> addFavorite(String menuItemId) async =>
      const Success([]);
  @override
  Future<Result<void>> removeFavorite(String menuItemId) async =>
      const Success(null);
}

class _FakeOrderRepository implements OrderRepository {
  final List<Order> orders;
  final bool fail;
  _FakeOrderRepository({this.orders = const [], this.fail = false});
  @override
  Future<Result<List<Order>>> getOrders({
    String? userId,
    int? page,
    int? limit,
    String? status,
  }) async {
    if (fail) return const Err(NetworkFailure('simulated network failure'));
    return Success(orders);
  }

  @override
  Future<Result<Order>> getOrderById(String id) async =>
      throw UnimplementedError();
  @override
  Future<Result<Order>> getAdminOrderById(String id) async =>
      throw UnimplementedError();
  @override
  Future<Result<Order>> checkout({
    required FulfillmentType deliveryMethod,
    required String paymentMethod,
    Map<String, dynamic>? deliveryAddress,
    String? promoCode,
    String? redeemRewardId,
    String? notes,
    required String idempotencyKey,
  }) async => throw UnimplementedError();
  @override
  Future<Result<Order>> createOrder(Order order) async =>
      throw UnimplementedError();
  @override
  Future<Result<Order>> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async => throw UnimplementedError();
  @override
  Stream<Order> watchOrder(String id) => const Stream.empty();
  @override
  Future<Result<List<Order>>> getAllOrders() async => Success(orders);
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
        // Match main.dart exactly — the app never reads the JSON files at
        // runtime, it reads this pre-compiled map. Testing against the
        // default JSON loader would validate a code path production never
        // takes.
        assetLoader: const CodegenLoader(),
        child: const MaterialApp(home: HomeScreen()),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Future<void> setMobileViewport(
    WidgetTester tester, [
    Size size = const Size(375, 812),
  ]) async {
    // Flutter's default test surface is ~800x600 — ABOVE the 600px mobile
    // breakpoint (ResponsiveBreakpoints.mobileMax), so without this every
    // test above exercised the tablet/desktop branch only. Force a real
    // phone width (iPhone-SE-class, 375 logical px by default) to actually
    // hit context.isMobile == true.
    await tester.binding.setSurfaceSize(size);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets(
    'renders without exceptions: no user, no address, no featured items, '
    'no offers, no recent orders (all-empty state)',
    (tester) async {
      final overrides = [
        authRepositoryProvider.overrideWithValue(
          _FakeAuthRepository(_testUser(guest: true)),
        ),
        addressRepositoryProvider.overrideWithValue(
          _FakeAddressRepository(const []),
        ),
        favoritesRepositoryProvider.overrideWithValue(
          _FakeFavoritesRepository(),
        ),
        orderRepositoryProvider.overrideWithValue(_FakeOrderRepository()),
        homeDataProvider.overrideWith(
          (ref) async => const HomeData(
            categories: [],
            featuredItems: [],
            bestSellers: [],
            offers: [],
            recommended: [],
            popular: [],
            acceptingOrders: true,
          ),
        ),
      ];

      await setMobileViewport(tester);
      await _pump(tester, overrides);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(HomeScreen), findsOneWidget);
    },
  );

  // Regression coverage for the Best Sellers header row (home_screen.dart)
  // overflowing at narrow widths when the best-sellers list is empty — see
  // the all-empty-state scenario above, repeated across the specific
  // widths this was confirmed to fail at.
  for (final entry in {
    'mobile 320 (320x690)': const Size(320, 690),
    'mobile 360 (360x800)': const Size(360, 800),
    'mobile 375 (375x812)': const Size(375, 812),
    'mobile 390 (390x844)': const Size(390, 844),
    'mobile 430 (430x932)': const Size(430, 932),
  }.entries) {
    testWidgets(
      'renders without exceptions on ${entry.key} — empty best sellers, '
      'no user, no address',
      (tester) async {
        final overrides = [
          authRepositoryProvider.overrideWithValue(
            _FakeAuthRepository(_testUser(guest: true)),
          ),
          addressRepositoryProvider.overrideWithValue(
            _FakeAddressRepository(const []),
          ),
          favoritesRepositoryProvider.overrideWithValue(
            _FakeFavoritesRepository(),
          ),
          orderRepositoryProvider.overrideWithValue(_FakeOrderRepository()),
          homeDataProvider.overrideWith(
            (ref) async => const HomeData(
              categories: [],
              featuredItems: [],
              bestSellers: [],
              offers: [],
              recommended: [],
              popular: [],
              acceptingOrders: true,
            ),
          ),
        ];

        await setMobileViewport(tester, entry.value);
        await _pump(tester, overrides);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );
  }

  testWidgets(
    'renders without exceptions: homeDataProvider returns an API error',
    (tester) async {
      final overrides = [
        authRepositoryProvider.overrideWithValue(
          _FakeAuthRepository(_testUser(guest: true)),
        ),
        addressRepositoryProvider.overrideWithValue(
          _FakeAddressRepository(const []),
        ),
        favoritesRepositoryProvider.overrideWithValue(
          _FakeFavoritesRepository(),
        ),
        orderRepositoryProvider.overrideWithValue(_FakeOrderRepository()),
        homeDataProvider.overrideWith(
          (ref) async => throw Exception('empty/broken API response'),
        ),
      ];

      await setMobileViewport(tester);
      await _pump(tester, overrides);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(HomeScreen), findsOneWidget);
    },
  );

  testWidgets(
    'renders without exceptions: ordersProvider (recently ordered) fails',
    (tester) async {
      final overrides = [
        authRepositoryProvider.overrideWithValue(
          _FakeAuthRepository(_testUser(guest: true)),
        ),
        addressRepositoryProvider.overrideWithValue(
          _FakeAddressRepository(const []),
        ),
        favoritesRepositoryProvider.overrideWithValue(
          _FakeFavoritesRepository(),
        ),
        orderRepositoryProvider.overrideWithValue(
          _FakeOrderRepository(fail: true),
        ),
        homeDataProvider.overrideWith(
          (ref) async => const HomeData(
            categories: [],
            featuredItems: [],
            bestSellers: [],
            offers: [],
            recommended: [],
            popular: [],
            acceptingOrders: true,
          ),
        ),
      ];

      await setMobileViewport(tester);
      await _pump(tester, overrides);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Recently Ordered must be hidden, not crash, when its data source fails.
      expect(find.text('home.recently_ordered'), findsNothing);
    },
  );

  testWidgets(
    'renders without exceptions: populated state (name, address, featured, '
    'offers, best sellers, recent orders all present)',
    (tester) async {
      final address = Address(
        id: 'a1',
        userId: 'u1',
        label: 'Home',
        street: '12 Nile St',
        building: '4',
        city: 'Cairo',
        area: 'Heliopolis',
        isDefault: true,
      );
      final overrides = [
        authRepositoryProvider.overrideWithValue(
          _FakeAuthRepository(_testUser()),
        ),
        addressRepositoryProvider.overrideWithValue(
          _FakeAddressRepository([address]),
        ),
        favoritesRepositoryProvider.overrideWithValue(
          _FakeFavoritesRepository(),
        ),
        orderRepositoryProvider.overrideWithValue(
          _FakeOrderRepository(orders: [_testOrder('o1')]),
        ),
        homeDataProvider.overrideWith(
          (ref) async => HomeData(
            categories: const [Category(id: 'c1', name: 'Sandwiches')],
            featuredItems: [_testItem('f1')],
            bestSellers: [_testItem('b1')],
            offers: [_testItem('o1', discountPrice: 40)],
            recommended: const [],
            popular: [_testItem('p1')],
            acceptingOrders: true,
          ),
        ),
      ];

      await setMobileViewport(tester);
      await _pump(tester, overrides);
      // Log in (and thus become non-guest / non-empty address) through the
      // real AuthNotifier so its full state machine is exercised, not a
      // hand-substituted notifier.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(HomeScreen)),
      );
      await container
          .read(authNotifierProvider.notifier)
          .login(identifier: 'ahmed@example.com', password: 'whatever');
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Ahmed'), findsOneWidget); // first-name greeting
      // _AppBarAddressSelector's subtitle intentionally shows only the
      // address label (falling back to street) — the " • {area}" suffix
      // was deliberately dropped from the compact selector (see
      // home_screen.dart's _AppBarAddressSelector; area is no longer
      // referenced there at all), so "Heliopolis" (area) is correctly never
      // shown here — asserting on the label it does render instead.
      expect(find.text('Home'), findsOneWidget);
    },
  );
}
