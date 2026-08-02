import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/order_repository.dart';

class FakeOrderRepository implements OrderRepository {
  List<Order> _orders = [];
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('orders_state');
    _orders = [];
    _initialized = true;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'orders_state',
      json.encode(_orders.map((o) => o.toJson()).toList()),
    );
  }

  @override
  Future<Result<List<Order>>> getOrders({
    String? userId,
    int? page,
    int? limit,
    String? status,
  }) async {
    await _init();
    return Success(
      userId == null
          ? _orders
          : _orders.where((o) => o.userId == userId).toList(),
    );
  }

  @override
  Future<Result<Order>> getOrderById(String id) async {
    await _init();
    final order = _orders.firstWhere(
      (o) => o.id == id,
      orElse: () => throw Exception(),
    );
    return Success(order);
  }

  @override
  Future<Result<Order>> checkout({
    required FulfillmentType deliveryMethod,
    required String paymentMethod,
    Map<String, dynamic>? deliveryAddress,
    String? deliveryZoneId,
    String? promoCode,
    String? redeemRewardId,
    String? notes,
    required String idempotencyKey,
  }) async {
    // Just a mock for old usage
    await _init();
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      orderNumber: 'MOCK',
      userId: 'mock',
      items: [],
      fulfillmentType: deliveryMethod,
      status: OrderStatus.pending,
      subtotal: 0,
      grandTotal: 0,
      placedAt: DateTime.now(),
    );
    _orders.add(order);
    await _save();
    return Success(order);
  }

  @override
  Future<Result<Order>> createOrder(Order order) async {
    await _init();
    _orders.add(order);
    await _save();
    return Success(order);
  }

  @override
  Future<Result<Order>> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async {
    await _init();
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _orders[idx] = _orders[idx].copyWith(status: status);
      await _save();
      return Success(_orders[idx]);
    }
    return const Err(UnknownFailure('Not found'));
  }

  @override
  Stream<Order> watchOrder(String id) async* {
    await _init();
    final order = _orders.firstWhere(
      (o) => o.id == id,
      orElse: () => throw Exception(),
    );
    yield order;
  }

  @override
  Future<Result<List<Order>>> getAllOrders() async {
    await _init();
    return Success(_orders);
  }

  @override
  Future<Result<Order>> getAdminOrderById(String id) async {
    await _init();
    for (final order in _orders) {
      if (order.id == id) return Success(order);
    }
    return const Err(NetworkFailure('Order not found'));
  }
}
