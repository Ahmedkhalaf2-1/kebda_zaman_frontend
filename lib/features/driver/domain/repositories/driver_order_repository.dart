import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/driver/domain/models/driver_order.dart';

/// A `429` from `PUT /driver/orders/:id/location` (the dedicated
/// `DRIVER_LOCATION_THROTTLE` — 60/60s per driver, shared across every
/// order this driver has active). [retryAfterSeconds] carries the
/// `Retry-After` response header when the server sent one, so the upload
/// scheduler can honor the server's own cooldown instead of guessing.
class RateLimitedFailure extends ValidationFailure {
  final int? retryAfterSeconds;

  const RateLimitedFailure(super.message, super.cause, this.retryAfterSeconds);
}

/// `LocationAckResponseDto` (DRIVER_DELIVERY_API_CONTRACT.md Phase 2).
/// `accepted: false` is a normal, successful outcome (the sample was valid
/// but not newer than what's already stored for this assignment) — never a
/// transport failure, so it is never represented as a [Result] error.
class LocationUploadAck {
  final bool accepted;
  final int assignmentVersion;
  final DateTime receivedAt;

  const LocationUploadAck({
    required this.accepted,
    required this.assignmentVersion,
    required this.receivedAt,
  });
}

/// DRIVER-only delivery endpoints (DRIVER_DELIVERY_API_CONTRACT.md,
/// `/api/v1/driver/orders`). Every read/write is ownership-checked
/// server-side (`driverId = caller`) — a non-owned or unknown order is
/// always `404 ORDER_NOT_ASSIGNED`, indistinguishable from "doesn't exist".
abstract class DriverOrderRepository {
  /// `GET /driver/orders?page=&limit=` — active assigned orders (any
  /// non-terminal status; assignment can happen before PREPARING).
  Future<Result<List<DriverOrder>>> getActiveOrders({
    int page = 1,
    int limit = 20,
  });

  /// `GET /driver/orders/history?page=&limit=` — completed-delivery history
  /// (DELIVERED/CANCELLED, still currently assigned to this driver).
  Future<Result<List<DriverOrder>>> getHistory({int page = 1, int limit = 20});

  Future<Result<DriverOrder>> getOrderById(String id);

  /// `PATCH /driver/orders/:id/pickup` — PREPARING -> OUT_FOR_DELIVERY.
  Future<Result<DriverOrder>> pickup(String id);

  /// `PATCH /driver/orders/:id/delivered` — OUT_FOR_DELIVERY -> DELIVERED.
  Future<Result<DriverOrder>> delivered(String id);

  /// `PUT /driver/orders/:id/location` (DRIVER_DELIVERY_API_CONTRACT.md
  /// Phase 2). [capturedAt] must be the device's actual GPS fix time, never
  /// the upload time. [assignmentVersion] must be the value most recently
  /// read from this order's [DriverOrder.assignmentVersion] — a stale value
  /// is rejected with `409 ASSIGNMENT_VERSION_MISMATCH`
  /// (`ValidationFailure`, `ApiException.details['currentAssignmentVersion']`
  /// carries the authoritative value to resync against).
  ///
  /// Optional sensor fields are omitted from the request entirely when not
  /// available or outside the backend's accepted range, never sent as a
  /// sentinel (e.g. `-1`) — see the accuracy/heading/speed bounds documented
  /// in the contract (0-10000m, 0-359.999°, 0-100 m/s respectively).
  Future<Result<LocationUploadAck>> uploadLocation(
    String orderId, {
    required double latitude,
    required double longitude,
    required DateTime capturedAt,
    required int assignmentVersion,
    double? accuracyMeters,
    double? headingDegrees,
    double? speedMps,
  });
}
