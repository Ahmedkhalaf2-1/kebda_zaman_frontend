import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/domain/models/kitchen_order.dart';
import 'package:kebda_zaman/features/admin/domain/repositories/kitchen_repository.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/kitchen_notifier.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/order_management_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/order_repository.dart';

/// Covers [PollingNotifierMixin] as used by Admin Order Management and
/// Kitchen Queue: no-overlap guard, silent error-swallowing on background
/// ticks (vs. surfaced errors on explicit `refresh()`), skip-apply while a
/// foreground mutation is in flight, and timer start/stop lifecycle. Uses
/// `debugTick()` to exercise the exact same code path a real 5s timer tick
/// runs, without waiting on real time.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Order buildOrder({
    required String id,
    OrderStatus status = OrderStatus.pending,
  }) {
    return Order(
      id: id,
      orderNumber: id,
      userId: 'user-1',
      items: const [],
      fulfillmentType: FulfillmentType.pickup,
      status: status,
      subtotal: 10,
      grandTotal: 10,
      placedAt: DateTime(2026, 1, 1),
    );
  }

  KitchenOrder buildKitchenOrder({
    required String id,
    OrderStatus status = OrderStatus.confirmed,
  }) {
    return KitchenOrder(
      id: id,
      orderNumber: id,
      status: status,
      deliveryMethod: FulfillmentType.pickup,
      createdAt: DateTime(2026, 1, 1),
      items: const [],
    );
  }

  group('OrderManagementNotifier polling', () {
    test('background tick replaces state with the latest list', () async {
      final calls = <int>[];
      final repo = _FakeOrderRepository(
        onGetAllOrders: () {
          calls.add(calls.length);
          return Success([buildOrder(id: 'o${calls.length}')]);
        },
      );
      final container = ProviderContainer(
        overrides: [orderRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await container.read(orderManagementProvider.future);
      expect(container.read(orderManagementProvider).value!.single.id, 'o1');

      final notifier = container.read(orderManagementProvider.notifier);
      await notifier.debugTick();

      expect(container.read(orderManagementProvider).value!.single.id, 'o2');
    });

    test('a failed background tick keeps showing current data', () async {
      var shouldFail = false;
      final repo = _FakeOrderRepository(
        onGetAllOrders: () {
          if (shouldFail) return const Err(NetworkFailure('boom'));
          return Success([buildOrder(id: 'stable')]);
        },
      );
      final container = ProviderContainer(
        overrides: [orderRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await container.read(orderManagementProvider.future);
      final notifier = container.read(orderManagementProvider.notifier);

      shouldFail = true;
      await notifier.debugTick();

      final state = container.read(orderManagementProvider);
      expect(state.hasError, isFalse);
      expect(state.value!.single.id, 'stable');
    });

    test('explicit refresh() surfaces a failure as AsyncError', () async {
      var shouldFail = false;
      final repo = _FakeOrderRepository(
        onGetAllOrders: () {
          if (shouldFail) return const Err(NetworkFailure('boom'));
          return Success([buildOrder(id: 'ok')]);
        },
      );
      final container = ProviderContainer(
        overrides: [orderRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await container.read(orderManagementProvider.future);
      final notifier = container.read(orderManagementProvider.notifier);

      shouldFail = true;
      await notifier.refresh();

      expect(container.read(orderManagementProvider).hasError, isTrue);
    });

    test('never issues overlapping background requests', () async {
      var inFlight = 0;
      var maxInFlight = 0;
      final gate = Completer<void>();
      var callCount = 0;
      final repo = _FakeOrderRepository(
        onGetAllOrders: () => Success([buildOrder(id: 'seed')]),
        onGetAllOrdersAsync: () async {
          callCount++;
          if (callCount == 1) {
            // First call is the initial build() fetch — resolve immediately.
            return Success([buildOrder(id: 'seed')]);
          }
          inFlight++;
          maxInFlight = maxInFlight < inFlight ? inFlight : maxInFlight;
          await gate.future;
          inFlight--;
          return Success([buildOrder(id: 'tick-$callCount')]);
        },
      );
      final container = ProviderContainer(
        overrides: [orderRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await container.read(orderManagementProvider.future);
      final notifier = container.read(orderManagementProvider.notifier);

      // Fire two ticks back-to-back without awaiting the first — the
      // in-flight guard must make the second a no-op.
      final first = notifier.debugTick();
      final second = notifier.debugTick();
      gate.complete();
      await first;
      await second;

      expect(maxInFlight, 1);
    });

    test(
      'skips applying a poll tick while a status update is in flight',
      () async {
        final updateGate = Completer<Result<Order>>();
        final repo = _FakeOrderRepository(
          onGetAllOrders: () => Success([buildOrder(id: 'o1')]),
          onUpdateOrderStatus: (id, status) => updateGate.future,
        );
        final container = ProviderContainer(
          overrides: [orderRepositoryProvider.overrideWithValue(repo)],
        );
        addTearDown(container.dispose);

        await container.read(orderManagementProvider.future);
        final notifier = container.read(orderManagementProvider.notifier);

        final updateFuture = notifier.updateOrderStatus(
          'o1',
          OrderStatus.confirmed,
        );
        // Optimistic update should already be applied.
        expect(
          container.read(orderManagementProvider).value!.single.status,
          OrderStatus.confirmed,
        );

        // A poll tick landing mid-update must not clobber the optimistic
        // state with stale pre-mutation data.
        await notifier.debugTick();
        expect(
          container.read(orderManagementProvider).value!.single.status,
          OrderStatus.confirmed,
        );

        updateGate.complete(
          Success(buildOrder(id: 'o1', status: OrderStatus.confirmed)),
        );
        await updateFuture;
      },
    );

    test('timer starts on build and stops on dispose', () async {
      final repo = _FakeOrderRepository(
        onGetAllOrders: () => Success([buildOrder(id: 'o1')]),
      );
      final container = ProviderContainer(
        overrides: [orderRepositoryProvider.overrideWithValue(repo)],
      );

      await container.read(orderManagementProvider.future);
      final notifier = container.read(orderManagementProvider.notifier);
      expect(notifier.hasActiveTimerForTesting, isTrue);

      container.dispose();
      expect(notifier.hasActiveTimerForTesting, isFalse);
    });
  });

  group('KitchenQueueNotifier polling', () {
    test('background tick replaces the queue in place', () async {
      var callCount = 0;
      final repo = _FakeKitchenRepository(
        onGetQueue: () {
          callCount++;
          return Success([buildKitchenOrder(id: 'k$callCount')]);
        },
      );
      final container = ProviderContainer(
        overrides: [kitchenRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await container.read(kitchenQueueProvider.future);
      final notifier = container.read(kitchenQueueProvider.notifier);
      await notifier.debugTick();

      expect(container.read(kitchenQueueProvider).value!.single.id, 'k2');
    });

    test('a failed background tick never surfaces AsyncError', () async {
      var shouldFail = false;
      final repo = _FakeKitchenRepository(
        onGetQueue: () {
          if (shouldFail) return const Err(NetworkFailure('boom'));
          return Success([buildKitchenOrder(id: 'stable')]);
        },
      );
      final container = ProviderContainer(
        overrides: [kitchenRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await container.read(kitchenQueueProvider.future);
      final notifier = container.read(kitchenQueueProvider.notifier);

      shouldFail = true;
      await notifier.debugTick();

      final state = container.read(kitchenQueueProvider);
      expect(state.hasError, isFalse);
      expect(state.value!.single.id, 'stable');
    });
  });
}

class _FakeOrderRepository implements OrderRepository {
  final Result<List<Order>> Function()? onGetAllOrders;
  final Future<Result<List<Order>>> Function()? onGetAllOrdersAsync;
  final Future<Result<Order>> Function(String orderId, OrderStatus status)?
  onUpdateOrderStatus;

  _FakeOrderRepository({
    this.onGetAllOrders,
    this.onGetAllOrdersAsync,
    this.onUpdateOrderStatus,
  });

  @override
  Future<Result<List<Order>>> getAllOrders() async {
    if (onGetAllOrdersAsync != null) return onGetAllOrdersAsync!();
    return onGetAllOrders!();
  }

  @override
  Future<Result<Order>> updateOrderStatus(String orderId, OrderStatus status) {
    if (onUpdateOrderStatus != null) {
      return onUpdateOrderStatus!(orderId, status);
    }
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Order>>> getOrders({
    String? userId,
    int? page,
    int? limit,
    String? status,
  }) => throw UnimplementedError();

  @override
  Future<Result<Order>> getOrderById(String id) => throw UnimplementedError();

  @override
  Future<Result<Order>> checkout({
    required FulfillmentType deliveryMethod,
    required String paymentMethod,
    Map<String, dynamic>? deliveryAddress,
    String? promoCode,
    String? redeemRewardId,
    String? notes,
    required String idempotencyKey,
  }) => throw UnimplementedError();

  @override
  Future<Result<Order>> createOrder(Order order) => throw UnimplementedError();

  @override
  Stream<Order> watchOrder(String id) => throw UnimplementedError();

  @override
  Future<Result<Order>> getAdminOrderById(String id) =>
      throw UnimplementedError();
}

class _FakeKitchenRepository implements KitchenRepository {
  final Result<List<KitchenOrder>> Function() onGetQueue;

  _FakeKitchenRepository({required this.onGetQueue});

  @override
  Future<Result<List<KitchenOrder>>> getQueue() async => onGetQueue();

  @override
  Future<Result<KitchenOrder>> getOrder(String id) =>
      throw UnimplementedError();
}
