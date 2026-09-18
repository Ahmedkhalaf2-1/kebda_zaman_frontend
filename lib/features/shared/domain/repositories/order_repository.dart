import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/features/shared/domain/models/orders_reset_summary.dart';

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

  /// Admin/Cashier single-order lookup via `GET /admin/orders/:id` — distinct
  /// from [getOrderById], which hits the customer-owned `GET /orders/:id`
  /// and 404s for orders the caller doesn't own (every order, for staff).
  Future<Result<Order>> getAdminOrderById(String id);

  /// ADMIN-only: `PATCH /admin/orders/:id/driver` — assigns or reassigns a
  /// DELIVERY order to an active driver. Backend rules (DRIVER_DELIVERY_API_
  /// CONTRACT.md): only DELIVERY orders, not already DELIVERED/CANCELLED,
  /// target must be an active DRIVER, and a concurrent reassignment loses
  /// with `409 ASSIGNMENT_CHANGED`. Returns the authoritative updated order.
  Future<Result<Order>> assignDriver(String orderId, String driverId);

  /// ADMIN-only: `DELETE /admin/orders/:id/driver` — unassigns the current
  /// driver. Same rules/response shape as [assignDriver].
  Future<Result<Order>> unassignDriver(String orderId);

  /// ADMIN-only: `GET /admin/orders/reset-preview` — a dry-run count of
  /// what [resetOrders] would delete, with no side effects. Used to show
  /// the admin what they're about to permanently destroy before they
  /// confirm.
  Future<Result<OrdersResetSummary>> previewResetOrders();

  /// ADMIN-only, destructive: `DELETE /admin/orders/reset` — permanently
  /// deletes every order (cascading items/payments/reviews/feedback/status
  /// history at the DB level). Disabled server-side outside non-production
  /// environments (`403 RESET_DISABLED_IN_PRODUCTION`). Irreversible.
  Future<Result<OrdersResetSummary>> resetOrders();
}
