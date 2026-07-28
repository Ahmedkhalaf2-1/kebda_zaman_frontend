import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

class OrdersData {
  final List<Order> activeOrders;
  final List<Order> previousOrders;

  OrdersData({required this.activeOrders, required this.previousOrders});
}

class OrdersNotifier extends AutoDisposeAsyncNotifier<OrdersData> {
  @override
  Future<OrdersData> build() async {
    return _fetchOrders();
  }

  Future<OrdersData> _fetchOrders() async {
    // Guard: do not call GET /orders while unauthenticated.
    final authState = ref.read(authNotifierProvider);
    if (!authState.isLoggedIn) {
      return OrdersData(activeOrders: [], previousOrders: []);
    }

    final repo = ref.read(orderRepositoryProvider);
    final result = await repo.getOrders();
    final allOrders = result.fold((f) => throw f, (data) => data);

    final active = allOrders
        .where(
          (o) =>
              o.status != OrderStatus.delivered &&
              o.status != OrderStatus.cancelled,
        )
        .toList();
    final previous = allOrders
        .where(
          (o) =>
              o.status == OrderStatus.delivered ||
              o.status == OrderStatus.cancelled,
        )
        .toList();

    active.sort((a, b) => b.placedAt.compareTo(a.placedAt));
    previous.sort((a, b) => b.placedAt.compareTo(a.placedAt));

    return OrdersData(activeOrders: active, previousOrders: previous);
  }
}

final ordersProvider =
    AutoDisposeAsyncNotifierProvider<OrdersNotifier, OrdersData>(
      () => OrdersNotifier(),
    );
