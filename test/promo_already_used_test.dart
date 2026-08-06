import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/api/api_interceptors.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/core/notifications/device_service.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/cart_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/checkout_notifier.dart';
import 'package:kebda_zaman/features/shared/data/api_cart_repository.dart';
import 'package:kebda_zaman/features/shared/data/fake_auth_repository.dart';
import 'package:kebda_zaman/features/shared/domain/models/cart.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/cart_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/order_repository.dart';

/// Focused tests for backend `PROMO_ALREADY_USED` (409) handling:
///  - the API repository preserves the backend `code` on the failure,
///  - CartNotifier surfaces the Failure (not a generic Exception) so the UI
///    can pick a specific localized message, and never leaves a rejected
///    promo looking applied,
///  - CheckoutNotifier never returns an order for this failure (so the
///    screen never navigates to success) and refreshes the cart so a stale
///    locally-displayed discount is cleared,
///  - other promo/checkout error codes are unaffected.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.script);
  final List<Future<ResponseBody> Function(RequestOptions)> script;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    if (script.isEmpty) {
      throw StateError('No more scripted responses for ${options.path}');
    }
    return script.removeAt(0)(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(Map<String, dynamic> data, int statusCode) {
  return ResponseBody.fromString(
    jsonEncode(data),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

/// Same constructor-race workaround used for AuthNotifier elsewhere: waits
/// out the fire-and-forget `_loadCachedUserForDisplay()` before the caller
/// drives the notifier further.
Future<AuthNotifier> _readyLoggedInNotifier() async {
  final notifier = AuthNotifier(FakeAuthRepository());
  await Future<void>.delayed(Duration.zero);
  final ok = await notifier.login(identifier: 'user@test.com', password: 'pw');
  expect(ok, isTrue);
  return notifier;
}

/// Cart repository test double whose [applyPromoCode] result is scripted per
/// test, and whose [getCart] always returns a plain no-promo cart — standing
/// in for "the server's real cart" that a rejected promo apply refetches.
class _ScriptedCartRepository implements CartRepository {
  _ScriptedCartRepository(this.applyPromoResult);
  final Result<Cart> applyPromoResult;
  int getCartCalls = 0;

  static Cart _plainCart() => const Cart(
    id: 'remote_cart',
    items: [],
    promoCodeId: null,
    subtotal: 0,
    discountTotal: 0,
    grandTotal: 0,
  );

  @override
  Future<Result<Cart>> getCart() async {
    getCartCalls++;
    return Success(_plainCart());
  }

  @override
  Future<Result<Cart>> applyPromoCode(String code) async => applyPromoResult;

  @override
  Future<Result<Cart>> addItem(CartItem item) async => Success(_plainCart());
  @override
  Future<Result<Cart>> updateItemQuantity(String itemId, int quantity) async =>
      Success(_plainCart());
  @override
  Future<Result<Cart>> removeItem(String itemId) async => Success(_plainCart());
  @override
  Future<Result<Cart>> clearCart() async => Success(_plainCart());
  @override
  Future<Result<Cart>> removePromoCode() async => Success(_plainCart());
}

/// Order repository test double whose [checkout] result is scripted per test.
class _ScriptedOrderRepository implements OrderRepository {
  _ScriptedOrderRepository(this.checkoutResult);
  final Result<Order> checkoutResult;

  @override
  Future<Result<Order>> checkout({
    required FulfillmentType deliveryMethod,
    required String paymentMethod,
    Map<String, dynamic>? deliveryAddress,
    String? promoCode,
    String? redeemRewardId,
    String? notes,
    required String idempotencyKey,
  }) async => checkoutResult;

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
  @override
  Future<Result<Order>> getAdminOrderById(String id) async =>
      throw UnimplementedError();
}

Failure _promoAlreadyUsedFailure() => NetworkFailure(
  'You have already used this promo code',
  ApiException(
    statusCode: 409,
    error: 'Conflict',
    message: 'You have already used this promo code',
    code: 'PROMO_ALREADY_USED',
  ),
);

Failure _minOrderNotMetFailure() => NetworkFailure(
  'Minimum order amount not met',
  ApiException(
    statusCode: 422,
    error: 'Unprocessable Entity',
    message: 'Minimum order amount not met',
    code: 'MIN_ORDER_NOT_MET',
  ),
);

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      {},
    );
    await DeviceService.instance.onSessionInvalidated();
  });

  group('ApiCartRepository.applyPromoCode — PROMO_ALREADY_USED', () {
    test('preserves the backend code on the returned Failure', () async {
      final adapter = _ScriptedAdapter([
        (options) async => _jsonResponse({
          'statusCode': 409,
          'error': 'Conflict',
          'message': 'You have already used this promo code',
          'code': 'PROMO_ALREADY_USED',
        }, 409),
      ]);
      final apiClient = ApiClient(
        secureStorage: const FlutterSecureStorage(),
        tokenStorage: TokenStorage(),
      );
      apiClient.dio.httpClientAdapter = adapter;
      final repo = ApiCartRepository(apiClient);

      final result = await repo.applyPromoCode('KEBDA20');

      expect(result, isA<Err<Cart>>());
      final failure = (result as Err<Cart>).error;
      expect(failure.cause, isA<ApiException>());
      expect((failure.cause as ApiException).code, 'PROMO_ALREADY_USED');
    });
  });

  group('CartNotifier.applyPromoCode — PROMO_ALREADY_USED', () {
    late ProviderContainer container;
    late AuthNotifier authNotifier;

    Future<ProviderContainer> buildContainer(CartRepository cartRepo) async {
      authNotifier = await _readyLoggedInNotifier();
      final c = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith((ref) => authNotifier),
          cartRepositoryProvider.overrideWithValue(cartRepo),
        ],
      );
      addTearDown(c.dispose);
      // cartProvider is autoDispose — keep it alive across the multiple
      // reads each test performs, otherwise it would rebuild from scratch
      // (and briefly report AsyncLoading) between reads.
      c.listen(cartProvider, (_, _) {});
      return c;
    }

    test(
      'throws the Failure (carrying the backend code), not a generic Exception',
      () async {
        final cartRepo = _ScriptedCartRepository(
          Err(_promoAlreadyUsedFailure()),
        );
        container = await buildContainer(cartRepo);
        await container.read(cartProvider.future); // let build() settle

        Object? caught;
        try {
          await container.read(cartProvider.notifier).applyPromoCode('X');
        } catch (e) {
          caught = e;
        }

        expect(caught, isA<Failure>());
        final cause = (caught as Failure).cause;
        expect(cause, isA<ApiException>());
        expect((cause as ApiException).code, 'PROMO_ALREADY_USED');
      },
    );

    test('promo is not shown as applied and no discount is retained — the '
        'cart is refetched from the server after rejection', () async {
      final cartRepo = _ScriptedCartRepository(Err(_promoAlreadyUsedFailure()));
      container = await buildContainer(cartRepo);
      await container.read(cartProvider.future);

      try {
        await container.read(cartProvider.notifier).applyPromoCode('X');
      } catch (_) {}
      // Let the fire-and-forget refetch (started in the failure branch)
      // finish updating state.
      await Future<void>.delayed(Duration.zero);

      final cart = container.read(cartProvider).valueOrNull;
      expect(cart, isNotNull);
      expect(cart!.promoCodeId, isNull);
      expect(cart.discountTotal, 0);
      expect(cartRepo.getCartCalls, greaterThan(0));
    });

    test('other promo errors are unaffected (still thrown as the Failure, '
        'still trigger a cart refresh)', () async {
      final cartRepo = _ScriptedCartRepository(Err(_minOrderNotMetFailure()));
      container = await buildContainer(cartRepo);
      await container.read(cartProvider.future);

      Object? caught;
      try {
        await container.read(cartProvider.notifier).applyPromoCode('X');
      } catch (e) {
        caught = e;
      }

      expect(caught, isA<Failure>());
      expect(
        ((caught as Failure).cause as ApiException).code,
        'MIN_ORDER_NOT_MET',
      );
    });
  });

  group('CheckoutNotifier.placeOrder — PROMO_ALREADY_USED', () {
    late ProviderContainer container;
    late AuthNotifier authNotifier;

    test(
      'does not return an order (so the screen never navigates to success)',
      () async {
        authNotifier = await _readyLoggedInNotifier();
        final c = ProviderContainer(
          overrides: [
            authNotifierProvider.overrideWith((ref) => authNotifier),
            cartRepositoryProvider.overrideWithValue(
              _ScriptedCartRepository(const Success(Cart(id: 'x'))),
            ),
            orderRepositoryProvider.overrideWithValue(
              _ScriptedOrderRepository(Err(_promoAlreadyUsedFailure())),
            ),
          ],
        );
        addTearDown(c.dispose);
        c.listen(checkoutProvider, (_, _) {});
        container = c;

        final order = await container
            .read(checkoutProvider.notifier)
            .placeOrder(
              deliveryMethod: FulfillmentType.delivery,
              paymentMethod: 'CASH',
            );

        expect(order, isNull);
        final state = container.read(checkoutProvider);
        expect(state.hasError, isTrue);
        final failure = state.error as Failure;
        expect((failure.cause as ApiException).code, 'PROMO_ALREADY_USED');
      },
    );

    test('refreshes the server cart so a stale applied promo/discount is '
        'cleared', () async {
      final cartRepo = _ScriptedCartRepository(Err(_promoAlreadyUsedFailure()));
      authNotifier = await _readyLoggedInNotifier();
      final c = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith((ref) => authNotifier),
          cartRepositoryProvider.overrideWithValue(cartRepo),
          orderRepositoryProvider.overrideWithValue(
            _ScriptedOrderRepository(Err(_promoAlreadyUsedFailure())),
          ),
        ],
      );
      addTearDown(c.dispose);
      c.listen(cartProvider, (_, _) {});
      c.listen(checkoutProvider, (_, _) {});
      container = c;

      // Prime the cart provider so we can observe it being invalidated.
      await container.read(cartProvider.future);
      final callsBefore = cartRepo.getCartCalls;

      await container
          .read(checkoutProvider.notifier)
          .placeOrder(
            deliveryMethod: FulfillmentType.delivery,
            paymentMethod: 'CASH',
          );
      await container.read(cartProvider.future);

      expect(cartRepo.getCartCalls, greaterThan(callsBefore));
    });

    test('other checkout errors do not trigger the extra cart refresh', () async {
      final cartRepo = _ScriptedCartRepository(Err(_minOrderNotMetFailure()));
      authNotifier = await _readyLoggedInNotifier();
      final c = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith((ref) => authNotifier),
          cartRepositoryProvider.overrideWithValue(cartRepo),
          orderRepositoryProvider.overrideWithValue(
            _ScriptedOrderRepository(Err(_minOrderNotMetFailure())),
          ),
        ],
      );
      addTearDown(c.dispose);
      c.listen(cartProvider, (_, _) {});
      c.listen(checkoutProvider, (_, _) {});
      container = c;

      await container.read(cartProvider.future);
      final callsBefore = cartRepo.getCartCalls;

      final order = await container
          .read(checkoutProvider.notifier)
          .placeOrder(
            deliveryMethod: FulfillmentType.delivery,
            paymentMethod: 'CASH',
          );

      expect(order, isNull);
      final state = container.read(checkoutProvider);
      final cause = (state.error as Failure).cause;
      expect(cause, isA<ApiException>());
      expect((cause as ApiException).code, 'MIN_ORDER_NOT_MET');
      // No explicit invalidate call for this code — cartProvider is left as-is.
      expect(cartRepo.getCartCalls, callsBefore);
    });
  });
}
