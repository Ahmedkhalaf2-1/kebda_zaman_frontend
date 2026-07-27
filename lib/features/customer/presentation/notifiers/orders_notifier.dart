import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
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
    final repo = ref.read(orderRepositoryProvider);

    // In a real app we get current user id, for fake we just pass null to get customer orders
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
