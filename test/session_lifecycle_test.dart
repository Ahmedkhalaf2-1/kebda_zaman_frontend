import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/session/session_coordinator.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/cart_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/orders_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/favorites_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/address_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';
import 'package:kebda_zaman/features/shared/domain/models/cart.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/features/shared/domain/models/address.dart';
import 'package:kebda_zaman/core/errors/result.dart';
import 'package:kebda_zaman/features/shared/data/fake_auth_repository.dart';
import 'package:kebda_zaman/features/shared/data/fake_cart_repository.dart';
import 'package:kebda_zaman/features/shared/data/fake_order_repository.dart';
import 'package:kebda_zaman/features/shared/data/fake_favorites_repository.dart';
import 'package:kebda_zaman/features/shared/data/fake_address_repository.dart';

class TestAuthRepository extends FakeAuthRepository {
  User? loginUser;
  User? currentUser;

  @override
  Future<Result<User>> login(String email, String password) async =>
      Success(loginUser!);

  @override
  Future<Result<User?>> getCurrentUser() async => Success(currentUser);

  @override
  Future<Result<User>> adminLogin(String email, String password) async =>
      Success(loginUser!);
}

class TestCartRepository extends FakeCartRepository {
  int getCartCalls = 0;
  @override
  Future<Result<Cart>> getCart() async {
    getCartCalls++;
    return const Success(Cart(id: 'cart-1'));
  }
}

class TestOrderRepository extends FakeOrderRepository {
  int getOrdersCalls = 0;
  @override
  Future<Result<List<Order>>> getOrders({
    String? userId,
    String? status,
    int? page,
    int? limit,
  }) async {
    getOrdersCalls++;
    return const Success([]);
  }
}

class TestFavoritesRepository extends FakeFavoritesRepository {
  int getFavoritesCalls = 0;
  @override
  Future<Result<List<MenuItem>>> getFavorites() async {
    getFavoritesCalls++;
    return const Success([]);
  }
}

