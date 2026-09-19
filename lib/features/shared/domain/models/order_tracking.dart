import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_tracking.freezed.dart';

/// `OrderTrackingResponseDto.state` (DRIVER_DELIVERY_API_CONTRACT.md Phase 2)
/// — derived fresh by the backend on every read, never cached client-side.
/// [unknown] is this app's own safety fallback for a future state value the
/// backend adds that this build doesn't know about yet; it is always
/// treated exactly like [ended] (no coordinates shown, no tracking loop
/// kept alive) — never like [active], since that would risk displaying a
/// location under a state this client doesn't actually understand.
enum TrackingState {
  notStarted,
  waitingForLocation,
  active,
  stale,
  ended,
  unknown,
}

TrackingState trackingStateFromWire(String? value) {
  switch (value) {
    case 'NOT_STARTED':
      return TrackingState.notStarted;
    case 'WAITING_FOR_LOCATION':
      return TrackingState.waitingForLocation;
    case 'ACTIVE':
      return TrackingState.active;
    case 'STALE':
      return TrackingState.stale;
    case 'ENDED':
      return TrackingState.ended;
    default:
      return TrackingState.unknown;
  }
}

/// A single reported driver fix — `latitude`/`longitude` are always a real,
/// valid pair here (never a `(0,0)` placeholder): the mapper only ever
/// constructs this from a non-null backend `location` object, and the
/// backend itself never emits `(0,0)` as a sentinel.
@freezed
abstract class TrackingLocationSample with _$TrackingLocationSample {
  const factory TrackingLocationSample({
    required double latitude,
    required double longitude,
    double? accuracyMeters,
    double? headingDegrees,
    double? speedMps,
    required DateTime capturedAt,
    required DateTime receivedAt,
  }) = _TrackingLocationSample;
}

/// The customer's delivery destination coordinates, as carried on every
/// tracking response (`OrderTrackingResponseDto.destination`) — always the
/// same point regardless of driver movement, so it never needs its own
/// staleness handling the way [TrackingLocationSample] does.
@freezed
abstract class TrackingDestination with _$TrackingDestination {
  const factory TrackingDestination({
    required double latitude,
    required double longitude,
  }) = _TrackingDestination;
}

/// `OrderTrackingResponseDto` (DRIVER_DELIVERY_API_CONTRACT.md Phase 2) — the
/// shape both `GET /orders/:id/tracking` (customer) and
/// `GET /admin/orders/:id/tracking` (staff) return. `driverName`/
/// `driverPhone`/`location` are only ever non-null together with a state
/// that documents them as present (see the contract's state table);
/// callers must still treat them as nullable rather than assuming the
/// state guarantees it, since this is client-side defensive parsing of a
/// contract, not a language-level guarantee.
///
/// `distanceKm`/`etaSeconds`/`encodedPolyline` are all server-computed
/// (Google Routes) and may independently be `null` when that computation
/// temporarily fails — never recomputed client-side, and a `null` route
/// must never block the driver marker itself from continuing to update.
@freezed
abstract class OrderTracking with _$OrderTracking {
  const factory OrderTracking({
    required String orderId,
    required TrackingState state,
    String? driverName,
    String? driverPhone,
    TrackingLocationSample? location,
    int? locationAgeSeconds,
    TrackingDestination? destination,
    double? distanceKm,
    int? etaSeconds,
    String? encodedPolyline,
  }) = _OrderTracking;
}

/// Backend freshness threshold (`TRACKING_FRESHNESS_THRESHOLD_SECONDS`,
/// DRIVER_DELIVERY_API_CONTRACT.md) — mirrored here so the customer screen
/// can independently age a displayed location into "stale" purely from a
/// local clock tick, without waiting on another successful poll (a failed
/// poll must never leave a location looking falsely live forever).
const int kTrackingFreshnessThresholdSeconds = 30;
