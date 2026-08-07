import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/favorites_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/home_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/item_details_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/menu_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/screens/favorites_screen.dart';
import 'package:kebda_zaman/features/customer/presentation/screens/home_screen.dart';
import 'package:kebda_zaman/features/customer/presentation/screens/item_details_screen.dart';
import 'package:kebda_zaman/features/customer/presentation/screens/menu_screen.dart';
import 'package:kebda_zaman/features/shared/domain/models/address.dart';
import 'package:kebda_zaman/features/shared/domain/models/category.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/address_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/auth_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/favorites_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/order_repository.dart';
import 'package:kebda_zaman/generated/codegen_loader.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

User _testUser({bool guest = false}) => User(
  id: 'u1',
  name: guest ? 'Guest' : 'Ahmed Ali',
  email: guest ? null : 'ahmed@example.com',
  createdAt: DateTime(2026, 1, 1),
);

MenuItem _testItem(String id) => MenuItem(
  id: id,
  categoryId: 'c1',
  name: 'Kebda Sandwich $id',
  description: 'Delicious liver sandwich with herbs and spices.',
  imageUrl: '',
  basePrice: 50.0,
);

class _FakeAuthRepository implements AuthRepository {
  final User? user;
  _FakeAuthRepository(this.user);
  @override
  Future<Result<User>> login(String email, String password) async =>
      Success(user!);
  @override
  Future<Result<User>> adminLogin(String email, String password) async =>
      Success(user!);
  @override
  Future<Result<User>> googleLogin(String firebaseIdToken) async =>
      Success(user!);
  @override
  Future<Result<User>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async => Success(user!);
  @override
  Future<Result<User>> guestLogin() async => Success(user!);
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
  }) async => Success(user!);
}

class _FakeAddressRepository implements AddressRepository {
  @override
  Future<Result<List<Address>>> getAddresses() async => const Success([]);
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
      throw UnimplementedError();
}

class _FakeOrderRepository implements OrderRepository {
  @override
  Future<Result<List<Order>>> getOrders({
    String? userId,
    int? page,
    int? limit,
    String? status,
  }) async => const Success([]);
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
  Future<Result<List<Order>>> getAllOrders() async => const Success([]);
}

class _MockFavoritesRepository implements FavoritesRepository {
  List<MenuItem> items;
  _MockFavoritesRepository({this.items = const []});
  @override
  Future<Result<List<MenuItem>>> getFavorites() async => Success(items);
  @override
  Future<Result<List<MenuItem>>> addFavorite(String menuItemId) async {
    final newItem = _testItem(menuItemId);
    items = [...items, newItem];
    return Success(items);
  }

  @override
  Future<Result<void>> removeFavorite(String menuItemId) async {
    items = items.where((i) => i.id != menuItemId).toList();
    return const Success(null);
  }
}

class _FixedMenuNotifier extends MenuNotifier {
  final MenuData data;
  _FixedMenuNotifier(this.data);
  @override
  Future<MenuData> build() async => data;
}