class TestAddressRepository extends FakeAddressRepository {
  int getAddressesCalls = 0;
  @override
  Future<Result<List<Address>>> getAddresses() async {
    getAddressesCalls++;
    return const Success([]);
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  group('Session Lifecycle Coordination & Auth-Gating', () {
    test(
      'protected providers do not request APIs while unauthenticated',
      () async {
        final mockCartRepo = TestCartRepository();
        final mockOrderRepo = TestOrderRepository();
        final mockFavRepo = TestFavoritesRepository();
        final mockAddrRepo = TestAddressRepository();

        final container = ProviderContainer(
          overrides: [
            cartRepositoryProvider.overrideWithValue(mockCartRepo),
            orderRepositoryProvider.overrideWithValue(mockOrderRepo),
            favoritesRepositoryProvider.overrideWithValue(mockFavRepo),
            addressRepositoryProvider.overrideWithValue(mockAddrRepo),
          ],
        );
        addTearDown(container.dispose);

        // Initialize root session lifecycle listener
        container.read(sessionLifecycleProvider);

        // Read protected providers while unauthenticated (default auth state is unauthenticated/initial)
        await container.read(cartProvider.future);
        await container.read(ordersProvider.future);
        container.read(customerFavoritesProvider);
        container.read(addressNotifierProvider);

        await Future.delayed(const Duration(milliseconds: 50));

        expect(mockCartRepo.getCartCalls, 0);
        expect(mockOrderRepo.getOrdersCalls, 0);
        expect(mockFavRepo.getFavoritesCalls, 0);
        expect(mockAddrRepo.getAddressesCalls, 0);
      },
    );

    test(
      'logout clears all user-scoped providers and stops further API calls',
      () async {
        final testAuthRepo = TestAuthRepository();
        final mockCartRepo = TestCartRepository();
        final mockOrderRepo = TestOrderRepository();
        final mockFavRepo = TestFavoritesRepository();
        final mockAddrRepo = TestAddressRepository();

        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(testAuthRepo),
            cartRepositoryProvider.overrideWithValue(mockCartRepo),
            orderRepositoryProvider.overrideWithValue(mockOrderRepo),
            favoritesRepositoryProvider.overrideWithValue(mockFavRepo),
            addressRepositoryProvider.overrideWithValue(mockAddrRepo),
          ],
        );
        addTearDown(container.dispose);

        container.read(sessionLifecycleProvider);

        final cartSub = container.listen(cartProvider, (_, __) {});
        final orderSub = container.listen(ordersProvider, (_, __) {});
        final favSub = container.listen(customerFavoritesProvider, (_, __) {});
        final addrSub = container.listen(addressNotifierProvider, (_, __) {});
        addTearDown(cartSub.close);
        addTearDown(orderSub.close);
        addTearDown(favSub.close);
        addTearDown(addrSub.close);

        final userA = User(
          id: 'usr-A',
          name: 'User A',
          email: 'usera@test.com',
          createdAt: DateTime.now(),
        );
        testAuthRepo.loginUser = userA;

        // Log in User A via authNotifierProvider
        await container
            .read(authNotifierProvider.notifier)
            .login(identifier: 'usera@test.com', password: 'password');

        await container.read(cartProvider.future);
        await container.read(ordersProvider.future);
        container.read(customerFavoritesProvider);
        container.read(addressNotifierProvider);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(mockCartRepo.getCartCalls, 1);
        expect(mockOrderRepo.getOrdersCalls, 1);
        expect(mockFavRepo.getFavoritesCalls, 1);
        expect(mockAddrRepo.getAddressesCalls, 1);

        // Now logout
        await container.read(authNotifierProvider.notifier).logout();
        await Future.delayed(const Duration(milliseconds: 50));

        // Because cartProvider and ordersProvider were invalidated while being listened to,
        // Riverpod rebuilds them immediately. The auth-guard check must prevent a new API call!
        expect(mockCartRepo.getCartCalls, 1); // still 1, no new call!
        expect(mockOrderRepo.getOrdersCalls, 1); // still 1, no new call!

        // Favorites and Addresses should be reset to empty in-memory state without new API calls
        expect(container.read(customerFavoritesProvider).favoriteItems, isEmpty);
        expect(container.read(addressNotifierProvider).addresses, isEmpty);
      },
    );

    test('session restoration reloads user-scoped providers', () async {
      final testAuthRepo = TestAuthRepository();
      final mockCartRepo = TestCartRepository();
      final mockOrderRepo = TestOrderRepository();
      final mockFavRepo = TestFavoritesRepository();
      final mockAddrRepo = TestAddressRepository();

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(testAuthRepo),
          cartRepositoryProvider.overrideWithValue(mockCartRepo),
          orderRepositoryProvider.overrideWithValue(mockOrderRepo),
          favoritesRepositoryProvider.overrideWithValue(mockFavRepo),
          addressRepositoryProvider.overrideWithValue(mockAddrRepo),
        ],
      );
      addTearDown(container.dispose);

      container.read(sessionLifecycleProvider);

      final favSub = container.listen(customerFavoritesProvider, (_, __) {});
      final addrSub = container.listen(addressNotifierProvider, (_, __) {});
      addTearDown(favSub.close);
      addTearDown(addrSub.close);

      container.read(customerFavoritesProvider);
      container.read(addressNotifierProvider);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(mockFavRepo.getFavoritesCalls, 0);
      expect(mockAddrRepo.getAddressesCalls, 0);

      final userA = User(
        id: 'usr-A',
        name: 'User A',
        email: 'usera@test.com',
        createdAt: DateTime.now(),
      );
      testAuthRepo.currentUser = userA;

      // Simulate cold-start session restoration by calling confirmRestoredSession()
      await container
          .read(authNotifierProvider.notifier)
          .confirmRestoredSession();
      await Future.delayed(const Duration(milliseconds: 50));

      // Favorites and Addresses should have been reloaded
      expect(mockFavRepo.getFavoritesCalls, 1);
      expect(mockAddrRepo.getAddressesCalls, 1);
    });

    test(
      'User A -> User B never retains User A data and triggers fresh load for User B',
      () async {
        final testAuthRepo = TestAuthRepository();
        final mockCartRepo = TestCartRepository();
        final mockOrderRepo = TestOrderRepository();
        final mockFavRepo = TestFavoritesRepository();
        final mockAddrRepo = TestAddressRepository();

        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(testAuthRepo),
            cartRepositoryProvider.overrideWithValue(mockCartRepo),
            orderRepositoryProvider.overrideWithValue(mockOrderRepo),
            favoritesRepositoryProvider.overrideWithValue(mockFavRepo),
            addressRepositoryProvider.overrideWithValue(mockAddrRepo),
          ],
        );
        addTearDown(container.dispose);

        container.read(sessionLifecycleProvider);

        final cartSub = container.listen(cartProvider, (_, __) {});
        final orderSub = container.listen(ordersProvider, (_, __) {});
        final favSub = container.listen(customerFavoritesProvider, (_, __) {});
        final addrSub = container.listen(addressNotifierProvider, (_, __) {});
        addTearDown(cartSub.close);
        addTearDown(orderSub.close);
        addTearDown(favSub.close);
        addTearDown(addrSub.close);

        final userA = User(
          id: 'usr-A',
          name: 'User A',
          email: 'usera@test.com',
          createdAt: DateTime.now(),
        );
        final userB = User(
          id: 'usr-B',
          name: 'User B',
          email: 'userb@test.com',
          createdAt: DateTime.now(),
        );

        // Log in User A
        testAuthRepo.loginUser = userA;
        await container
            .read(authNotifierProvider.notifier)
            .login(identifier: 'usera@test.com', password: 'password');

        await container.read(cartProvider.future);
        await container.read(ordersProvider.future);
        container.read(customerFavoritesProvider);
        container.read(addressNotifierProvider);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(mockCartRepo.getCartCalls, 1);
        expect(mockOrderRepo.getOrdersCalls, 1);
        expect(mockFavRepo.getFavoritesCalls, 1);
        expect(mockAddrRepo.getAddressesCalls, 1);

        // Log in User B (switching accounts)
        testAuthRepo.loginUser = userB;
        await container
            .read(authNotifierProvider.notifier)
            .login(identifier: 'userb@test.com', password: 'password2');
        await Future.delayed(const Duration(milliseconds: 50));

        // All providers should be invalidated and rebuilt for User B
        await container.read(cartProvider.future);
        await container.read(ordersProvider.future);
        container.read(customerFavoritesProvider);
        container.read(addressNotifierProvider);

        expect(mockCartRepo.getCartCalls, 2);
        expect(mockOrderRepo.getOrdersCalls, 2);
        expect(mockFavRepo.getFavoritesCalls, 2);
        expect(mockAddrRepo.getAddressesCalls, 2);
      },
    );
  });
}
