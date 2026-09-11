import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/domain/models/kitchen_order.dart';

/// GET visibility here is KITCHEN-role-only — ADMIN/CASHIER tokens get 403
/// on [getQueue]/[getOrder], they use the /admin/orders endpoints instead.
/// [setPreparationTime]'s mutation endpoint is the one exception: the
/// backend authorizes it for both KITCHEN and ADMIN (an admin override),
/// still 403s CASHIER.
abstract class KitchenRepository {
  /// GET /kitchen/orders — the live queue: only CONFIRMED/PREPARING orders,
  /// oldest first. Nothing pending-unaccepted, nothing already handed
  /// off/cancelled.
  Future<Result<List<KitchenOrder>>> getQueue();

  /// GET /kitchen/orders/:id — single order, any status (not restricted to
  /// CONFIRMED/PREPARING like the queue, so a ticket already open in the UI
  /// doesn't 404 if the order moves along mid-view).
  Future<Result<KitchenOrder>> getOrder(String id);

  /// PATCH /kitchen/orders/:id/preparation-time — sets minutes remaining
  /// (1..180). Backend-only validated against order status (only
  /// CONFIRMED/PREPARING accept this; 422 ORDER_NOT_IN_PREPARATION
  /// otherwise) and role (KITCHEN or ADMIN). Returns the updated
  /// [KitchenOrder] with the backend-computed [KitchenOrder.estimatedDeliveryTime]
  /// — never compute that timestamp client-side.
  Future<Result<KitchenOrder>> setPreparationTime(String orderId, int minutes);
}