Future<void> _pumpWithContainer(
  WidgetTester tester,
  ProviderContainer container,
  Widget screen,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('ar'),
        startLocale: const Locale('ar'),
        useOnlyLangCode: true,
        assetLoader: const CodegenLoader(),
        child: MaterialApp(locale: const Locale('ar'), home: screen),
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

  Future<void> setMobileViewport(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('Favorites Widget/Screen Integration', () {
    testWidgets(
      'toggling a Favorite on Home updates the same item’s Favorite status on Menu and Item Details',
      (tester) async {
        await setMobileViewport(tester);

        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(
              _FakeAuthRepository(_testUser()),
            ),
            addressRepositoryProvider.overrideWithValue(
              _FakeAddressRepository(),
            ),
            orderRepositoryProvider.overrideWithValue(_FakeOrderRepository()),
            favoritesRepositoryProvider.overrideWithValue(
              _MockFavoritesRepository(),
            ),
            homeDataProvider.overrideWith(
              (ref) async => HomeData(
                categories: const [Category(id: 'c1', name: 'Sandwiches')],
                featuredItems: const [],
                bestSellers: [_testItem('mi_1')],
                offers: const [],
                recommended: const [],
                popular: const [],
                acceptingOrders: true,
              ),
            ),
            menuNotifierProvider.overrideWith(
              () => _FixedMenuNotifier(
                MenuData(
                  categories: const [Category(id: 'c1', name: 'Sandwiches')],
                  items: [_testItem('mi_1')],
                ),
              ),
            ),
            itemDetailsProvider.overrideWith((ref, id) async => _testItem(id)),
          ],
        );

        await container
            .read(authNotifierProvider.notifier)
            .login(identifier: 'test@example.com', password: 'password');
        await container
            .read(customerFavoritesProvider.notifier)
            .loadFavorites();

        await _pumpWithContainer(tester, container, const HomeScreen());
        await tester.pumpAndSettle();
        tester.takeException(); // Clear transient frame 0 layout exceptions

        // Initially not favorited on Home
        expect(find.byIcon(Icons.favorite_border_rounded), findsWidgets);
        expect(find.byIcon(Icons.favorite_rounded), findsNothing);

        // Tap favorite on Home
        await tester.ensureVisible(
          find.byIcon(Icons.favorite_border_rounded).first,
        );
        await tester.tap(find.byIcon(Icons.favorite_border_rounded).first);
        await tester.pumpAndSettle();

        // Favorited on Home
        expect(find.byIcon(Icons.favorite_rounded), findsWidgets);
        expect(
          container
              .read(customerFavoritesProvider)
              .favoriteIds
              .contains('mi_1'),
          isTrue,
        );

        // Check MenuScreen
        await _pumpWithContainer(tester, container, const MenuScreen());
        await tester.pumpAndSettle();
        tester.takeException();
        expect(find.byIcon(Icons.favorite_rounded), findsWidgets);

        // Check ItemDetailsScreen
        await _pumpWithContainer(
          tester,
          container,
          const ItemDetailsScreen(itemId: 'mi_1'),
        );
        await tester.pumpAndSettle();
        tester.takeException();
        expect(find.byIcon(Icons.favorite_rounded), findsWidgets);
      },
    );

    testWidgets(
      'removing an item from Favorites screen updates Home and Menu icon state',
      (tester) async {
        await setMobileViewport(tester);

        final mockFavRepo = _MockFavoritesRepository(
          items: [_testItem('mi_1')],
        );
        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(
              _FakeAuthRepository(_testUser()),
            ),
            addressRepositoryProvider.overrideWithValue(
              _FakeAddressRepository(),
            ),
            orderRepositoryProvider.overrideWithValue(_FakeOrderRepository()),
            favoritesRepositoryProvider.overrideWithValue(mockFavRepo),
            homeDataProvider.overrideWith(
              (ref) async => HomeData(
                categories: const [Category(id: 'c1', name: 'Sandwiches')],
                featuredItems: const [],
                bestSellers: [_testItem('mi_1')],
                offers: const [],
                recommended: const [],
                popular: const [],
                acceptingOrders: true,
              ),
            ),
            menuNotifierProvider.overrideWith(
              () => _FixedMenuNotifier(
                MenuData(
                  categories: const [Category(id: 'c1', name: 'Sandwiches')],
                  items: [_testItem('mi_1')],
                ),
              ),
            ),
          ],
        );

        await container
            .read(authNotifierProvider.notifier)
            .login(identifier: 'test@example.com', password: 'password');
        await container
            .read(customerFavoritesProvider.notifier)
            .loadFavorites();
        expect(
          container
              .read(customerFavoritesProvider)
              .favoriteIds
              .contains('mi_1'),
          isTrue,
        );

        await _pumpWithContainer(tester, container, const FavoritesScreen());
        await tester.pumpAndSettle();
        tester.takeException();

        expect(find.text('Kebda Sandwich mi_1'), findsWidgets);
        expect(find.byIcon(Icons.favorite_rounded), findsWidgets);

        // Tap remove button on FavoritesScreen using KZIconButton finder
        await tester.tap(find.byType(KZIconButton).first);
        await tester.pumpAndSettle();

        expect(
          container
              .read(customerFavoritesProvider)
              .favoriteIds
              .contains('mi_1'),
          isFalse,
        );

        // Check HomeScreen
        await _pumpWithContainer(tester, container, const HomeScreen());
        await tester.pumpAndSettle();
        tester.takeException();
        expect(find.byIcon(Icons.favorite_border_rounded), findsWidgets);

        // Check MenuScreen
        await _pumpWithContainer(tester, container, const MenuScreen());
        await tester.pumpAndSettle();
        tester.takeException();
        expect(find.byIcon(Icons.favorite_border_rounded), findsWidgets);
      },
    );

    testWidgets(
      'unauthenticated favorite button tap preserves existing intended project behavior without crashing',
      (tester) async {
        await setMobileViewport(tester);

        final mockFavRepo = _MockFavoritesRepository();
        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(_FakeAuthRepository(null)),
            addressRepositoryProvider.overrideWithValue(
              _FakeAddressRepository(),
            ),
            orderRepositoryProvider.overrideWithValue(_FakeOrderRepository()),
            favoritesRepositoryProvider.overrideWithValue(mockFavRepo),
            homeDataProvider.overrideWith(
              (ref) async => HomeData(
                categories: const [Category(id: 'c1', name: 'Sandwiches')],
                featuredItems: const [],
                bestSellers: [_testItem('mi_1')],
                offers: const [],
                recommended: const [],
                popular: const [],
                acceptingOrders: true,
              ),
            ),
            menuNotifierProvider.overrideWith(
              () => _FixedMenuNotifier(
                MenuData(
                  categories: const [Category(id: 'c1', name: 'Sandwiches')],
                  items: [_testItem('mi_1')],
                ),
              ),
            ),
          ],
        );

        await container
            .read(customerFavoritesProvider.notifier)
            .loadFavorites();

        // Test Home unauthenticated tap
        await _pumpWithContainer(tester, container, const HomeScreen());
        await tester.pumpAndSettle();
        tester
            .takeException(); // Clear transient frame 0 layout overflow from async localization loading
        await tester.ensureVisible(
          find.byIcon(Icons.favorite_border_rounded).first,
        );
        await tester.tap(find.byIcon(Icons.favorite_border_rounded).first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(mockFavRepo.items.isEmpty, isTrue);

        // Test Menu unauthenticated tap
        await _pumpWithContainer(tester, container, const MenuScreen());
        await tester.pumpAndSettle();
        tester.takeException();
        await tester.ensureVisible(
          find.byIcon(Icons.favorite_border_rounded).first,
        );
        await tester.tap(find.byIcon(Icons.favorite_border_rounded).first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(mockFavRepo.items.isEmpty, isTrue);

        // Test Favorites unauthenticated view
        await _pumpWithContainer(tester, container, const FavoritesScreen());
        await tester.pumpAndSettle();
        tester.takeException();
      },
    );
  });
}
