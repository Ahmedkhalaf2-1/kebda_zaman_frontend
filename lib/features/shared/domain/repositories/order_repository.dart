import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

/// Order repository interface per md1 §21/§25.
abstract class OrderRepository {
  Future<Result<List<Order>>> getOrders({
    String? userId,
    int? page,
    int? limit,
    String? status,
  });
  Future<Result<Order>> getOrderById(String id);
  Future<Result<Order>> checkout({
    required FulfillmentType deliveryMethod,
    required String paymentMethod,
    Map<String, dynamic>? deliveryAddress,
    String? promoCode,
    String? redeemRewardId,
    String? notes,
    required String idempotencyKey,
  });
  Future<Result<Order>> createOrder(Order order);
  Future<Result<Order>> updateOrderStatus(String orderId, OrderStatus status);
  Stream<Order> watchOrder(String id);

  // Admin
  Future<Result<List<Order>>> getAllOrders();
}
