import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/order_tracking.dart';

/// Live driver-location tracking reads (DRIVER_DELIVERY_API_CONTRACT.md
/// Phase 2). Both endpoints return the identical `OrderTrackingResponseDto`
/// shape and are `Cache-Control: no-store` server-side — never cached here
/// either, each call is a fresh read.
abstract class TrackingRepository {
  /// `GET /orders/:id/tracking` — open to any authenticated owner (guests
  /// included), ownership enforced server-side by `userId`, not by role.
  /// Requires no location permission of its own: this is a pure read of the
  /// backend's already-stored location, never the customer device's GPS.
  Future<Result<OrderTracking>> getCustomerTracking(String orderId);

  /// `GET /admin/orders/:id/tracking` — ADMIN/CASHIER only (inherits
  /// `AdminOrdersController`'s class-level role guard).
  Future<Result<OrderTracking>> getAdminTracking(String orderId);
}
