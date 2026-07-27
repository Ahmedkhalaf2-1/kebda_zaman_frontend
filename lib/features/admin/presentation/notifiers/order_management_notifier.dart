import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/result.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

class OrderManagementNotifier extends AutoDisposeAsyncNotifier<List<Order>> {
  @override
  Future<List<Order>> build() async {
    final repo = ref.read(orderRepositoryProvider);
    final result = await repo.getAllOrders();
    return result.fold((l) => throw l, (r) => r);
  }

  /// Re-fetches the order list, e.g. for pull-to-refresh, so newly created
  /// orders show up without having to leave and re-enter the screen.
  Future<void> refresh() async {
    state = const AsyncLoading<List<Order>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final repo = ref.read(orderRepositoryProvider);
      final result = await repo.getAllOrders();
      return result.fold((l) => throw l, (r) => r);
    });
  }

  /// Returns null on success, or an error message on failure.
  Future<String?> updateOrderStatus(
    String orderId,
    OrderStatus newStatus,
  ) async {
    final repo = ref.read(orderRepositoryProvider);
    final currentOrders = state.valueOrNull ?? [];

    late final Order order;
    try {
      order = currentOrders.firstWhere((o) => o.id == orderId);
    } catch (e) {
      return 'Order not found';
    }

    final oldStatus = order.status;
    final optimisticOrder = order.copyWith(status: newStatus);

    // Optimistic update
    state = AsyncData(
      currentOrders.map((o) => o.id == orderId ? optimisticOrder : o).toList(),
    );

    final Result<Order> result = await repo.updateOrderStatus(
      orderId,
      newStatus,
    );

    if (result is Err<Order>) {
      // Roll back the optimistic update — the server rejected the transition.
      state = AsyncData(currentOrders);
      return result.error.message;
    }

    final serverOrder = (result as Success<Order>).data;
    // Reconcile with the authoritative order returned by the server.
    final latest = state.valueOrNull ?? currentOrders;
    state = AsyncData(
      latest.map((o) => o.id == orderId ? serverOrder : o).toList(),
    );

    // Award loyalty points if this transition just became a terminal success state.
    if (newStatus == OrderStatus.delivered &&
        oldStatus != OrderStatus.delivered &&
        order.loyaltyPointsEarned > 0) {
      final loyaltyRepo = ref.read(loyaltyRepositoryProvider);
      await loyaltyRepo.earnPoints(
        userId: order.userId,
        orderId: order.id,
        points: order.loyaltyPointsEarned,
      );
    }

    return null;
  }
}

final orderManagementProvider =
    AutoDisposeAsyncNotifierProvider<OrderManagementNotifier, List<Order>>(
      () => OrderManagementNotifier(),
    );
