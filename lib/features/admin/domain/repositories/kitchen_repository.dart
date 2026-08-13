import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/domain/models/kitchen_order.dart';

/// KITCHEN-role-only order visibility. ADMIN/CASHIER tokens get 403 on
/// these — they use the /admin/orders endpoints instead.
abstract class KitchenRepository {
  /// GET /kitchen/orders — the live queue: only CONFIRMED/PREPARING orders,
  /// oldest first. Nothing pending-unaccepted, nothing already handed
  /// off/cancelled.
  Future<Result<List<KitchenOrder>>> getQueue();

  /// GET /kitchen/orders/:id — single order, any status (not restricted to
  /// CONFIRMED/PREPARING like the queue, so a ticket already open in the UI
  /// doesn't 404 if the order moves along mid-view).
  Future<Result<KitchenOrder>> getOrder(String id);
}
